//! https://www.rfc-editor.org/rfc/rfc9562.html#section-5.4

const std = @import("std");
const UUID = @import("../UUID.zig");

/// Creates a new UUID version 4 using the CSPRNG.
pub fn new() UUID {
    return new2(std.crypto.random);
}

/// Creates a new UUID version 4 using a custom PRNG.
pub fn new2(rand: std.Random) UUID {
    var data: [16]u8 = undefined;
    rand.bytes(&data);
    data[6] = 0x40 | (data[6] & 0x0f);
    data[8] = 0x80 | (data[8] & 0x3f);
    return UUID{ .data = data };
}

test "v4.new" {
    var i: u8 = 0;
    while (i < 100) : (i += 1) {
        const uuid = new();

        try std.testing.expectEqual(uuid.version(), UUID.Version.version_4);
        try std.testing.expectEqual(uuid.variant(), UUID.Variant.standard);
    }
}
