## Changelog

### v0.1.1 - 2025-10-12
- Migrate codebase to Zig 0.16 (nightly, master) std API
- Remove C interop, use std.posix sockets throughout
- Add -Dstatic build option; prefer static linking where supported
- CI: native tests on Ubuntu/macOS with performance smoke tests (<10s)
- CI: cross-build Linux (gnu/musl) stable matrix; experimental Windows + IoT arches
- Release workflow generates multi-target artifacts (static-preferred)
- README: add stable + experimental downloads tables and updated usage/help
