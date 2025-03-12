const std = @import("std");
const uuidz = @import("uuidz");

pub fn main() !void {
    const idv1 = uuidz.v1.new();
    const idv3 = uuidz.v3.new("www.example.com", uuidz.ns.URL);
    const idv4 = uuidz.v4.new();
    const idv5 = uuidz.v5.new("www.example.com", uuidz.ns.URL);
    const idv6 = uuidz.v6.new();
    const idv7 = uuidz.v7.new();

    const rand = std.crypto.random;
    const idv8 = uuidz.v8.new(rand.int(u48), rand.int(u16), rand.int(u64));

    const stdout = std.io.getStdOut().writer();

    try std.fmt.format(stdout, "{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n", .{
        idv1, idv3, idv4, idv5, idv6, idv7, idv8,
    });
}
