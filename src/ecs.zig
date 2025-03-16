const std = @import("std");

const misc = @import("misc.zig");

const ArrayListUtils = misc.ArrayListUtils;
const TypeList = misc.TypeList;
const TypeBitMask = misc.TypeBitMask;

const Entity = u32;

const ECSWorldParams = struct {
    entity_interfaces: []const type = .{},
    components: []const type = .{},
    systems: []const type = .{},
};

const EntityInterfaceData = struct {
    id: usize,
    instance: *anyopaque,
};

const InitEntityParams = struct {
    interface: ?type = null,
};

pub fn ECSWorld(params: ECSWorldParams) type {
    misc.assertUnsigned(params.entity_type);
    const entity_interface_types = params.entity_interfaces;
    const component_types = params.components;
    const system_types = params.systems;
    const entity_interface_type_list = TypeList(entity_interface_types);
    const component_type_list = TypeList(component_types);
    const systems_type_list = TypeList(system_types);
    const ComponentSignature = TypeBitMask(component_types);

    return struct {

        const EntityData = struct {
            components: [component_types.len]?*anyopaque = [_]?*anyopaque{null} ** component_types.len,
            interface: ?EntityInterfaceData = null,
            component_signature: ComponentSignature = .{},
            queued_for_deletion: bool = false,
        };

        const SystemData = struct {
            interface_instance: *anyopaque,
            component_signature: ComponentSignature,
        };

        allocator: std.mem.Allocator,
        entity_data: std.ArrayList(EntityData),
        system_data: [system_types.len]SystemData,
        update_entities: std.ArrayList(Entity),
        fixed_update_entities: std.ArrayList(Entity),

        pub fn init(allocator: std.mem.Allocator) !@This() {
            const entity_data_list = std.ArrayList(EntityData).init(allocator);
            const update_entities_list = std.ArrayList(Entity).init(allocator);
            const fixed_update_entities_list = std.ArrayList(Entity).init(allocator);
            const context: @This() = .{
                .allocator = allocator,
                .entity_data = entity_data_list,
                .system_data = undefined,
                .update_entity = update_entities_list,
                .fixed_update_entities = fixed_update_entities_list,
            };
            inline for (0..system_types.len) |i| {
                const SystemT = systems_type_list.getType(i);
                var new_system: *SystemT = try allocator.create(SystemT);
                // All system members should have default values in order to 'default construct' them
                @memcpy(std.mem.asBytes(new_system), std.mem.asBytes(&SystemT{}));
                context.system_data[i].interface_instance = new_system;
                if (@hasDecl(SystemT, "getSignature")) {
                    const system_component_signature: []const type = new_system.getSignature();
                    context.system_data[i].component_signature.setFlagsFromTypes(system_component_signature);
                } else {
                    context.system_data[i].component_signature = .{};
                }
                if (@hasDecl(SystemT, "init")) {
                    new_system.init(context);
                }
            }
            return context;
        }

        pub fn deinit(self: *@This()) void {
            inline for (0..system_types.len) |i| {
                const SystemT = systems_type_list.getType(i);
                if (@hasDecl(SystemT, "deinit")) {
                    var system: *SystemT = @alignCast(@ptrCast(self.system_data[i].interface_instance));
                    system.deinit(self);
                }
            }
            self.entity_data.deinit();
        }

        pub fn initEntity(self: *@This(), entity_params: ?InitEntityParams) !Entity {
            const p: InitEntityParams = entity_params orelse .{};
            var newEntity: Entity = undefined;
            if (self.getExistingEntityId()) |entity| {
                newEntity = entity;
            } else {
                // Create new entity
                newEntity = self.entity_data.items.len;
                _ = try self.entity_data.addOne();
            }
            // Reset and update entity data
            const entity_data: *EntityData = &self.entity_data.items[newEntity];
            const interface_id = entity_interface_type_list.getIndex(p.interface);
            entity_data.interface = .{ .id = interface_id, .instance = p.interface};

            if (entity_params) |entity_p| {
                if (@hasDecl(entity_p.interface, "update")) {
                    self.update_entities.append(newEntity);
                }
                if (@hasDecl(entity_p.interface, "fixed_update")) {
                    self.fixed_update_entities.append(newEntity);
                }
            }
            return newEntity;
        }

        pub fn deinitEntity(self: *@This(), entity: Entity) void {
            if (self.isEntityValid(entity)) {
                if (self.entity_data.items[entity].interface) |interface| {
                    const InterfaceT = entity_interface_type_list.getType(interface.id);
                    var interface_inst: *InterfaceT = @alignCast(@ptrCast(interface.instance));
                    if (@hasDecl(InterfaceT, "deinit")) {
                        interface_inst.deinit(entity);
                    }
                    if (@hasDecl(InterfaceT, "update")) {
                        ArrayListUtils.removeByValue(Entity, &self.update_entities, entity);
                    }
                    if (@hasDecl(InterfaceT, "fixed_update")) {
                        ArrayListUtils.removeByValue(Entity, &self.fixed_update_entities, entity);
                    }
                }
            }
        }

        pub inline fn isEntityValid(self: *const @This(), entity: Entity) bool {
            return (entity < self.entity_data.items.len
                and self.entity_data.items[entity] != null
                and !self.entity_data.items[entity].queued_for_deletion
            );
        }

        pub fn setComponent(self: *@This(), entity: Entity, comptime T: type, component: *const T) !void {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            const comp_index = component_type_list.getIndex(T);
            if (!self.hasComponent(entity,T)) {
                const new_comp: *T = try self.allocator.create(T);
                @memcpy(std.mem.asBytes(new_comp), std.mem.asBytes(component));

                if (@hasDecl(T, "init")) {
                    new_comp.init();
                }

                entity_data.components[comp_index] = new_comp;
                entity_data.component_signature.set(T);
                try self.refreshArchetypeState(entity);
            } else {
                const current_comp: *T = @alignCast(@ptrCast(entity_data.components[comp_index].?));
                @memcpy(std.mem.asBytes(current_comp), std.mem.asBytes(component));
            }

        }

        pub fn getComponent(self: *@This(), entity: Entity, comptime T: type) ?*T {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            const comp_index: usize = component_type_list.getIndex(T);
            if (entity_data.components[comp_index]) |comp| {
                return @alignCast(@ptrCast(comp));
            }
            return null;
        }

        pub fn removeComponent(self: *@This(), entity: Entity, comptime T: type) void {
            if (self.hasComponent(entity, T)) {
                const entity_data: *EntityData = &self.entity_data_list.items[entity];
                const comp_index: usize = component_type_list.getIndex(T);
                const comp_ptr: *T = @alignCast(@ptrCast(entity_data.components[comp_index]));

                if (@hasDecl(T, "deinit")) {
                    comp_ptr.deinit();
                }

                self.allocator.destroy(comp_ptr);
                entity_data.components[comp_index] = null;
                entity_data.component_signature.unset(T);
            }
        }

        pub inline fn hasComponent(self: *@This(), entity: Entity, comptime T: type) bool {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            const comp_index: usize = component_type_list.getIndex(T);
            return entity_data.components[comp_index] != null;
        }

        pub fn setComponentEnabled(self: *@This(), entity: Entity, comptime T: type, enabled: bool) void {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            entity_data.component_signature.setEnabled(T, enabled);
        }

        pub fn isComponentEnabled(self: *@This(), entity: Entity, comptime T: type) bool {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            return entity_data.component_signature.isEnabled(T);
        }

        fn getExistingEntityId(self: *@This()) ?Entity {
            for (0..self.entity_data.items.len) |i| {
                if (self.entity_data.items[i] == null) {
                    return i;
                }
            }
            return null;
        }
    };
}