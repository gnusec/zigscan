const std = @import("std");
const net = std.net;
const os = std.os;
const netutil = @import("netutil.zig");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Version = "0.1.1";

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
    adaptive: bool = false,
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
        \\  --adaptive              Enable simple adaptive concurrency (experimental)
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
    var ports = ArrayList(u16){};
    errdefer ports.deinit(allocator);

    var iter = mem.splitScalar(u8, port_str, ',');
    while (iter.next()) |port_part| {
        const trimmed = mem.trim(u8, port_part, " \t\r\n");
        if (trimmed.len == 0) continue;

        const port = try fmt.parseInt(u16, trimmed, 10);
        try ports.append(allocator, port);
    }

    return ports;
}

fn parsePortRange(allocator: Allocator, range_str: []const u8) !ArrayList(u16) {
    var ports = ArrayList(u16){};
    errdefer ports.deinit(allocator);

    var iter = mem.splitScalar(u8, range_str, '-');
    const start_str = iter.next() orelse return error.InvalidRange;
    const end_str = iter.next() orelse return error.InvalidRange;

    const start = try fmt.parseInt(u16, mem.trim(u8, start_str, " \t\r\n"), 10);
    const end = try fmt.parseInt(u16, mem.trim(u8, end_str, " \t\r\n"), 10);

    if (start > end) return error.InvalidRange;

    var port = start;
    while (port <= end) : (port += 1) {
        try ports.append(allocator, port);
    }

    return ports;
}

fn scanPort(host: []const u8, port: u16, timeout_ms: u32) bool {
    return netutil.connectWithTimeoutIPv4(host, port, timeout_ms);
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

            const task = self.task_queue.pop().?;
            self.task_mutex.unlock();

            const is_open = scanPort(task.host, task.port, task.timeout_ms);

            self.mutex.lock();
            defer self.mutex.unlock();

            self.results.append(self.allocator, ScanResult{
                .host = task.host,
                .port = task.port,
                .open = is_open,
            }) catch {};
        }
    }
};

fn scanConcurrent(allocator: Allocator, host: []const u8, ports: []const u16, config: Config) !ArrayList(ScanResult) {
    var results = ArrayList(ScanResult){};
    var task_queue = ArrayList(ScanTask){};
    defer task_queue.deinit(allocator);

    // Create task queue
    for (ports) |port| {
        try task_queue.append(allocator, ScanTask{
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

fn scanConcurrentAdaptive(allocator: Allocator, host: []const u8, ports: []const u16, config: Config) !ArrayList(ScanResult) {
    var results = ArrayList(ScanResult){};

    var idx: usize = 0;
    var current_c: usize = @intCast(@max(@as(u32, 1), config.concurrency));
    const min_c: usize = 8;
    const max_c: usize = 2000;

    while (idx < ports.len) {
        const remaining = ports.len - idx;
        const batch_c = if (remaining < current_c) remaining else current_c;

        var task_queue = ArrayList(ScanTask){};
        defer task_queue.deinit(allocator);
        var j: usize = 0;
        while (j < batch_c) : (j += 1) {
            try task_queue.append(allocator, .{ .host = host, .port = ports[idx + j], .timeout_ms = config.timeout_ms });
        }

        var mutex = std.Thread.Mutex{};
        var task_mutex = std.Thread.Mutex{};
        const threads = try allocator.alloc(std.Thread, batch_c);
        defer allocator.free(threads);
        var worker = ScanWorker{
            .allocator = allocator,
            .task_queue = &task_queue,
            .results = &results,
            .mutex = &mutex,
            .task_mutex = &task_mutex,
        };

        const tstart = std.time.milliTimestamp();
        for (threads) |*t| t.* = try std.Thread.spawn(.{}, ScanWorker.run, .{&worker});
        for (threads) |t| t.join();
        const dur = std.time.milliTimestamp() - tstart;

        const timeout = config.timeout_ms;
        if (dur < timeout / 3 and current_c < max_c) {
            current_c = @min(max_c, current_c + (current_c / 2) + 1);
        } else if (dur > timeout and current_c > min_c) {
            current_c = @max(min_c, current_c - (current_c / 3) - 1);
        }

        idx += batch_c;
    }

    return results;
}

fn outputJson(allocator: Allocator, results: []const ScanResult, file_path: ?[]const u8) !void {
    var output = ArrayList(u8){};
    defer output.deinit(allocator);

    try output.appendSlice(allocator, "[\n");

    var first = true;
    for (results) |result| {
        if (!result.open) continue;

        if (!first) {
            try output.appendSlice(allocator, ",\n");
        }
        first = false;

        try output.appendSlice(allocator, "  {\n");
        var buf: [128]u8 = undefined;
        const s1 = try std.fmt.bufPrint(&buf, "    \"host\": \"{s}\",\n", .{result.host});
        try output.appendSlice(allocator, s1);
        const s2 = try std.fmt.bufPrint(&buf, "    \"port\": {},\n", .{result.port});
        try output.appendSlice(allocator, s2);
        const s3 = try std.fmt.bufPrint(&buf, "    \"status\": \"open\"\n", .{});
        try output.appendSlice(allocator, s3);
        try output.appendSlice(allocator, "  }");
    }

    try output.appendSlice(allocator, "\n]\n");

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

        var buf: [128]u8 = undefined;
        for (results) |result| {
            if (result.open) {
                const s = try std.fmt.bufPrint(&buf, "{s}:{}\n", .{ result.host, result.port });
                try file.writeAll(s);
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
        } else if (mem.eql(u8, arg, "--adaptive")) {
            config.adaptive = true;
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
    var ports_list = ArrayList(u16){};
    defer ports_list.deinit(allocator);

    if (config.ports) |port_str| {
        var parsed = try parsePortList(allocator, port_str);
        defer parsed.deinit(allocator);
        try ports_list.appendSlice(allocator, parsed.items);
    } else if (config.port_range) |range_str| {
        var parsed = try parsePortRange(allocator, range_str);
        defer parsed.deinit(allocator);
        try ports_list.appendSlice(allocator, parsed.items);
    } else {
        // Default common ports
        const default_ports = [_]u16{ 21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3306, 3389, 5432, 8080, 8443 };
        try ports_list.appendSlice(allocator, &default_ports);
    }

    if (config.target) |target| {
        std.debug.print("\n[*] Starting ZigScan v{s}\n", .{Version});
        std.debug.print("[*] Target: {s}\n", .{target});
        std.debug.print("[*] Ports: {d} total\n", .{ports_list.items.len});
        std.debug.print("[*] Concurrency: {d}{s}\n", .{ config.concurrency, if (config.adaptive) " (adaptive)" else "" });
        std.debug.print("[*] Timeout: {d}ms\n", .{config.timeout_ms});
        std.debug.print("[*] Scanning...\n\n", .{});

        const start_time = std.time.milliTimestamp();

        var results = try (if (config.adaptive) scanConcurrentAdaptive(allocator, target, ports_list.items, config) else scanConcurrent(allocator, target, ports_list.items, config));
        defer results.deinit(allocator);

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
