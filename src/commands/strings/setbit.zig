// SETBIT key offset value
const Value = @import("../_common_utils.zig").Value;

pub const SETBIT = struct {
    key: []const u8,
    offset: usize,
    value: Value,

    pub fn init(key: []const u8, offset: usize, value: var) SETBIT {
        return .{ .key = key, .offset = offset, .value = Value.fromVar(value) };
    }

    pub fn validate(self: SETBIT) !void {
        if (self.key.len == 0) return error.EmptyKeyName;
    }

    pub const RedisCommand = struct {
        pub fn serialize(self: SETBIT, comptime rootSerializer: type, msg: var) !void {
            return rootSerializer.serializeCommand(msg, .{ "SETBIT", self.key, self.offset, self.value });
        }
    };
};

test "basic usage" {
    const cmd = SETBIT.init("lol", 100, "banana");
}

test "serializer" {
    const std = @import("std");
    const serializer = @import("../../serializer.zig").CommandSerializer;

    var correctBuf: [1000]u8 = undefined;
    var correctMsg = std.io.SliceOutStream.init(correctBuf[0..]);

    var testBuf: [1000]u8 = undefined;
    var testMsg = std.io.SliceOutStream.init(testBuf[0..]);

    {
        correctMsg.reset();
        testMsg.reset();

        try serializer.serializeCommand(
            &testMsg.stream,
            SETBIT.init("mykey", 1, 99),
        );
        try serializer.serializeCommand(
            &correctMsg.stream,
            .{ "SETBIT", "mykey", 1, 99 },
        );

        std.testing.expectEqualSlices(u8, correctMsg.getWritten(), testMsg.getWritten());
    }
}
