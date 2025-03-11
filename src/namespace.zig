//! Collection of some pre-defined namespace IDs as defined in RFC 9562.
//! https://www.rfc-editor.org/rfc/rfc9562.html#section-6.6

const std = @import("std");
const UUID = @import("UUID.zig");

pub const DNS = UUID.fromUint(0x6ba7b8109dad11d180b400c04fd430c8);
pub const URL = UUID.fromUint(0x6ba7b8119dad11d180b400c04fd430c8);
pub const OID = UUID.fromUint(0x6ba7b8129dad11d180b400c04fd430c8);
pub const X500 = UUID.fromUint(0x6ba7b8149dad11d180b400c04fd430c8);

test "namespaces" {
    try std.testing.expectFmt("6ba7b810-9dad-11d1-80b4-00c04fd430c8", "{s}", .{DNS});
    try std.testing.expectFmt("6ba7b811-9dad-11d1-80b4-00c04fd430c8", "{s}", .{URL});
    try std.testing.expectFmt("6ba7b812-9dad-11d1-80b4-00c04fd430c8", "{s}", .{OID});
    try std.testing.expectFmt("6ba7b814-9dad-11d1-80b4-00c04fd430c8", "{s}", .{X500});
}
