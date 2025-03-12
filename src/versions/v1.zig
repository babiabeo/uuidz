//! https://www.rfc-editor.org/rfc/rfc9562.html#section-5.1

const std = @import("std");
const UUID = @import("../UUID.zig");

const G1582_OFF = 122_192_928_000_000_000;

fn getTime() u60 {
    const now = std.time.nanoTimestamp();
    const g1582_100s = @divFloor(now, 100) + G1582_OFF;
    return @intCast(g1582_100s & 0x0fffffffffffffff);
}

/// Creates a new UUID version 1 using the CSPRNG.
pub fn new() UUID {
    return new2(std.crypto.random);
}

/// Creates a new UUID version 1 using a custom PRNG.
pub fn new2(rand: std.Random) UUID {
    var data: [16]u8 = undefined;
    const time = getTime();
    const timeLow: u32 = @truncate(time);
    const timeMid: u16 = @truncate(time >> 32);
    const timeHigh: u16 = 0x1000 | @as(u16, @truncate(time >> 48));

    std.mem.writeInt(u32, data[0..4], timeLow, .big);
    std.mem.writeInt(u16, data[4..6], timeMid, .big);
    std.mem.writeInt(u16, data[6..8], timeHigh, .big);

    rand.bytes(data[8..16]);
    data[8] = 0x80 | (data[8] & 0x3f);

    return UUID{ .data = data };
}

test "v1.new" {
    var i: u8 = 0;
    while (i < 100) : (i += 1) {
        const uuid = new();

        try std.testing.expectEqual(uuid.version(), UUID.Version.version_1);
        try std.testing.expectEqual(uuid.variant(), UUID.Variant.standard);
    }
}
