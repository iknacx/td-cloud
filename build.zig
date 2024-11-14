const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const pong = b.addExecutable(.{
        .name = "pong",
        .root_source_file = b.path("src/pong.zig"), // b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    pong.entry = .disabled;
    pong.root_module.export_symbol_names = &[_][]const u8{ "start", "update" };
    pong.import_memory = true;
    pong.initial_memory = 65536;
    pong.max_memory = 65536;
    pong.stack_size = 14752;

    b.installArtifact(pong);

    const snake = b.addExecutable(.{
        .name = "snake",
        .root_source_file = b.path("src/snake.zig"), // b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    snake.entry = .disabled;
    snake.root_module.export_symbol_names = &[_][]const u8{ "start", "update" };
    snake.import_memory = true;
    snake.initial_memory = 65536;
    snake.max_memory = 65536;
    snake.stack_size = 14752;

    b.installArtifact(snake);
}
