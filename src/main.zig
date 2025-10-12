const std = @import("std");
const net = std.net;
const os = std.os;
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Version = "1.0.0";

const ScanResult = struct {
    host: []const u8,
    port: u16,
    open: bool,
};

const Config = struct {
    target: ?[]const u8 = null,
    targets_file: ?[]const u8 = null,
    ports: ?[]const u8 = null,
    port_range: ?[]const u8 = null,
    concurrency: u32 = 500,
    timeout_ms: u32 = 1000,
    output_json: bool = false,
    output_txt: bool = false,
    output_file: ?[]const u8 = null,
};

fn printHelp() void {
    const help =
        \\ZigScan - High-performance Port Scanner
        \\Version: {s}
        \\
        \\Usage: zigscan [options]
        \\
        \\Options:
        \\  -h, --help              Show this help message
        \\  -t, --target <IP>       Target IP address or hostname (required)
        \\  -T, --targets <file>    File containing list of target IPs
        \\  -p, --ports <ports>     Port list (e.g., 80,443,8080)
        \\  -r, --range <range>     Port range (e.g., 1-1000)
        \\  -c, --concurrency <n>   Number of concurrent connections (default: 500)
        \\  --timeout <ms>          Connection timeout in milliseconds (default: 1000)
        \\  --json                  Output results in JSON format
        \\  --txt                   Output results in TXT format
        \\  -o, --output <file>     Output file path
        \\
        \\Examples:
        \\  zigscan -t 192.168.1.1 -p 80,443,8080
        \\  zigscan -t 103.235.46.115 -r 1-1000 -c 100
        \\  zigscan -t scanme.nmap.org -p 22,80,443 --json -o results.json
        \\
    ;
    std.debug.print(help, .{Version});
}

fn parsePortList(allocator: Allocator, port_str: []const u8) !ArrayList(u16) {
    var ports = ArrayList(u16).init(allocator);
    errdefer ports.deinit();

    var iter = mem.split(u8, port_str, ",");
    while (iter.next()) |port_part| {
        const trimmed = mem.trim(u8, port_part, " \t\r\n");
        if (trimmed.len == 0) continue;

        const port = try fmt.parseInt(u16, trimmed, 10);
        try ports.append(port);
    }

    return ports;
}

fn parsePortRange(allocator: Allocator, range_str: []const u8) !ArrayList(u16) {
    var ports = ArrayList(u16).init(allocator);
    errdefer ports.deinit();

    var iter = mem.split(u8, range_str, "-");
    const start_str = iter.next() orelse return error.InvalidRange;
    const end_str = iter.next() orelse return error.InvalidRange;

    const start = try fmt.parseInt(u16, mem.trim(u8, start_str, " \t\r\n"), 10);
    const end = try fmt.parseInt(u16, mem.trim(u8, end_str, " \t\r\n"), 10);

    if (start > end) return error.InvalidRange;

    var port = start;
    while (port <= end) : (port += 1) {
        try ports.append(port);
    }

    return ports;
}

fn scanPort(host: []const u8, port: u16, timeout_ms: u32) bool {
    const builtin = @import("builtin");
    const is_windows = builtin.os.tag == .windows;

    if (is_windows) {
        return scanPortWindows(host, port, timeout_ms);
    } else {
        return scanPortUnix(host, port, timeout_ms);
    }
}

fn scanPortUnix(host: []const u8, port: u16, timeout_ms: u32) bool {
    const C = @cImport({
        @cInclude("sys/socket.h");
        @cInclude("netinet/in.h");
        @cInclude("arpa/inet.h");
        @cInclude("unistd.h");
        @cInclude("fcntl.h");
        @cInclude("errno.h");
        @cInclude("poll.h");
    });

    // Parse the address
    const address = net.Address.parseIp4(host, port) catch {
        return false;
    };

    // Create socket
    const sockfd = C.socket(C.AF_INET, C.SOCK_STREAM, 0);
    if (sockfd < 0) {
        return false;
    }
    defer _ = C.close(sockfd);

    // Set non-blocking
    const flags = C.fcntl(sockfd, C.F_GETFL, @as(c_int, 0));
    _ = C.fcntl(sockfd, C.F_SETFL, flags | C.O_NONBLOCK);

    // Attempt connection
    const addr_ptr: *const C.sockaddr = @ptrCast(&address.in);
    const result = C.connect(sockfd, addr_ptr, @sizeOf(C.sockaddr_in));

    if (result == 0) {
        return true; // Connected immediately
    }

    // Cross-platform errno access
    const builtin = @import("builtin");
    const errno_val = if (builtin.os.tag == .linux)
        C.__errno_location().*
    else if (builtin.os.tag == .macos or builtin.os.tag == .ios)
        C.__error().*
    else
        C.errno;

    if (errno_val != C.EINPROGRESS) {
        return false;
    }

    // Wait for connection with timeout using poll
    var pfd = C.pollfd{
        .fd = sockfd,
        .events = C.POLLOUT,
        .revents = 0,
    };

    const poll_result = C.poll(&pfd, 1, @as(c_int, @intCast(timeout_ms)));

    if (poll_result <= 0) {
        return false; // Timeout or error
    }

    // Check if connection succeeded
    if (pfd.revents & C.POLLOUT != 0) {
        var err_code: c_int = 0;
        var err_len: C.socklen_t = @sizeOf(c_int);
        _ = C.getsockopt(sockfd, C.SOL_SOCKET, C.SO_ERROR, @ptrCast(&err_code), &err_len);
        return err_code == 0;
    }

    return false;
}

