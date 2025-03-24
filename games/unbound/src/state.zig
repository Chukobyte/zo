//! Game state related data.  Also using this to flesh out game details.

const zo = @import("zo");
const math = @import("zo").math;

const Vec2 = math.Vec2;
const String = zo.string.HeapString;

pub const Abilities = enum(u32) {
    none = 0,
    battle_prowess = 1 << 0,
    orator = 1 << 1,
    enlightened = 1 << 2,
};

pub const Role = enum {
    free_man,
    slave,
    governor,
    rebel_leader,
    military_commander,
    plantation_owner,
    indigenous_leader,
    explorer,
};

/// Percentage of ethnicity a character is.  Values will equal up to 100
pub const EthnicityProfile = struct {
    black: u8 = 0,
    indigenous: u8 = 0,
    white: u8 = 0,

    pub const Black: @This() = .{ .black = 100 };
    pub const Indigenous: @This() = .{ .indigenous = 100 };
    pub const White: @This() = .{ .white = 100 };
};

pub const Character = struct {
    name: String,
    role: Role,
    ethnicity: EthnicityProfile,
    lead: u32 = 0,
    military: u32 = 0,
    charisma: u32 = 0,
    intelligence: u32 = 0,
    politics: u32 = 0,
    abilities: Abilities = .none,
};

pub const Location = struct {
    name: []const u8,
    map_position: Vec2,
};

pub const map_locations: [13]Location = .{
    .{ .name = "New Hampshire", .map_position = .{ .x = 527.0, .y = 90.0 } },
    .{ .name = "Rhode Island", .map_position = .{ .x = 568.0, .y = 106.0 } },
    .{ .name = "Connecticut", .map_position = .{ .x = 556.0, .y = 108.0 } },
    .{ .name = "Massachusettes", .map_position = .{ .x = 534.0, .y = 107.0 } },
    .{ .name = "New York", .map_position = .{ .x = 475.0, .y = 107.0 } },
    .{ .name = "New Jersey", .map_position = .{ .x = 495.0, .y = 140.0 } },
    .{ .name = "Delaware", .map_position = .{ .x = 481.0, .y = 158.0 } },
    .{ .name = "Pennsylvania", .map_position = .{ .x = 445.0, .y = 134.0 } },
    .{ .name = "Maryland", .map_position = .{ .x = 445.0, .y = 158.0 } },
    .{ .name = "Virginia", .map_position = .{ .x = 428.0, .y = 180.0 } },
    .{ .name = "North Carolina", .map_position = .{ .x = 425.0, .y = 215.0 } },
    .{ .name = "South Carolina", .map_position = .{ .x = 370.0, .y = 238.0 } },
    .{ .name = "Georgia", .map_position = .{ .x = 339.0, .y = 258.0 } },
};

pub const character_pool: []Character = &.{
  // .{ .name = "Guy", .ethnicity = EthnicityProfile.Black, .role = .free_man, .lead = 50, .military = 50, .charisma = 50, .intelligence = 50, .politics = 50, .abilities = .none },
};