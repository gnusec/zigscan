const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const want_static = b.option(bool, "static", "Link statically when supported") orelse false;
    const want_strip = b.option(bool, "strip", "Strip symbols to reduce binary size") orelse false;

    const exe = b.addExecutable(.{
        .name = "zigscan",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .linkage = if (want_static) .static else null,
    });

    exe.root_module.strip = want_strip;

    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
