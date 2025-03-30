//! Game state related data.  Also using this to flesh out game details.

const std = @import("std");
const zo = @import("zo");
const math = @import("zo").math;

const Vec2 = math.Vec2;
const MinMax = math.MinMax;
const String = zo.string.HeapString;

pub const Location = struct {
    name: []const u8,
    map_position: Vec2,
};

pub const map_locations: [13]Location = .{
    .{ .name = "New Hampshire", .map_position = .{ .x = 527.0, .y = 74.0 } },
    .{ .name = "Rhode Island", .map_position = .{ .x = 568.0, .y = 90.0 } },
    .{ .name = "Connecticut", .map_position = .{ .x = 556.0, .y = 92.0 } },
    .{ .name = "Massachusettes", .map_position = .{ .x = 534.0, .y = 91.0 } },
    .{ .name = "New York", .map_position = .{ .x = 475.0, .y = 91.0 } },
    .{ .name = "New Jersey", .map_position = .{ .x = 495.0, .y = 124.0 } },
    .{ .name = "Delaware", .map_position = .{ .x = 481.0, .y = 142.0 } },
    .{ .name = "Pennsylvania", .map_position = .{ .x = 445.0, .y = 118.0 } },
    .{ .name = "Maryland", .map_position = .{ .x = 445.0, .y = 142.0 } },
    .{ .name = "Virginia", .map_position = .{ .x = 428.0, .y = 164.0 } },
    .{ .name = "North Carolina", .map_position = .{ .x = 425.0, .y = 209.0 } },
    .{ .name = "South Carolina", .map_position = .{ .x = 370.0, .y = 222.0 } },
    .{ .name = "Georgia", .map_position = .{ .x = 339.0, .y = 242.0 } },
};

pub const Abilities = enum(u32) {
    none = 0,
    battle_prowess = 1 << 0,
    orator = 1 << 1,
    enlightened = 1 << 2,

    pub fn toString(self: @This()) []const u8 {
        switch (self) {
            .none => return "None",
            .battle_prowess => return "Battle Prowess",
            .orator => return "Orator",
            .enlightened => return "Enlightened",
        }
    }
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

    pub fn toString(self: @This()) []const u8 {
        switch (self) {
            .free_man => return "Freeman",
            .slave => return "Slave",
            .governor => return "Govenor",
            .rebel_leader => return "Rebel Leader",
            .military_commander => return "Military Commander",
            .plantation_owner => return "Plantation Owner",
            .indigenous_leader => return "Indigenous Leader",
            .explorer => return "Explorer",
        }
    }
};

/// Percentage of ethnicity a character is.  Values will equal up to 100
pub const EthnicityProfile = struct {
    black: u8 = 0,
    indigenous: u8 = 0,
    white: u8 = 0,

    pub const Black: @This() = .{ .black = 100 };
    pub const Indigenous: @This() = .{ .indigenous = 100 };
    pub const White: @This() = .{ .white = 100 };

    pub fn toString(self: *const @This()) []const u8 {
        if (self.equal(&Black)) {
            return "Black";
        } else if (self.equal(&Indigenous)) {
            return "Indigenous";
        } else if (self.equal(&White)) {
            return "White";
        }
        return "Mixed";
    }

    pub fn equal(a: *const @This(), b: *const @This()) bool {
        return a.black == b.black and a.indigenous == b.indigenous and a.white == b.white;
    }
};

pub const Character = struct {
    const CharacterDetailsType = enum {
        create_character,
        location_view_character,
    };

    name: String,
    role: Role,
    ethnicity: EthnicityProfile,
    lead: u32 = 0,
    military: u32 = 0,
    charisma: u32 = 0,
    intelligence: u32 = 0,
    politics: u32 = 0,
    abilities: Abilities = .none,
    starting_location: ?*const Location = null,
    action_points: MinMax(u32) = .{ .value = 3, .min = 0, .max = 3 },

    pub fn toString(self: *const @This(), comptime detail_type: CharacterDetailsType) ![]const u8 {
        const Local = struct {
            var buffer: [256]u8 = undefined;
        };
        switch (detail_type) {
            .create_character => {
                return try std.fmt.bufPrint(
                    &Local.buffer,
                    "Role: {s}\nEthnicity: {s}\nLead: {d}\nMilitary: {d}\nCharisma: {d}\nIntelligence: {d}\nPolitics: {d}\nLocation: {s}",
                    .{ self.role.toString(), self.ethnicity.toString(), self.lead, self.military, self.charisma, self.intelligence, self.politics, self.starting_location.?.name, }
                );
            },
            .location_view_character => {
                return try std.fmt.bufPrint(
                    &Local.buffer,
                    "Name: {s}\nRole: {s}\nEthnicity: {s}\nLead: {d}\nMilitary: {d}\nCharisma: {d}\nIntelligence: {d}\nPolitics: {d}\nAbilities: {s}",
                    .{ self.name.get(), self.role.toString(), self.ethnicity.toString(), self.lead, self.military, self.charisma, self.intelligence, self.politics, self.abilities.toString(), }
                );
            },
        }
    }
};

pub const Date = struct {
    pub const Month = enum {
        jan,
        feb,
        mar,
        apr,
        may,
        jun,
        jul,
        aug,
        sep,
        oct,
        nov,
        dec
    };

    month: Month,
    year: u32,

    pub fn incrementMonth(self: *@This()) void {
        self.month = @enumFromInt((@intFromEnum(self.month) + 1) % 12);
        if (self.month == .jan) {
            self.year += 1;
        }
    }

    pub fn toMonthString(self: *const @This()) []const u8 {
        return switch (self.month) {
            .jan => return "Jan",
            .feb => return "Feb",
            .mar => return "Mar",
            .apr => return "Apr",
            .may => return "May",
            .jun => return "Jun",
            .jul => return "Jul",
            .aug => return "Aug",
            .sep => return "Sep",
            .oct => return "Oct",
            .nov => return "Nov",
            .dec => return "Dec",
        };
    }

    pub fn toString(self: *const @This()) []const u8 {
        const Local = struct {
            var buffer: [32]u8 = undefined;
        };
        return std.fmt.bufPrint(&Local.buffer, "{s} {d}", .{ self.toMonthString(), self.year }) catch unreachable;
    }
};

pub const GameState = struct {
    player_character: Character,
    date: Date,
};

pub var game_state: GameState = .{
    .player_character = .{
        .name = undefined,
        .role = .free_man,
        .ethnicity = EthnicityProfile.Black,
        .starting_location = &map_locations[9],
    },
    .date = .{
        .month = .jan,
        .year = 1700,
    },
};

// Structs not in use yet

const Troop = struct {
    active: u32,
    injured: u32,
    leader: ?*Character = null,
};
