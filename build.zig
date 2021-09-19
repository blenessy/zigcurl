const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zigcurl", "src/main.zig");
    //exe.addCSourceFile("src/download.c", &[_][]const u8{});
    //exe.setTarget(.{.cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu});
    exe.setTarget(target);
    exe.setBuildMode(mode);
    //exe.setVerboseCC(true);
    //exe.setVerboseLink(true);
    exe.linkLibC();
    if (exe.target.isDarwin()) {
        // brew install curl
        const libCurlPath = "/opt/homebrew/opt/curl/lib";
        exe.addLibPath(libCurlPath);
        // workaround for UnhandledSymbolType (is a _curl_jmpenv common symbol)
        const dir = std.fs.openDirAbsolute(libCurlPath, .{.access_sub_paths = true}) catch {
            std.log.err("could not open {s}", .{libCurlPath});
            std.process.exit(1);
        };
        if (dir.rename("libcurl.a", "libcurl.a.bak")) {
            std.log.info("renamed {s}/libcurl.a to libcurl.a.bak", .{libCurlPath});
        } else |err| {
            std.debug.assert(err == error.FileNotFound);
        }
    }
    exe.linkSystemLibrary("curl"); // add libcurl to the project
    // exe.addIncludeDir("/opt/homebrew/opt/curl/include");
    // exe.addLibPath("/usr/lib/aarch64-linux-gnu");
    // exe.linkSystemLibraryName("curl");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
