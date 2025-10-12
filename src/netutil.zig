const std = @import("std");
const net = std.net;
const builtin = @import("builtin");
const windows = std.os.windows;

pub fn connectWithTimeoutIPv4(host: []const u8, port: u16, timeout_ms: u32) bool {
    if (builtin.os.tag == .windows) {
        // Minimal Windows implementation: best-effort connect (timeout not enforced yet)
        const address = net.Address.parseIp4(host, port) catch {
            return false;
        };
        var conn = net.tcpConnectToAddress(address) catch {
            return false;
        };
        defer conn.close();
        _ = timeout_ms; // future: enforce timeout using non-blocking mode/IOCP
        return true;
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
