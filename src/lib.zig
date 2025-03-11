const std = @import("std");

/// Represents a 128-bit Universally Unique Identifier (UUID).
pub const UUID = @import("UUID.zig");

/// The Nil UUID is special form of UUID that is specified to have all 128 bits set to 0.
pub const NIL_UUID = UUID{ .data = [_]u8{0x00} ** 16 };
/// The Max UUID is a special form of UUID that is specified to have all 128 bits set to 1.
/// This UUID can be thought of as the inverse of [`NIL_UUID`].
pub const MAX_UUID = UUID{ .data = [_]u8{0xff} ** 16 };

pub const ns = @import("namespace.zig");

pub const v1 = @import("versions/v1.zig");
pub const v3 = @import("versions/v3.zig");
pub const v4 = @import("versions/v4.zig");
pub const v5 = @import("versions/v5.zig");
pub const v6 = @import("versions/v6.zig");
pub const v7 = @import("versions/v7.zig");
pub const v8 = @import("versions/v8.zig");

test {
    std.testing.refAllDecls(@This());
}

test "nil uuid and max uuid" {
    try std.testing.expectFmt("00000000-0000-0000-0000-000000000000", "{s}", .{NIL_UUID});
    try std.testing.expectFmt("ffffffff-ffff-ffff-ffff-ffffffffffff", "{s}", .{MAX_UUID});
}
