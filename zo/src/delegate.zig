const std = @import("std");

const FixedArrayList = @import("misc.zig").FixedArrayList;

pub const SubscriberHandle = u32;

const DelegateError = error {
    FailedToSubscribe,
    ReachedSubscriberMax,
};

pub fn Delegate(comptime FunctionT: type) type {
    return struct {
        const Subscriber = struct {
            callback: *const FunctionT,
            handle: SubscriberHandle = 0,
        };

        subscribers: std.ArrayList(Subscriber),
        handle_index: SubscriberHandle = 1,

        /// Initializes delegate, call 'deinit' once completely finished with the delegate
        pub fn init(allocator: std.mem.Allocator) @This() {
            return @This(){
                .subscribers = std.ArrayList(Subscriber).init(allocator),
            };
        }

        /// Deinitializes the delegate
        pub fn deinit(self: *@This()) void {
            self.subscribers.deinit();
        }

        /// Broadcasts the delegate to all subscribers.  Args passed in much match callback function's params.
        pub fn broadcast(self: *@This(), args: anytype) void {
            for (self.subscribers.items) |subscriber| {
                @call(.auto, subscriber.callback, args);
            }
        }

        /// Subscribe to event, use returned 'SubscriberHander' to unsubscribe once finished
        pub fn subscribe(self: *@This(), in_callback: FunctionT) DelegateError!SubscriberHandle {
            const new_handle = self.handle_index;
            defer self.handle_index += 1;
            self.subscribers.append(Subscriber{.callback = in_callback, .handle = new_handle}) catch {
                return DelegateError.FailedToSubscribe;
            };
            return new_handle;
        }

        /// Unsubscribes from an event using the SubscriberHandle
        pub fn unsubscribe(self: *@This(), sub_handle: SubscriberHandle) void {
            var index: usize = 0;
            for (self.subscribers.items) |*sub| {
                if (sub.handle == sub_handle) {
                    _ = self.subscribers.swapRemove(index);
                    break;
                }
                index += 1;
            }
        }

        /// Clears all subscribers
        pub fn clear(self: *@This()) void {
            self.subscribers.clearRetainingCapacity();
        }
    };
}

pub fn FixedDelegate(comptime FunctionT: type, max_subs: comptime_int) type {
    return struct {
        const Subscriber = struct {
            callback: *const FunctionT,
            handle: SubscriberHandle = 0,
        };

        subscribers: [max_subs]Subscriber = undefined,
        count: usize = 0,
        handle_index: SubscriberHandle = 1,

        /// Broadcasts the delegate to all subscribers.  Args passed in much match callback function's params.
        pub fn broadcast(self: *@This(), args: anytype) void {
            for (self.subscribers[0..self.count]) |*subscriber| {
                @call(.auto, subscriber.callback, args);
            }
        }

        pub fn broadcastWithReturn(self: *@This(), args: anytype, comptime ReturnT: type) !FixedArrayList(ReturnT, max_subs) {
            var return_values = FixedArrayList(ReturnT, max_subs).init();
            for (self.subscribers[0..self.count]) |*subscriber| {
                const value = @call(.auto, subscriber.callback, args);
                try return_values.append(value);
            }
            return return_values;
        }

        /// Subscribe to event, use returned 'SubscriberHander' to unsubscribe once finished
        pub fn subscribe(self: *@This(), in_callback: FunctionT) DelegateError!SubscriberHandle {
            if (self.count >= max_subs) { return DelegateError.ReachedSubscriberMax; }

            const new_handle = self.handle_index;
            defer self.handle_index += 1;
            self.subscribers[self.count] = .{
                .callback = in_callback,
                .handle = new_handle,
            };
            self.count += 1;
            return new_handle;
        }

        /// Unsubscribes from an event using the SubscriberHandle
        pub fn unsubscribe(self: *@This(), sub_handle: SubscriberHandle) void {
            for (0..self.count) |i| {
                if (self.subscribers[i].handle == sub_handle) {
                    // Swap remove
                    self.subscribers[i] = self.subscribers[self.count - 1];
                    self.count -= 1;
                    break;
                }
            }
        }

        /// Clears all subscribers
        pub fn clear(self: *@This()) void {
            self.count = 0;
        }
    };
}
