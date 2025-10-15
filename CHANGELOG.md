## Changelog

### v0.1.2 - 2025-10-15
- CI: add macOS non-blocking test on PRs (fmt+build) to widen coverage without breaking green
- CI: add off-PR smoke tests (push/dispatch) to prevent PR flakiness
- CI: nightly schedule at 03:17 UTC for broader periodic coverage
- CI: top-level concurrency to cancel redundant in-progress runs per ref
- CI: cache Zig installation across jobs to speed up runs
- Docs: README downloads updated to v0.1.2 with full stable + experimental links

### v0.1.1 - 2025-10-12
- Migrate codebase to Zig 0.16 (nightly, master) std API
- Remove C interop, use std.posix sockets throughout
- Add -Dstatic build option; prefer static linking where supported
- CI: native tests on Ubuntu/macOS with performance smoke tests (<10s)
- CI: cross-build Linux (gnu/musl) stable matrix; experimental Windows + IoT arches
- Release workflow generates multi-target artifacts (static-preferred)
- README: add stable + experimental downloads tables and updated usage/help
