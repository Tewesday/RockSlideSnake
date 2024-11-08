const std = @import("std");

pub fn build(b: *std.Build) !void {
    const exe = b.addExecutable(.{
        .name = "cart",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .wasi,
        }),
        .optimize = b.standardOptimizeOption(.{}),
    });

    // exe.linkLibC();
    // exe.addIncludePath(b.path("c-src"));   // Look for C source files
    
    // Allow exported symbols to actually be exported.
    //exe.rdynamic = true;
    
    exe.wasi_exec_model = .reactor;

    exe.entry = .disabled;
    exe.root_module.export_symbol_names = &[_][]const u8{ "start", "update" };
    exe.import_memory = true;
    exe.initial_memory = 65536;
    exe.max_memory = 65536;
    exe.stack_size = 14752;

    b.installArtifact(exe);
}
