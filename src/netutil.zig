const std = @import("std");
const net = std.net;
const builtin = @import("builtin");
const windows = std.os.windows;
const wsa = windows.ws2_32;

pub fn connectWithTimeoutIPv4(host: []const u8, port: u16, timeout_ms: u32) bool {
    if (builtin.os.tag == .windows) {
        // Windows: non-blocking connect with timeout using WSAPoll
        const address = net.Address.parseIp4(host, port) catch {
            return false;
        };

        const s = wsa.socket(wsa.AF_INET, wsa.SOCK_STREAM, wsa.IPPROTO_TCP);
        if (s == wsa.INVALID_SOCKET) return false;
        defer _ = wsa.closesocket(s);

        var nonblock: wsa.u_long = 1;
        if (wsa.ioctlsocket(s, wsa.FIONBIO, &nonblock) == wsa.SOCKET_ERROR) return false;

        const sa: *const wsa.sockaddr = @ptrCast(&address.in);
        const sa_len: c_int = @intCast(@sizeOf(@TypeOf(address.in)));
        const cres = wsa.connect(s, sa, sa_len);
        if (cres == wsa.SOCKET_ERROR) {
            const err = wsa.WSAGetLastError();
            switch (err) {
                wsa.WSAEWOULDBLOCK, wsa.WSAEINPROGRESS, wsa.WSAEALREADY => {},
                else => return false,
            }
        } else {
            return true;
        }

        var pfd: wsa.pollfd = .{ .fd = s, .events = wsa.POLLOUT, .revents = 0 };
        const n = wsa.WSAPoll(&pfd, 1, @as(c_int, @intCast(timeout_ms)));
        if (n <= 0) return false; // timeout or error

        var soerr: c_int = 0;
        var optlen: c_int = @intCast(@sizeOf(c_int));
        if (wsa.getsockopt(s, wsa.SOL_SOCKET, wsa.SO_ERROR, @ptrCast(&soerr), &optlen) == wsa.SOCKET_ERROR) return false;
        return soerr == 0;
    } else {
        return connectWithTimeoutIPv4Posix(host, port, timeout_ms);
    }
}

fn connectWithTimeoutIPv4Posix(host: []const u8, port: u16, timeout_ms: u32) bool {
    const posix = std.posix;

    const address = net.Address.parseIp4(host, port) catch {
        return false;
    };

    const fd = posix.socket(posix.AF.INET, posix.SOCK.STREAM | posix.SOCK.CLOEXEC | posix.SOCK.NONBLOCK, 0) catch {
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
        else => return false,
    };
    if (!need_poll) return true;

    var fds = [_]posix.pollfd{.{ .fd = fd, .events = posix.POLL.OUT, .revents = 0 }};
    const n = posix.poll(fds[0..], @as(i32, @intCast(timeout_ms))) catch return false;
    if (n == 0) return false;

    var err_code: c_int = 0;
    posix.getsockopt(fd, posix.SOL.SOCKET, posix.SO.ERROR, std.mem.asBytes(&err_code)) catch return false;
    return err_code == 0;
}
