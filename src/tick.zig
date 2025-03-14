const std = @import("std");

const TickParams = struct {
    interface: type,
    target_fps: u32,
    fixed_target_fps: ?u32 = null,
};

const Tick = struct {
    interface: type,
    start_time: u64 = 0,
    current_time: u64 = 0,
    accumaltor: f32 = 0.0,
    update_interval: u32 = 0,
    fixed_update_interval: f32 = 0.0,
    fixed_delta_time: f32 = 0.0,

    pub fn init(comptime p: TickParams) @This() {
        var new_tick: Tick = .{ .interface = p.interface };
        new_tick.start_time = std.time.timestamp();
        new_tick.update_interval = @intCast(1000 / p.target_fps);
        new_tick.fixed_update_interval = 1.0 / @floatCast(p.fixed_target_fps orelse p.target_fps);
        new_tick.fixed_delta_time = new_tick.fixed_update_interval;
        new_tick.currentTime = getTicks();

        return new_tick;
    }

    pub fn update(self: *@This()) !void {
        const new_time = getTicks();
        const delta_time = new_time - self.current_time;
        self.current_time = new_time;

        // Call the variable timestep update if provided.
        if (@hasDecl(self.interface, "update")) {
            const delta_time_seconds = @floatCast(f32, delta_time) / 1000.0;
            try self.interface.update(delta_time_seconds);
        }

        // Process fixed update logic.
        if (@hasDecl(self.interface, "fixed_update")) {
            self.accumulator += self.fixed_delta_time;
            var stepped: bool = false;
            while (self.accumulator >= self.fixed_update_interval) {
                try self.interface.fixed_update(self.fixed_delta_time);
                self.accumulator -= self.fixed_update_interval;
                stepped = true;
            }
            // If no fixed update was performed, call it at least once.
            if (!stepped) {
                try self.interface.fixed_update(self.fixed_delta_time);
                self.accumulator -= self.fixed_update_interval;
                // Optionally, clamp the accumulator if needed.
                if (self.accumulator < 0.0) {
                    self.accumulator = 0.0;
                }
            }
        }

        // Optionally, add a delay here to maintain your targetFPS.
    }

    /// Returns the number of milliseconds elapsed since the Tick was initialized.
    pub fn getTicks(self: *const Tick) u64 {
        return std.time.milliTimestamp() - self.start_time;
    }
};