fn scanPortWindows(host: []const u8, port: u16, timeout_ms: u32) bool {
    const C = @cImport({
        @cInclude("winsock2.h");
        @cInclude("ws2tcpip.h");
    });

    // Parse the address
    _ = net.Address.parseIp4(host, port) catch {
        return false;
    };

    // Create socket
    const sockfd = C.socket(C.AF_INET, C.SOCK_STREAM, C.IPPROTO_TCP);
    if (sockfd == C.INVALID_SOCKET) {
        return false;
    }
    defer _ = C.closesocket(sockfd);

    // Set non-blocking
    var mode: c_ulong = 1;
    _ = C.ioctlsocket(sockfd, C.FIONBIO, &mode);

    // Attempt connection
    var addr: C.sockaddr_in = undefined;
    addr.sin_family = C.AF_INET;
    addr.sin_port = C.htons(port);
    addr.sin_addr.s_addr = C.inet_addr(host.ptr);

    const result = C.connect(sockfd, @ptrCast(&addr), @sizeOf(C.sockaddr_in));

    if (result == 0) {
        return true; // Connected immediately
    }

    // Check if connection is in progress
    if (C.WSAGetLastError() != C.WSAEWOULDBLOCK) {
        return false;
    }

    // Use select for timeout
    var timeout = C.timeval{
        .tv_sec = @intCast(timeout_ms / 1000),
        .tv_usec = @intCast((timeout_ms % 1000) * 1000),
    };

    var write_fds: C.fd_set = undefined;
    C.FD_ZERO(&write_fds);
    C.FD_SET(sockfd, &write_fds);

    const select_result = C.select(0, null, &write_fds, null, &timeout);

    if (select_result <= 0) {
        return false; // Timeout or error
    }

    // Check if connection succeeded
    if (C.FD_ISSET(sockfd, &write_fds) != 0) {
        var err_code: c_int = 0;
        var err_len: c_int = @sizeOf(c_int);
        _ = C.getsockopt(sockfd, C.SOL_SOCKET, C.SO_ERROR, @ptrCast(&err_code), &err_len);
        return err_code == 0;
    }

    return false;
}

const ScanTask = struct {
    host: []const u8,
    port: u16,
    timeout_ms: u32,
};

const ScanWorker = struct {
    allocator: Allocator,
    task_queue: *ArrayList(ScanTask),
    results: *ArrayList(ScanResult),
    mutex: *std.Thread.Mutex,
    task_mutex: *std.Thread.Mutex,

    fn run(self: *ScanWorker) void {
        while (true) {
            self.task_mutex.lock();

            if (self.task_queue.items.len == 0) {
                self.task_mutex.unlock();
                break;
            }

            const task = self.task_queue.pop();
            self.task_mutex.unlock();

            const is_open = scanPort(task.host, task.port, task.timeout_ms);

            self.mutex.lock();
            defer self.mutex.unlock();

            self.results.append(ScanResult{
                .host = task.host,
                .port = task.port,
                .open = is_open,
            }) catch {};
        }
    }
};

fn scanConcurrent(allocator: Allocator, host: []const u8, ports: []const u16, config: Config) !ArrayList(ScanResult) {
    var results = ArrayList(ScanResult).init(allocator);
    var task_queue = ArrayList(ScanTask).init(allocator);
    defer task_queue.deinit();

    // Create task queue
    for (ports) |port| {
        try task_queue.append(ScanTask{
            .host = host,
            .port = port,
            .timeout_ms = config.timeout_ms,
        });
    }

    // Create mutex for thread synchronization
    var mutex = std.Thread.Mutex{};
    var task_mutex = std.Thread.Mutex{};

    // Create worker threads
    const num_workers = @min(config.concurrency, ports.len);
    const threads = try allocator.alloc(std.Thread, num_workers);
    defer allocator.free(threads);

    // Note: worker is declared as var (not const) because we pass a mutable pointer to threads
    // even though the struct itself is not directly mutated
    var worker = ScanWorker{
        .allocator = allocator,
        .task_queue = &task_queue,
        .results = &results,
        .mutex = &mutex,
        .task_mutex = &task_mutex,
    };

    // Start worker threads
    for (threads) |*thread| {
        thread.* = try std.Thread.spawn(.{}, ScanWorker.run, .{&worker});
    }

    // Wait for all threads to complete
    for (threads) |thread| {
        thread.join();
    }

    return results;
}

