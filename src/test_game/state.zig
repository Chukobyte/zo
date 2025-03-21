//! Game state related data.  Also using this to flesh out game details.

const math = @import("zo").math;

const Vec2 = math.Vec2;

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
    name: []const u8,
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
    .{ .name = "South Carolina", .map_position = .{ .x = 331.0, .y = 237.0 } },
    .{ .name = "North Carolina", .map_position = .{ .x = 433.0, .y = 210.0 } },
    .{ .name = "Georgia", .map_position = .{ .x = 356.0, .y = 252.0 } },
    .{ .name = "Virginia", .map_position = .{ .x = 439.0, .y = 177.0 } },
    .{ .name = "Maryland", .map_position = .{ .x = 453.0, .y = 153.0 } },
    .{ .name = "Delaware", .map_position = .{ .x = 489.0, .y = 156.0 } },
    .{ .name = "Pennsylvania", .map_position = .{ .x = 451.0, .y = 132.0 } },
    .{ .name = "New Jersey", .map_position = .{ .x = 505.0, .y = 137.0 } },
    .{ .name = "Connecticut", .map_position = .{ .x = 558.0, .y = 107.0 } },
    .{ .name = "Rhode Island", .map_position = .{ .x = 570.0, .y = 105.0 } },
    .{ .name = "Massachusettes", .map_position = .{ .x = 563.0, .y = 54.0 } },
    .{ .name = "New Hampshire", .map_position = .{ .x = 534.0, .y = 87.0 } },
    .{ .name = "New York", .map_position = .{ .x = 478.0, .y = 105.0 } },
};

pub const character_pool: []Character = &.{
  .{ .name = "Guy", .ethnicity = EthnicityProfile.Black, .role = .free_man, .lead = 50, .military = 50, .charisma = 50, .intelligence = 50, .politics = 50, .abilities = .none },
};