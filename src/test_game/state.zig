//! Game state related data.  Also using this to flesh out game details.

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
};

pub const map_locations: []Location = .{
    .{ .name = "South Carolina" },
    .{ .name = "North Carolina" },
    .{ .name = "Georgia" },
    .{ .name = "Virginia" },
    .{ .name = "Maryland" },
    .{ .name = "Delaware" },
    .{ .name = "Pennsylvania" },
    .{ .name = "New Jersey" },
    .{ .name = "Connecticut" },
    .{ .name = "Rhode Island" },
    .{ .name = "Massachusettes" },
    .{ .name = "New Hampshire" },
    .{ .name = "New York" },
};

pub const character_pool: []Character = &.{
  .{ .name = "Guy", .ethnicity = EthnicityProfile.Black, .role = .free_man, .lead = 50, .military = 50, .charisma = 50, .intelligence = 50, .politics = 50, .abilities = .none },
};