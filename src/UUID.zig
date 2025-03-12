//! Represents an Universally Unique IDentifier (UUID), also known as Globally Unique IDentifier (GUID).
//! A UUID is 128 bits long (16 bytes) and requires no central registration process.
//!
//! Based on [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562.html) (obsoletes RFC 4122).

const std = @import("std");
const mem = std.mem;
const testing = std.testing;

const UUID = @This();

pub const Version = enum(u4) {
    invalid,
    version_1,
    version_2,
    version_3,
    version_4,
    version_5,
    version_6,
    version_7,
    version_8,
};

pub const Variant = enum {
    // Reserved. Network Computing System (NCS) backward compatibility
    reserved,
    // Defined in RFC 9562.
    standard,
    // Reserved. Microsoft Corporation backward compatibility.
    microsoft,
    // Reserved for future definition.
    future,
};

data: [16]u8,

/// Creates a new UUID from an unsigned 128-bit integer.
pub fn fromUint(uint: u128) UUID {
    var data: [16]u8 = undefined;
    mem.writeInt(u128, &data, uint, .big);
    return UUID{ .data = data };
}

/// Converts an UUID to an unsigned 128-bit integer.
pub fn toUint(self: *const UUID) u128 {
    return mem.readInt(u128, &self.data, .big);
}

/// Returns the version of the UUID.
pub fn version(self: *const UUID) Version {
    const ver = (self.data[6] >> 4) & 0xf;
    if (ver < 1 or ver > 8)
        return Version.invalid;

    return @enumFromInt(ver);
}

/// Returns the variant of the UUID.
pub fn variant(self: *const UUID) Variant {
    const vari = self.data[8];

    if ((vari & 0xc0) == 0x80) {
        return Variant.standard;
    } else if ((vari & 0xe0) == 0xc0) {
        return Variant.microsoft;
    } else if ((vari & 0xe0) == 0xe0) {
        return Variant.future;
    } else {
        return Variant.reserved;
    }
}

/// Encodes an UUID into one of these formats:
/// - s: output uuid in standard form `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (all letters are lowercase).
/// - S: output uuid in standard form `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (all letters are uppercase).
/// - b: output uuid in form `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` (a.k.a Microsoft style).
/// - u: output uuid in URN form `urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.
/// - d: output uuid as an u128 integer.
/// - x: same as s.
/// - X: same as S.
pub fn format(
    self: *const UUID,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = options;

    const set_1 = mem.readInt(u32, self.data[0..4], .big);
    const set_2 = mem.readInt(u16, self.data[4..6], .big);
    const set_3 = mem.readInt(u16, self.data[6..8], .big);
    const set_4 = mem.readInt(u16, self.data[8..10], .big);
    const set_5 = mem.readInt(u48, self.data[10..16], .big);

    if (mem.eql(u8, fmt, "s") or mem.eql(u8, fmt, "x")) {
        try std.fmt.format(writer, "{x:0>8}-{x:0>4}-{x:0>4}-{x:0>4}-{x:0>12}", .{
            set_1,
            set_2,
            set_3,
            set_4,
            set_5,
        });
    } else if (mem.eql(u8, fmt, "S") or mem.eql(u8, fmt, "X")) {
        try std.fmt.format(writer, "{X:0>8}-{X:0>4}-{X:0>4}-{X:0>4}-{X:0>12}", .{
            set_1,
            set_2,
            set_3,
            set_4,
            set_5,
        });
    } else if (mem.eql(u8, fmt, "u")) {
        try std.fmt.format(writer, "urn:uuid:{x:0>8}-{x:0>4}-{x:0>4}-{x:0>4}-{x:0>12}", .{
            set_1,
            set_2,
            set_3,
            set_4,
            set_5,
        });
    } else if (mem.eql(u8, fmt, "b")) {
        try std.fmt.format(writer, "{{{x:0>8}-{x:0>4}-{x:0>4}-{x:0>4}-{x:0>12}}}", .{
            set_1,
            set_2,
            set_3,
            set_4,
            set_5,
        });
    } else if (mem.eql(u8, fmt, "d")) {
        try std.fmt.format(writer, "{d}", .{self.toUint()});
    } else {
        try std.fmt.format(writer, "{any}", .{&self.data});
    }
}

