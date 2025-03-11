//! https://www.rfc-editor.org/rfc/rfc9562.html#section-5.5

const std = @import("std");

const ns = @import("../namespace.zig");
const UUID = @import("../UUID.zig");

/// Creates a new UUID version 5.
pub fn new(name: []const u8, namespace: UUID) UUID {
    var data: [20]u8 = undefined;
    var hasher = std.crypto.hash.Sha1.init(.{});

    hasher.update(&namespace.data);
    hasher.update(name);
    hasher.final(&data);

    data[6] = 0x50 | (data[6] & 0x0f);
    data[8] = 0x80 | (data[8] & 0x3f);

    return UUID{ .data = data[0..16].* };
}

test "v3.new" {
    // https://www.rfc-editor.org/rfc/rfc9562.html#appendix-A.4
    const uuid = new("www.example.com", ns.DNS);

    try std.testing.expectFmt("2ed6657d-e927-568b-95e1-2665a8aea6a2", "{s}", .{uuid});
    try std.testing.expectEqual(uuid.version(), UUID.Version.version_5);
    try std.testing.expectEqual(uuid.variant(), UUID.Variant.standard);
}
