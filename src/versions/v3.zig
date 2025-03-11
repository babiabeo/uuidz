//! https://www.rfc-editor.org/rfc/rfc9562.html#section-5.3

const std = @import("std");

const ns = @import("../namespace.zig");
const UUID = @import("../UUID.zig");

/// Creates a new UUID version 3.
pub fn new(name: []const u8, namespace: UUID) UUID {
    var data: [16]u8 = undefined;
    var hasher = std.crypto.hash.Md5.init(.{});

    hasher.update(&namespace.data);
    hasher.update(name);
    hasher.final(&data);

    data[6] = 0x30 | (data[6] & 0x0f);
    data[8] = 0x80 | (data[8] & 0x3f);

    return UUID{ .data = data };
}

test "v3.new" {
    // https://www.rfc-editor.org/rfc/rfc9562.html#appendix-A.2
    const uuid = new("www.example.com", ns.DNS);

    try std.testing.expectFmt("5df41881-3aed-3515-88a7-2f4a814cf09e", "{s}", .{uuid});
    try std.testing.expectEqual(uuid.version(), UUID.Version.version_3);
    try std.testing.expectEqual(uuid.variant(), UUID.Variant.standard);
}
