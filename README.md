# uuidz

A Zig package for generating and parsing UUIDs based on [RFC 9562][rfc].

## Installation

First, to add `uuidz` package to your `build.zig.zon`, run:

```sh
zig fetch --save git+https://github.com/babiabeo/uuidz.git#main
```

Then, in `build.zig`, add `uuidz` as a dependency to your program:

```zig
// ...
const uuidz = b.dependency("uuidz", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("uuidz", pg.module("uuidz"));
// ...
```

That's it! Now you can start your journey with `uuidz` :)

## Usage

### Generating

`uuidz` supports generating all versions defined in RFC 9562 (except version 2).

```zig
const uuidz = @import("uuidz");

pub fn main() void {
    _ = uuidz.v1.new(); // Version 1
    _ = uuidz.v3.new(); // Version 3
    _ = uuidz.v4.new(); // Version 4
    _ = uuidz.v5.new(); // Version 5
    _ = uuidz.v6.new(); // Version 6
    _ = uuidz.v7.new(); // Version 7
    _ = uuidz.v8.new(); // Version 8
}
```

There is also `uuidz.ns` which is a collection of pre-defined namespace IDs as
provided in RFC. These namespaces are usually used when creating uuid version 3
or 5.

```zig
_ = uuidz.ns.DNS;
_ = uuidz.ns.URL;
_ = uuidz.ns.OID;
_ = uuidz.ns.X500;
```

### Parsing

`uuidz.UUID.parse` allows you to parse an uuid from a string. Only one of these
formats are supported:

- `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (Standard form)
- `urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (URN form)
- `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` (Microsoft's curly braced style)

## License

[MIT](./LICENSE)

[rfc]: https://www.rfc-editor.org/rfc/rfc9562.html
