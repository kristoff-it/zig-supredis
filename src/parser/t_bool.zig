const builtin = @import("builtin");
const std = @import("std");
const fmt = std.fmt;
const testing = std.testing;

pub const BoolParser = struct {
    pub fn isSupported(comptime T: type) bool {
        return switch (@typeInfo(T)) {
            .Bool, .Int, .Float => true,
            else => false,
        };
    }

    pub fn parse(comptime T: type, comptime _: type, msg: var) !T {
        const ch = try msg.readByte();
        try msg.skipBytes(2);
        return switch (@typeInfo(T)) {
            else => unreachable,
            .Bool => ch == 't',
            .Int, .Float => if (ch == 't') @as(T, 1) else @as(T, 0),
        };
    }

    pub fn isSupportedAlloc(comptime T: type) bool {
        return isSupported(T);
    }

    pub fn parseAlloc(comptime T: type, comptime _: type, allocator: *std.mem.Allocator, msg: var) !T {
        return parse(T, struct {}, msg);
    }
};

test "parses bools" {
    testing.expect(true == try BoolParser.parse(bool, struct {}, TrueMSG().inStream()));
    testing.expect(false == try BoolParser.parse(bool, struct {}, FalseMSG().inStream()));
    testing.expect(1 == try BoolParser.parse(i64, struct {}, TrueMSG().inStream()));
    testing.expect(0 == try BoolParser.parse(u32, struct {}, FalseMSG().inStream()));
    testing.expect(1.0 == try BoolParser.parse(f32, struct {}, TrueMSG().inStream()));
    testing.expect(0.0 == try BoolParser.parse(f64, struct {}, FalseMSG().inStream()));
}

fn TrueMSG() std.io.FixedBufferStream([]const u8) {
    return std.io.fixedBufferStream("#t\r\n"[1..]);
}

fn FalseMSG() std.io.FixedBufferStream([]const u8) {
    return std.io.fixedBufferStream("#f\r\n"[1..]);
}
