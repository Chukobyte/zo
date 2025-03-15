//! All logic related specifically to the game prototype

pub const Abilities = enum(u32) {
    none = 0,
    battle_prowess = 1 << 0,
    orator = 1 << 1,
    enlightened = 1 << 2,
};

pub const Character = struct {
    name: []const u8,
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

pub const Map = struct {
    locations: [13]Location = .{
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
    },
};
