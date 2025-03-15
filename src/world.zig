//! World is a single instance of a 'game', there will only be one world at a time

const std = @import("std");

const String = @import("string.zig").String;

const ArrayList = std.ArrayList;
const ArrayListUtils = @import("misc.zig").ArrayListUtils;

pub const GameObjectId = u32;

pub const GameObject = struct {
    id: GameObjectId,
    name: String,
    parent: ?*@This() = null,
    update: ?*fn(f32) bool = null,
    fixed_update: ?*fn(f32) bool = null,
    init: ?*fn() bool = null,
    deinit: ?*fn() void = null,
};

pub const GameObjectTemplate = struct {
    name: []const u8,
    update: ?*fn(f32) bool = null,
    fixed_update: ?*fn(f32) bool = null,
    init: ?*fn() bool = null,
    deinit: ?*fn() void = null,
};

const GameObjectList = struct {
    const max_objects = 10_000;

    objects: [max_objects]?GameObject = [_]?GameObject{null} ** max_objects,
    len: usize = 0,

    pub fn createObj(self: *GameObjectList, allocator: std.mem.Allocator) !*GameObject {
        if (self.getNewId()) |new_id| {
            const name_string: String = try String.init(allocator);
            const new_object: GameObject = .{
                .id = new_id,
                .name = name_string,
            };
            self.objects[new_id] = new_object;
            return &self.objects[new_id];
        }
    }

    pub fn removeObj(self: *GameObjectList, game_obj: *GameObject) void {
        game_obj.name.deinit();
        self.objects[game_obj.id] = null;
    }

    fn getNewId(self: *GameObjectList) ?GameObjectId {
        for (0..max_objects) |i| {
            if (self.objects[i] == null) {
                return i;
            }
        }
        return null;
    }

};

/// Scene is an abstraction of a 'level' within a world
pub const Scene = struct {
    name: []const u8,
    objects: ArrayList(*GameObject),
};

pub const World = struct {
    active_scene: ?Scene = null,
    objects: GameObjectList = .{},

    pub fn update(self: *@This(), delta_seconds: f32) void {
        if (self.active_scene) |scene| {
            for (scene.objects.items) |game_obj| {
                if (game_obj.update) |update_func| {
                    _ = update_func(delta_seconds);
                }
            }
        }
    }

    pub fn fixed_update(self: *@This(), delta_seconds: f32) void {
        if (self.active_scene) |scene| {
            for (scene.objects.items) |game_obj| {
                if (game_obj.fixed_update) |fixed_update_func| {
                    _ = fixed_update_func(delta_seconds);
                }
            }
        }
    }

    pub fn initScene(self: *@This(), allocator: std.mem.Allocator, name: []const u8) !*Scene {
        const obj_list = ArrayList(*GameObject).init(allocator);
        self.active_scene = .{ .name = name, .objects = obj_list, };
        return &self.active_scene.?;
    }

    pub fn deinitActiveScene(self: *@This()) void {
        if (self.active_scene) |scene| {
            scene.objects.deinit();
            self.active_scene = null;
        }
    }

    pub fn initObject(self: *@This(), allocator: std.mem.Allocator, template: GameObjectTemplate) !*GameObject {
        var new_obj: *GameObject = try self.objects.createObj(allocator);
        new_obj.name.set(template.name, .{});
        new_obj.init = template.init;
        new_obj.deinit = template.deinit;
        new_obj.update = template.update;
        return new_obj;
    }

    pub fn deinitObject(self: *@This(), game_obj: *GameObject) *GameObject {
        if (game_obj.deinit) |deinit_func| {
            deinit_func();
        }
        if (self.active_scene) |scene| {
            ArrayListUtils.removeByValue(*GameObject, scene.objects, game_obj);
        }
        self.objects.removeObj(game_obj);
    }

    pub fn addObjectToScene(self: *@This(), scene: *Scene,  game_obj: *GameObject, parent: ?*GameObject) !void {
        _ = self;
        game_obj.parent = parent;
        scene.objects.append(game_obj);
        if (game_obj.init) |init_func| {
            _ = init_func();
        }
    }
};
