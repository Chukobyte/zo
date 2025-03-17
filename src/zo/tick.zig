const std = @import("std");

const TickParams = struct {
    target_fps: u32,
    fixed_target_fps: ?u32 = null,
};

pub const Tick =  struct {
    start_time: u64 = 0,
    current_time: u64 = 0,
    accumulator: f32 = 0.0,
    update_interval: u32 = 0,
    fixed_update_interval: f32 = 0.0,
    fixed_delta_time: f32 = 0.0,

    pub fn init(p: TickParams) @This() {
        var new_tick: @This() = .{};
        new_tick.start_time = @intCast(std.time.timestamp());
        new_tick.update_interval = @intCast(1000 / p.target_fps);
        new_tick.fixed_update_interval = 1.0 / @as(f32, @floatFromInt(p.fixed_target_fps orelse p.target_fps));
        new_tick.fixed_delta_time = new_tick.fixed_update_interval;
        new_tick.current_time = new_tick.getTicks();

        return new_tick;
    }

    /// Updates the tick and will call interface functions 'update' and 'fixed_update'
    pub fn update(self: *@This(), comptime T: type) !void {
        const new_time: u64 = self.getTicks();
        const delta_time: u64 = new_time - self.current_time;
        self.current_time = new_time;

        // Call the variable timestep update if provided.
        if (@hasDecl(T, "update")) {
            const delta_time_float: f32 = @floatFromInt(delta_time);
            const delta_time_seconds: f32 = delta_time_float / 1000.0;
            try T.update(delta_time_seconds);
        }

        // Process fixed update logic.
        if (@hasDecl(T, "fixedUpdate")) {
            self.accumulator += self.fixed_delta_time;
            var stepped: bool = false;
            while (self.accumulator >= self.fixed_update_interval) {
                try T.fixedUpdate(self.fixed_delta_time);
                self.accumulator -= self.fixed_update_interval;
                stepped = true;
            }
            // If no fixed update was performed, call it at least once.
            if (!stepped) {
                try T.fixedUpdate(self.fixed_delta_time);
                self.accumulator -= self.fixed_update_interval;
                // Optionally, clamp the accumulator if needed.
                if (self.accumulator < 0.0) {
                    self.accumulator = 0.0;
                }
            }
        }

        // TODO: Decide if we want to call sleep here to maintain target_fps
    }

    /// Returns the number of milliseconds elapsed since the Tick was initialized.
    pub fn getTicks(self: *const @This()) u64 {
        const timestamp: u64 = @intCast(std.time.milliTimestamp());
        return timestamp - self.start_time;
    }
};
