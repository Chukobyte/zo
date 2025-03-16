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
    archetypes: []const []const type = .{},
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
    const archetypes_array = params.archetypes;
    const entity_interface_type_list = TypeList(entity_interface_types);
    const component_type_list = TypeList(component_types);
    const systems_type_list = TypeList(system_types);
    const ComponentSignature = TypeBitMask(component_types);

    const ArchetypeListData = struct {
        const sorted_components_max = 4; // TODO: Get by inspecting data
        const components_max = 32; // TODO: Get by inspecting data

        signature: usize,
        num_of_components: usize,
        num_of_sorted_components: usize = 0,
        sorted_components: [sorted_components_max][components_max]type = undefined,
        sorted_components_by_index: [sorted_components_max][components_max]usize = undefined,

        /// Generates compile time archetype data for queries
        fn generate() []@This() {
            var archetypes_count: usize = 0;
            var archetype_list_data: [component_types.len * component_types.len]@This() = undefined;
            main: for (archetypes_array) |archetype_types| {
                // Check if archetype already exists
                    const archetype_signature = component_type_list.getFlags(archetype_types);
                for (0..archetypes_count) |arch_i| {
                    const list_data: *@This() = &archetype_list_data[arch_i];
                    // The archetype already exists, now we check to see if we need to add new sort array for archetype
                        var is_duplicate = true;
                    if (archetype_signature == list_data.signature) {
                        for (0..list_data.num_of_sorted_components) |sort_i| {
                            if (archetype_types != list_data.num_of_sorted_components[sort_i]) {
                                is_duplicate = false;
                                break;
                            }
                        }
                        if (is_duplicate) {
                            continue :main;
                        }
                        // No duplicates found, create new sorted comps row
                            for (0..list_data.num_of_components) |i| {
                            list_data.sorted_components[list_data.num_of_sorted_components][i] = archetype_types[i];
                            list_data.sorted_components_by_index[list_data.num_of_sorted_components][i] = component_type_list.getIndex(component_types[i]);
                        }
                        list_data.num_of_sorted_components += 1;
                        continue :main;
                    }
                }

                // Now that it doesn't exist add it
                    archetype_list_data[archetypes_count] = @This(){
                    .signature = archetype_signature,
                    .num_of_components = component_types.len,
                    .num_of_sorted_components = 1
                };
                for (0..component_types.len) |i| {
                    archetype_list_data[archetypes_count].sorted_components[0][i] = component_types[i];
                    archetype_list_data[archetypes_count].sorted_components_by_index[0][i] = component_type_list.getIndex(component_types[i]);
                }
                archetypes_count += 1;
            }
            return archetype_list_data[0..archetypes_count];
        }
    };

    const archetype_list_data = ArchetypeListData.generate();

    const ArchetypeList = struct {
        fn getIndex(components: []const type) comptime_int {
            const types_sig = component_type_list.getFlags(components);
            for (0..archetype_list_data.len) |i| {
                const list_data = archetype_list_data[i];
                if (types_sig == list_data.signature) {
                    return i;
                }
            }
            @compileError("Didn't pass in valid component types!");
        }

        fn getSortIndex(components: []const type) comptime_int {
            const arch_index = getIndex(components);
            const list_data = &archetype_list_data[arch_index];
            const num_of_sorted_components = list_data.num_of_sorted_components;
            const num_of_components = list_data.num_of_components;
            inline for (0..num_of_sorted_components) |i| {
                inline for (0..num_of_components) |comp_i| {
                    if (components[comp_i] != list_data.sorted_components[i][comp_i]) {
                        break;
                    } else {
                        if (comp_i <= num_of_components - 1) {
                            return i;
                        }
                    }
                }
            }
            @compileError("Didn't pass in valid component types for sort index!");
        }

        fn getArchetypeCount() comptime_int {
            return archetype_list_data.len;
        }

        fn getSortedComponentMax() comptime_int {
            var sorted_comp_max = 0;
            for (archetype_list_data) |*list_data| {
                if (list_data.num_of_sorted_components > sorted_comp_max) {
                    sorted_comp_max = list_data.num_of_sorted_components;
                }
            }
            return sorted_comp_max;
        }
    };

    const sorted_components_max = ArchetypeList.getSortedComponentMax();
    const archetype_count = ArchetypeList.getArchetypeCount();

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

        const ArchetypeData = struct {
            sorted_components: std.ArrayList([sorted_components_max][component_types.len]*anyopaque) = undefined,
            entities: std.ArrayList(Entity) = undefined,
            sorted_components_by_index: [sorted_components_max][component_types.len]usize = undefined,
            systems: [system_types.len]usize = undefined, // System indices
            system_count: usize = 0,
            signature: usize = 0,
            num_of_components: usize = 0,
            num_of_sorted_components: usize = 0,
        };

        allocator: std.mem.Allocator,
        entity_data: std.ArrayList(EntityData),
        system_data: [system_types.len]SystemData,
        archetype_data: [archetype_count]ArchetypeData,
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
                .archetype_data = undefined,
                .update_entity = update_entities_list,
                .fixed_update_entities = fixed_update_entities_list,
            };
            // Setup archetype data
            inline for (0..archetype_count) |i| {
                const arch_list_data = &archetype_list_data[i];
                const context_arch_data = &context.archetype_data[i];
                context_arch_data.entities = std.ArrayList(Entity).init(allocator);
                context_arch_data.sorted_components = std.ArrayList([sorted_components_max][component_types.len]*anyopaque).init(allocator);
                for (0..arch_list_data.num_of_sorted_components) |comp_sort_i| {
                    for (0..arch_list_data.num_of_components) |comp_i| {
                        context_arch_data.sorted_components_by_index[comp_sort_i][comp_i] = arch_list_data.sorted_components_by_index[comp_sort_i][comp_i];
                    }
                }
                context_arch_data.signature = arch_list_data.signature;
                context_arch_data.num_of_components = arch_list_data.num_of_components;
                context_arch_data.num_of_sorted_components = arch_list_data.num_of_sorted_components;
            }
            // Setup systems
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