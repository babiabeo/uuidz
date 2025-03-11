//! https://www.rfc-editor.org/rfc/rfc9562.html#section-5.8

const std = @import("std");
const UUID = @import("../UUID.zig");

/// Creates a new UUID version 8.
pub fn new(custom_a: u48, custom_b: u16, custom_c: u64) UUID {
    var data: [16]u8 = undefined;
    std.mem.writeInt(u48, data[0..6], custom_a, .big);
    std.mem.writeInt(u16, data[6..8], custom_b, .big);
    std.mem.writeInt(u64, data[8..16], custom_c, .big);
    data[6] = 0x80 | (data[6] & 0x0f);
    data[8] = 0x80 | (data[8] & 0x3f);
    return UUID{ .data = data };
}

test "v8.new" {
    // https://www.rfc-editor.org/rfc/rfc9562.html#figure-27
    const custom_a: u48 = 0x2489e9ad2ee2;
    const custom_b: u16 = 0xe00;
    const custom_c: u64 = 0xec932d5f69181c0;

    const uuid = new(custom_a, custom_b, custom_c);

    try std.testing.expectFmt("2489e9ad-2ee2-8e00-8ec9-32d5f69181c0", "{s}", .{uuid});
    try std.testing.expectEqual(uuid.version(), UUID.Version.version_8);
    try std.testing.expectEqual(uuid.variant(), UUID.Variant.standard);
}
