//! https://www.rfc-editor.org/rfc/rfc9562.html#section-5.7

const std = @import("std");
const UUID = @import("../UUID.zig");

/// Creates a new UUID version 7 using the CSPRNG.
pub fn new() UUID {
    return new2(std.crypto.random);
}

/// Creates a new UUID version 7 using a custom PRNG.
pub fn new2(rand: std.Random) UUID {
    var data: [16]u8 = undefined;
    const ts: u64 = @intCast(std.time.milliTimestamp());

    data[0] = @truncate(ts >> 40);
    data[1] = @truncate(ts >> 32);
    data[2] = @truncate(ts >> 24);
    data[3] = @truncate(ts >> 16);
    data[4] = @truncate(ts >> 8);
    data[5] = @truncate(ts);

    rand.bytes(data[6..16]);

    data[6] = 0x70 | (data[6] & 0x0f);
    data[8] = 0x80 | (data[8] & 0x3f);

    return UUID{ .data = data };
}

test "v7.new" {
    var i: u8 = 0;
    while (i < 100) : (i += 1) {
        const uuid = new();

        try std.testing.expectEqual(uuid.version(), UUID.Version.version_7);
        try std.testing.expectEqual(uuid.variant(), UUID.Variant.standard);
    }
}

// TODO
//
// test "v7 monotonicity" {
//     var uid1 = new().toUint();
//     var i: u32 = 0;
//     while (i < 10000) : (i += 1) {
//         const uid2 = new().toUint();
//         try std.testing.expect(uid1 < uid2);
//         uid1 = uid2;
//     }
// }
