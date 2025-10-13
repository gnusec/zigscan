const std = @import("std");
const net = std.net;
const builtin = @import("builtin");
const windows = std.os.windows;
const wsa = windows.ws2_32;
const mem = std.mem;

// Failure stats (global, atomic) for optional adaptive logging
var g_fail_timeout: u64 = 0;
var g_fail_refused: u64 = 0;
var g_fail_other: u64 = 0;

inline fn inc_timeout() void {
    _ = @atomicRmw(u64, &g_fail_timeout, .Add, 1, .seq_cst);
}
inline fn inc_refused() void {
    _ = @atomicRmw(u64, &g_fail_refused, .Add, 1, .seq_cst);
}
inline fn inc_other() void {
    _ = @atomicRmw(u64, &g_fail_other, .Add, 1, .seq_cst);
}

pub const FailureStats = struct { timeout: u64, refused: u64, other: u64 };

pub fn resetFailureStats() void {
    @atomicStore(u64, &g_fail_timeout, 0, .seq_cst);
    @atomicStore(u64, &g_fail_refused, 0, .seq_cst);
    @atomicStore(u64, &g_fail_other, 0, .seq_cst);
}

pub fn snapshotFailureStats() FailureStats {
    return .{
        .timeout = @atomicLoad(u64, &g_fail_timeout, .seq_cst),
        .refused = @atomicLoad(u64, &g_fail_refused, .seq_cst),
        .other = @atomicLoad(u64, &g_fail_other, .seq_cst),
    };
}

pub fn connectWithTimeoutIPv4(host: []const u8, port: u16, timeout_ms: u32) bool {
    if (builtin.os.tag == .windows) {
        // Windows: non-blocking connect with timeout using WSAPoll
        const address = net.Address.parseIp4(host, port) catch {
            return false;
        };

        const s = wsa.socket(wsa.AF_INET, wsa.SOCK_STREAM, wsa.IPPROTO_TCP);
        if (s == wsa.INVALID_SOCKET) { inc_other(); return false; }
        defer _ = wsa.closesocket(s);

        var nonblock: wsa.u_long = 1;
        if (wsa.ioctlsocket(s, wsa.FIONBIO, &nonblock) == wsa.SOCKET_ERROR) { inc_other(); return false; }

        const sa: *const wsa.sockaddr = @ptrCast(&address.in);
        const sa_len: c_int = @intCast(@sizeOf(@TypeOf(address.in)));
        const cres = wsa.connect(s, sa, sa_len);
        if (cres == wsa.SOCKET_ERROR) {
            const err = wsa.WSAGetLastError();
            switch (err) {
                wsa.WSAEWOULDBLOCK, wsa.WSAEINPROGRESS, wsa.WSAEALREADY => {},
                wsa.WSAECONNREFUSED => { inc_refused(); return false; },
                wsa.WSAETIMEDOUT => { inc_timeout(); return false; },
                else => { inc_other(); return false; },
            }
        } else {
            return true;
        }

        var pfd: wsa.pollfd = .{ .fd = s, .events = wsa.POLLOUT, .revents = 0 };
        const n = wsa.WSAPoll(&pfd, 1, @as(c_int, @intCast(timeout_ms)));
        if (n <= 0) { if (n == 0) inc_timeout() else inc_other(); return false; } // timeout or error

        var soerr: c_int = 0;
        var optlen: c_int = @intCast(@sizeOf(c_int));
        if (wsa.getsockopt(s, wsa.SOL_SOCKET, wsa.SO_ERROR, @ptrCast(&soerr), &optlen) == wsa.SOCKET_ERROR) { inc_other(); return false; }
        if (soerr == 0) return true;
        if (soerr == wsa.WSAECONNREFUSED) { inc_refused(); return false; }
        if (soerr == wsa.WSAETIMEDOUT) { inc_timeout(); return false; }
        inc_other();
        return false;
    } else {
        return connectWithTimeoutIPv4Posix(host, port, timeout_ms);
    }
}

fn connectWithTimeoutIPv4Posix(host: []const u8, port: u16, timeout_ms: u32) bool {
    const posix = std.posix;

    const address = net.Address.parseIp4(host, port) catch {
        inc_other();
        return false;
    };

    const fd = posix.socket(posix.AF.INET, posix.SOCK.STREAM | posix.SOCK.CLOEXEC | posix.SOCK.NONBLOCK, 0) catch {
        inc_other();
        return false;
    };
    defer posix.close(fd);

    const addr_ptr: *const posix.sockaddr = @ptrCast(&address.in);
    const addr_len: posix.socklen_t = @sizeOf(@TypeOf(address.in));
    var need_poll = false;
    posix.connect(fd, addr_ptr, addr_len) catch |err| switch (err) {
        error.WouldBlock, error.ConnectionPending => {
            need_poll = true;
        },
        else => { inc_other(); return false; },
    };
    if (!need_poll) return true;

    var fds = [_]posix.pollfd{.{ .fd = fd, .events = posix.POLL.OUT, .revents = 0 }};
    const n = posix.poll(fds[0..], @as(i32, @intCast(timeout_ms))) catch { inc_other(); return false; };
    if (n == 0) { inc_timeout(); return false; }

    var err_code: c_int = 0;
    posix.getsockopt(fd, posix.SOL.SOCKET, posix.SO.ERROR, std.mem.asBytes(&err_code)) catch { inc_other(); return false; };
    if (err_code == 0) return true;
    if (err_code == @intFromEnum(posix.E.CONNREFUSED)) { inc_refused(); return false; }
    if (err_code == @intFromEnum(posix.E.TIMEDOUT)) { inc_timeout(); return false; }
    inc_other();
    return false;
}