fn outputJson(allocator: Allocator, results: []const ScanResult, file_path: ?[]const u8) !void {
    var output = ArrayList(u8).init(allocator);
    defer output.deinit();

    try output.appendSlice("[\n");

    var first = true;
    for (results) |result| {
        if (!result.open) continue;

        if (!first) {
            try output.appendSlice(",\n");
        }
        first = false;

        try output.appendSlice("  {\n");
        try fmt.format(output.writer(), "    \"host\": \"{s}\",\n", .{result.host});
        try fmt.format(output.writer(), "    \"port\": {},\n", .{result.port});
        try fmt.format(output.writer(), "    \"status\": \"open\"\n", .{});
        try output.appendSlice("  }");
    }

    try output.appendSlice("\n]\n");

    if (file_path) |path| {
        const file = try fs.cwd().createFile(path, .{});
        defer file.close();
        try file.writeAll(output.items);
        std.debug.print("Results saved to {s}\n", .{path});
    } else {
        std.debug.print("{s}", .{output.items});
    }
}

fn outputTxt(results: []const ScanResult, file_path: ?[]const u8) !void {
    if (file_path) |path| {
        const file = try fs.cwd().createFile(path, .{});
        defer file.close();

        for (results) |result| {
            if (result.open) {
                try file.writer().print("{s}:{}\n", .{ result.host, result.port });
            }
        }
        std.debug.print("Results saved to {s}\n", .{path});
    } else {
        for (results) |result| {
            if (result.open) {
                std.debug.print("{s}:{}\n", .{ result.host, result.port });
            }
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var config = Config{};

    // Parse command line arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help")) {
            printHelp();
            return;
        } else if (mem.eql(u8, arg, "-t") or mem.eql(u8, arg, "--target")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: -t requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.target = args[i];
        } else if (mem.eql(u8, arg, "-T") or mem.eql(u8, arg, "--targets")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: -T requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.targets_file = args[i];
        } else if (mem.eql(u8, arg, "-p") or mem.eql(u8, arg, "--ports")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: -p requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.ports = args[i];
        } else if (mem.eql(u8, arg, "-r") or mem.eql(u8, arg, "--range")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: -r requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.port_range = args[i];
        } else if (mem.eql(u8, arg, "-c") or mem.eql(u8, arg, "--concurrency")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: -c requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.concurrency = try fmt.parseInt(u32, args[i], 10);
        } else if (mem.eql(u8, arg, "--timeout")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: --timeout requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.timeout_ms = try fmt.parseInt(u32, args[i], 10);
        } else if (mem.eql(u8, arg, "--json")) {
            config.output_json = true;
        } else if (mem.eql(u8, arg, "--txt")) {
            config.output_txt = true;
        } else if (mem.eql(u8, arg, "-o") or mem.eql(u8, arg, "--output")) {
            i += 1;
            if (i >= args.len) {
                std.debug.print("Error: -o requires an argument\n", .{});
                return error.InvalidArgument;
            }
            config.output_file = args[i];
        }
    }

    // Validate configuration
    if (config.target == null and config.targets_file == null) {
        std.debug.print("Error: Target is required. Use -t <IP> or -T <file>\n", .{});
        std.debug.print("Use -h or --help for usage information\n", .{});
        return error.MissingTarget;
    }

    // Determine ports to scan
    var ports_list = ArrayList(u16).init(allocator);
    defer ports_list.deinit();

    if (config.ports) |port_str| {
        const parsed = try parsePortList(allocator, port_str);
        defer parsed.deinit();
        try ports_list.appendSlice(parsed.items);
    } else if (config.port_range) |range_str| {
        const parsed = try parsePortRange(allocator, range_str);
        defer parsed.deinit();
        try ports_list.appendSlice(parsed.items);
    } else {
        // Default common ports
        const default_ports = [_]u16{ 21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3306, 3389, 5432, 8080, 8443 };
        try ports_list.appendSlice(&default_ports);
    }

    if (config.target) |target| {
        std.debug.print("\n[*] Starting ZigScan v{s}\n", .{Version});
        std.debug.print("[*] Target: {s}\n", .{target});
        std.debug.print("[*] Ports: {d} total\n", .{ports_list.items.len});
        std.debug.print("[*] Concurrency: {d}\n", .{config.concurrency});
        std.debug.print("[*] Timeout: {d}ms\n", .{config.timeout_ms});
        std.debug.print("[*] Scanning...\n\n", .{});

        const start_time = std.time.milliTimestamp();

        const results = try scanConcurrent(allocator, target, ports_list.items, config);
        defer results.deinit();

        const end_time = std.time.milliTimestamp();
        const duration = end_time - start_time;

        // Count open ports
        var open_count: usize = 0;
        for (results.items) |result| {
            if (result.open) open_count += 1;
        }

        std.debug.print("[*] Scan completed in {d}ms\n", .{duration});
        std.debug.print("[*] Open ports: {d}/{d}\n\n", .{ open_count, ports_list.items.len });

        if (config.output_json) {
            try outputJson(allocator, results.items, config.output_file);
        } else if (config.output_txt) {
            try outputTxt(results.items, config.output_file);
        } else {
            // Default output
            std.debug.print("Open ports:\n", .{});
            for (results.items) |result| {
                if (result.open) {
                    std.debug.print("  {s}:{d}\n", .{ result.host, result.port });
                }
            }
        }
    }
}
