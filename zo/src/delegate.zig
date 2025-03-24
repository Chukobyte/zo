const std = @import("std");

pub const SubscriberHandle = u32;

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
        pub fn subscribe(self: *@This(), in_callback: FunctionT) SubscriberHandle {
            const new_handle = self.handle_index;
            defer self.handle_index += 1;
            self.subscribers.append(Subscriber{.callback = in_callback, .handle = new_handle}) catch {
                std.debug.print("Error adding sub!\n", .{});
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
        pub fn clearAndFree(self: *@This()) void {
            self.subscribers.clearAndFree();
        }
    };
}
