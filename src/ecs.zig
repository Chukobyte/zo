const std = @import("std");

const misc = @import("misc.zig");

const log = @import("logger.zig").log;

const ArrayListUtils = misc.ArrayListUtils;
const FlagUtils = misc.FlagUtils;
const TypeList = misc.TypeList;
const TypeBitMask = misc.TypeBitMask;

pub const Entity = u32;

const ECSWorldParams = struct {
    entity_interfaces: []const type = &[_]type{},
    components: []const type = &[_]type{},
    systems: []const type = &[_]type{},
    archetypes: []const []const type = &[_][]type{},
};

const EntityInterfaceData = struct {
    id: usize,
    instance: *anyopaque,
};

const InitEntityParams = struct {
    interface: ?type = null,
};

pub fn ECSWorld(params: ECSWorldParams) type {
    const entity_interface_types = params.entity_interfaces;
    const component_types = params.components;
    const system_types = params.systems;
    const archetypes_array = params.archetypes;
    const EntityInterfaceTypeList = TypeList(entity_interface_types);
    const ComponentTypeList = TypeList(component_types);
    const SystemsTypeList = TypeList(system_types);
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
                const archetype_signature = ComponentTypeList.getFlags(archetype_types);
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
                            list_data.sorted_components_by_index[list_data.num_of_sorted_components][i] = ComponentTypeList.getIndex(component_types[i]);
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
                    archetype_list_data[archetypes_count].sorted_components_by_index[0][i] = ComponentTypeList.getIndex(component_types[i]);
                }
                archetypes_count += 1;
            }
            return archetype_list_data[0..archetypes_count];
        }
    };

    const ArchetypeList = struct {
        fn getIndex(components: []const type) comptime_int {
            const types_sig = ComponentTypeList.getFlags(components);
            const archetype_list_data = comptime ArchetypeListData.generate();
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
            const archetype_list_data = comptime ArchetypeListData.generate();
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
            const archetype_list_data = comptime ArchetypeListData.generate();
            return archetype_list_data.len;
        }

        fn getSortedComponentMax() comptime_int {
            var sorted_comp_max = 0;
            const archetype_list_data = comptime ArchetypeListData.generate();
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

    // ECSWorld struct
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

        pub fn ArchetypeComponentIterator(arch_comps: []const type) type {
            const comp_sort_index = ArchetypeList.getSortIndex(arch_comps);
            const arch_index = ArchetypeList.getIndex(arch_comps);
            const archetype_list_data = comptime ArchetypeListData.generate();
            const list_data = &archetype_list_data[arch_index];

            return struct {
                current_index: usize,
                archetype: *ArchetypeData,
                entities: []Entity,
                components: *[arch_comps.len]*anyopaque,

                pub inline fn init() @This() {
                    var new_iterator = @This(){
                        .current_index = 0,
                        .archetype = list_data,
                        .entities = undefined,
                        .components = undefined,
                    };
                    new_iterator.entities = new_iterator.archetype.entities.items[0..];
                    if (new_iterator.entities.len != 0) {
                        new_iterator.components = new_iterator.archetype.sorted_components.items[new_iterator.entities[0]][comp_sort_index][0..arch_comps.len];
                    }
                    return new_iterator;
                }

                pub fn next(self: *@This()) ?*const @This() {
                    if (self.isValid()) {
                        self.components = self.archetype.sorted_components.items[self.entities[self.current_index]][comp_sort_index][0..arch_comps.len];
                        self.current_index += 1;
                        return self;
                    }
                    return null;
                }

                pub fn peek(self: *@This()) ?*@This() {
                    if (self.isValid()) {
                        return self;
                    }
                    return null;
                }

                pub inline fn isValid(self: *const @This()) bool {
                    return self.current_index < self.entities.len;
                }

                pub inline fn getSlot(self: *const @This(), comptime T: type) usize {
                    _ = self;
                    return getComponentSlot(T);
                }

                fn getComponentSlot(comptime T: type) usize {
                    inline for (0..list_data.num_of_components) |i| {
                        if (T == list_data.sorted_components[comp_sort_index][i]) {
                            return i;
                        }
                    }
                    @compileError("Comp isn't in iterator!");
                }

                pub inline fn getComponent(self: *const @This(), comptime T: type) *T {
                    return @alignCast(@ptrCast(self.components[getComponentSlot(T)]));
                }

                pub inline fn getValue(self: *const @This(), slot: comptime_int) *arch_comps[slot] {
                    return @alignCast(@ptrCast(self.components[slot]));
                }

                pub inline fn getEntity(self: *const @This()) Entity {
                    return self.entities[self.current_index - 1];
                }
            };
        }

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
            const world: @This() = .{
                .allocator = allocator,
                .entity_data = entity_data_list,
                .system_data = undefined,
                .archetype_data = undefined,
                .update_entities = update_entities_list,
                .fixed_update_entities = fixed_update_entities_list,
            };
            // Setup archetype data
            const archetype_list_data = comptime ArchetypeListData.generate();
            inline for (0..archetype_count) |i| {
                const arch_list_data = &archetype_list_data[i];
                const context_arch_data = &world.archetype_data[i];
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
                const SystemT = SystemsTypeList.getType(i);
                var new_system: *SystemT = try allocator.create(SystemT);
                // All system members should have default values in order to 'default construct' them
                @memcpy(std.mem.asBytes(new_system), std.mem.asBytes(&SystemT{}));
                world.system_data[i].interface_instance = new_system;
                if (@hasDecl(SystemT, "getSignature")) {
                    const system_component_signature: []const type = new_system.getSignature();
                    world.system_data[i].component_signature.setFlagsFromTypes(system_component_signature);
                } else {
                    world.system_data[i].component_signature = .{};
                }
                if (@hasDecl(SystemT, "init")) {
                    new_system.init(world);
                }
            }
            return world;
        }

        pub fn deinit(self: *@This()) void {
            for (0..self.entity_data.items.len) |i| {
                const entity: Entity = @intCast(i);
                self.deinitEntity(entity);
            }

            inline for (0..system_types.len) |i| {
                const SystemT = SystemsTypeList.getType(i);
                if (@hasDecl(SystemT, "deinit")) {
                    var system: *SystemT = @alignCast(@ptrCast(self.system_data[i].interface_instance));
                    system.deinit(self);
                }
            }
            self.entity_data.deinit();
        }

        pub fn update(self: *@This(), delta_seconds: f32) !void {
            for (self.update_entities.items) |entity| {
                const entity_data: *EntityData = &self.entity_data.items[entity];
                inline for (0..entity_interface_types.len) |interface_id| {
                    if (entity_data.interface.?.id == interface_id) {
                        const T = EntityInterfaceTypeList.getType(interface_id);
                        if (@hasDecl(T, "update")) {
                            const interface_ptr: *T = @alignCast(@ptrCast(entity_data.interface.?.instance));
                            try interface_ptr.update(self, entity, delta_seconds);
                            break;
                        }
                    }
                }
            }
        }

        pub fn fixed_update(self: *@This(), delta_seconds: f32) !void {
            for (self.fixed_update_entities.items) |entity| {
                const entity_data: *EntityData = &self.entity_data.items[entity];
                inline for (0..entity_interface_types.len) |interface_id| {
                    if (entity_data.interface.?.id == interface_id) {
                        const T = EntityInterfaceTypeList.getType(interface_id);
                        if (@hasDecl(T, "fixed_update")) {
                            const interface_ptr: *T = @alignCast(@ptrCast(entity_data.interface.?.instance));
                            try interface_ptr.fixed_update(self, entity, delta_seconds);
                            break;
                        }
                    }
                }
            }
        }

        pub fn initEntity(self: *@This(), entity_params: ?InitEntityParams) !Entity {
            const p: InitEntityParams = entity_params orelse .{};
            var newEntity: Entity = undefined;
            if (self.getExistingEntityId()) |entity| {
                newEntity = entity;
            } else {
                // Create new entity
                newEntity = @intCast(self.entity_data.items.len);
                _ = try self.entity_data.addOne();
            }
            // Reset and update entity data
            const entity_data: *EntityData = &self.entity_data.items[newEntity];
            if (p.interface) |InterfaceT| {
                const interface_id = EntityInterfaceTypeList.getIndex(InterfaceT);
                var interface_inst: *InterfaceT = try self.allocator.create(InterfaceT);
                @memcpy(std.mem.asBytes(interface_inst), std.mem.asBytes(&InterfaceT{}));
                entity_data.interface = .{ .id = interface_id, .instance = interface_inst };
                if (@hasDecl(InterfaceT, "init")) {
                    inline for (0..entity_interface_types.len) |id| {
                        if (interface_id == id) {
                            try interface_inst.init(self, newEntity);
                            break;
                        }
                    }
                }
                if (@hasDecl(InterfaceT, "update")) {
                    try self.update_entities.append(newEntity);
                }
                if (@hasDecl(InterfaceT, "fixed_update")) {
                    try self.fixed_update_entities.append(newEntity);
                }
            } else {
                entity_data.interface = null;
            }
            return newEntity;
        }

        pub fn deinitEntity(self: *@This(), entity: Entity) void {
            if (self.isEntityValid(entity)) {
                if (self.entity_data.items[entity].interface) |interface| {
                    inline for (0..entity_interface_types.len) |id| {
                        if (interface.id == id) {
                            const InterfaceT = EntityInterfaceTypeList.getType(id);
                            if (@hasDecl(InterfaceT, "deinit")) {
                                var interface_inst: *InterfaceT = @alignCast(@ptrCast(interface.instance));
                                interface_inst.deinit(self, entity);
                            }
                            if (@hasDecl(InterfaceT, "update")) {
                                ArrayListUtils.removeByValue(Entity, &self.update_entities, &entity);
                            }
                            if (@hasDecl(InterfaceT, "fixed_update")) {
                                ArrayListUtils.removeByValue(Entity, &self.fixed_update_entities, &entity);
                            }
                            break;
                        }
                    }
                }
                self.refreshArchetypeState(entity) catch {}; // Ignore
            }
        }

        pub inline fn isEntityValid(self: *const @This(), entity: Entity) bool {
            return (
                entity < self.entity_data.items.len
                // and self.entity_data.items[entity] != null
                and !self.entity_data.items[entity].queued_for_deletion
            );
        }

        pub fn setComponent(self: *@This(), entity: Entity, comptime T: type, component: *const T) !void {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            const comp_index = ComponentTypeList.getIndex(T);
            if (!self.hasComponent(entity,T)) {
                const new_comp: *T = try self.allocator.create(T);
                @memcpy(std.mem.asBytes(new_comp), std.mem.asBytes(component));
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
            const comp_index: usize = ComponentTypeList.getIndex(T);
            if (entity_data.components[comp_index]) |comp| {
                return @alignCast(@ptrCast(comp));
            }
            return null;
        }

        pub fn removeComponent(self: *@This(), entity: Entity, comptime T: type) void {
            if (self.hasComponent(entity, T)) {
                const entity_data: *EntityData = &self.entity_data_list.items[entity];
                const comp_index: usize = ComponentTypeList.getIndex(T);
                const comp_ptr: *T = @alignCast(@ptrCast(entity_data.components[comp_index]));

                if (@hasDecl(T, "deinit")) {
                    comp_ptr.deinit();
                }

                self.allocator.destroy(comp_ptr);
                entity_data.components[comp_index] = null;
                entity_data.component_signature.unset(T);
                try self.refreshArchetypeState(entity);
            }
        }

        pub inline fn hasComponent(self: *@This(), entity: Entity, comptime T: type) bool {
            const entity_data: *EntityData = &self.entity_data_list.items[entity];
            const comp_index: usize = ComponentTypeList.getIndex(T);
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
                const entity: Entity = @intCast(i);
                if (self.isEntityValid(entity)) {
                    return entity;
                }
            }
            return null;
        }

        // Archetype
        fn refreshArchetypeState(self: *@This(), entity: Entity) !void {
            const SystemNotifyState = enum {
                none,
                on_entity_registered,
                on_entity_unregistered,
            };

            const Static = struct {
                var SystemState: [system_types.len]SystemNotifyState = undefined;
            };

            const entity_data: *EntityData = &self.entity_data.items[entity];
            const archetype_list_data = comptime ArchetypeListData.generate();

            inline for (0..archetype_count) |i| {
                const arch_data = &self.archetype_data[i];
                const match_signature = FlagUtils(usize).containsFlags(entity_data.component_signature.mask, arch_data.signature);
                if (match_signature and !entity_data.is_in_archetype_map[i]) {
                    entity_data.is_in_archetype_map[i] = true;
                    arch_data.entities.append(entity) catch { unreachable; };
                    if (entity >= arch_data.sorted_components.items.len) {
                        _ = try arch_data.sorted_components.addManyAsSlice(entity + 1 - arch_data.sorted_components.items.len);
                    }
                    // Update sorted component arrays
                    inline for (0..archetype_list_data[i].num_of_sorted_components) |sort_comp_i| {
                        inline for (0..archetype_list_data[i].num_of_components) |comp_i| {
                            // Map component pointers with order
                            const entity_comp_index = arch_data.sorted_components_by_index[sort_comp_i][comp_i];
                            arch_data.sorted_components.items[entity][sort_comp_i][comp_i] = entity_data.components[entity_comp_index].?;
                            if (comp_i + 1 >= arch_data.num_of_components)  {
                                break;
                            }
                        }
                        if (sort_comp_i + 1 >= arch_data.num_of_sorted_components)  {
                            break;
                        }
                    }

                    for (0..arch_data.system_count) |sys_i| {
                        const system_index = arch_data.systems[sys_i];
                        Static.SystemState[system_index] = .on_entity_registered;
                    }
                } else if (!match_signature and entity_data.is_in_archetype_map[i]) {
                    entity_data.is_in_archetype_map[i] = false;
                    for (0..arch_data.entities.items.len) |item_index| {
                        if (arch_data.entities.items[item_index] == entity) {
                            _ = arch_data.entities.swapRemove(item_index);
                            break;
                        }
                    }
                    for (0..arch_data.system_count) |sys_i| {
                        const system_index = arch_data.systems[sys_i];
                        Static.SystemState[system_index] = .on_entity_unregistered;
                    }
                }
            }

            inline for (self.system_data, 0..system_types.len) |*system_data, i| {
                const T: type = SystemsTypeList.getType(i);
                switch (Static.SystemState[i]) {
                    .on_entity_registered => {
                        if (@hasDecl(T, "onEntityRegistered")) {
                            var system: *T = @alignCast(@ptrCast(system_data.interface_instance));
                            system.onEntityRegistered(self, entity);
                        }
                        Static.SystemState[i] = .none;
                    },
                    .on_entity_unregistered => {
                        if (@hasDecl(T, "onEntityUnregistered")) {
                            var system: *T = @alignCast(@ptrCast(system_data.interface_instance));
                            system.onEntityUnregistered(self, entity);
                        }
                        Static.SystemState[i] = .none;
                    },
                    .none => {},
                }
            }
        }
    };
}