/// Decodes a string into an UUID. Supported forms:
///
/// - Standard forms (defined in RFC 9562):
///   - xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
///   - urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
/// - Non-standard forms:
///   - {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx} (Microsoft's curly braced style)
///
/// Returns errors if the form is unsupported or the length is less than 36.
pub fn parse(buf: []const u8) !UUID {
    if (buf.len < 36) return error.InvalidForm;

    const b = switch (buf.len) {
        // xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        36 => buf[0..36],
        // {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}
        38 => buf[1..37],
        // urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        45 => blk: {
            if (!mem.startsWith(u8, buf, "urn:uuid:")) {
                return error.InvalidPrefix;
            }
            break :blk buf[9..45];
        },
        // invalid or unsupported forms
        else => return error.InvalidForm,
    };

    if (b[8] != '-' or b[13] != '-' or b[18] != '-' or b[23] != '-') {
        return error.InvalidForm;
    }

    var uuid: [16]u8 = undefined;

    const set_1 = try std.fmt.parseInt(u32, b[0..8], 16);
    const set_2 = try std.fmt.parseInt(u16, b[9..13], 16);
    const set_3 = try std.fmt.parseInt(u16, b[14..18], 16);
    const set_4 = try std.fmt.parseInt(u16, b[19..23], 16);
    const set_5 = try std.fmt.parseInt(u48, b[24..36], 16);

    mem.writeInt(u32, uuid[0..4], set_1, .big);
    mem.writeInt(u16, uuid[4..6], set_2, .big);
    mem.writeInt(u16, uuid[6..8], set_3, .big);
    mem.writeInt(u16, uuid[8..10], set_4, .big);
    mem.writeInt(u48, uuid[10..16], set_5, .big);

    return UUID{ .data = uuid };
}

test "UUID.fromUint" {
    const uint: u128 = 0xf81d4fae7dec11d0a76500a0c91e6bf6;
    const uuid = UUID.fromUint(uint);

    try testing.expectFmt("f81d4fae-7dec-11d0-a765-00a0c91e6bf6", "{s}", .{uuid});
    try testing.expectFmt("f81d4fae-7dec-11d0-a765-00a0c91e6bf6", "{x}", .{uuid});
    try testing.expectFmt("F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6", "{S}", .{uuid});
    try testing.expectFmt("F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6", "{X}", .{uuid});
    try testing.expectFmt("urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6", "{u}", .{uuid});
    try testing.expectFmt("{f81d4fae-7dec-11d0-a765-00a0c91e6bf6}", "{b}", .{uuid});
    try testing.expectFmt("329800735698586629295641978511506172918", "{d}", .{uuid});
}

test "UUID.toUint" {
    const uuid = try UUID.parse("f81d4fae-7dec-11d0-a765-00a0c91e6bf6");
    try testing.expectEqual(0xf81d4fae7dec11d0a76500a0c91e6bf6, uuid.toUint());
}

test "UUID.version" {
    const uuid = try UUID.parse("f81d4fae-7dec-11d0-a765-00a0c91e6bf6");
    try testing.expectEqual(Version.version_1, uuid.version());
}

test "UUID.variant" {
    const uuid = try UUID.parse("f81d4fae-7dec-11d0-a765-00a0c91e6bf6");
    try testing.expectEqual(Variant.standard, uuid.variant());
}

test "UUID.parse" {
    const uuid1 = "f81d4fae-7dec-11d0-a765-00a0c91e6bf6";
    const uuid2 = "urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6";
    const uuid3 = "{f81d4fae-7dec-11d0-a765-00a0c91e6bf6}";

    const expected = UUID.fromUint(0xf81d4fae7dec11d0a76500a0c91e6bf6);

    try testing.expectEqual(expected, try UUID.parse(uuid1));
    try testing.expectEqual(expected, try UUID.parse(uuid2));
    try testing.expectEqual(expected, try UUID.parse(uuid3));
}
