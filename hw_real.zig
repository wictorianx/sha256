const std = @import("std");
const Sha256 = std.crypto.hash.sha2.Sha256;

var global_hashes: std.atomic.Value(u64) = std.atomic.Value(u64).init(0);

fn worker(worker_id: u32) void {
    _ = worker_id; // THE FIX: Silence Zig's strict unused variable error

    const batch_size: u64 = 50_000;

    // 4 independent buffers to fill the CPU hardware pipeline
    var buf1: [32]u8 = [_]u8{0} ** 32;
    var buf2: [32]u8 = [_]u8{0} ** 32;
    var buf3: [32]u8 = [_]u8{0} ** 32;
    var buf4: [32]u8 = [_]u8{0} ** 32;

    std.crypto.random.bytes(&buf1);
    std.crypto.random.bytes(&buf2);
    std.crypto.random.bytes(&buf3);
    std.crypto.random.bytes(&buf4);

    while (true) {
        for (0..batch_size) |idx| {
            // Guarantee unique work every loop
            buf1[0] = @as(u8, @truncate(idx));
            buf2[0] = @as(u8, @truncate(idx + 1));
            buf3[0] = @as(u8, @truncate(idx + 2));
            buf4[0] = @as(u8, @truncate(idx + 3));

            // Run 4 hardware hashes back-to-back to overlap instruction execution
            Sha256.hash(&buf1, &buf1, .{});
            Sha256.hash(&buf2, &buf2, .{});
            Sha256.hash(&buf3, &buf3, .{});
            Sha256.hash(&buf4, &buf4, .{});

            // Prevent dead code elimination
            std.mem.doNotOptimizeAway(&buf1);
            std.mem.doNotOptimizeAway(&buf2);
            std.mem.doNotOptimizeAway(&buf3);
            std.mem.doNotOptimizeAway(&buf4);
        }

        _ = global_hashes.fetchAdd(batch_size * 4, .monotonic);
    }
}

pub fn main() !void {
    const thread_count = 12;
    var threads: [thread_count]std.Thread = undefined;

    std.debug.print("Executing ILP-Maxed Hardware SHA-NI Benchmark...\n", .{});

    for (0..thread_count) |i| {
        threads[i] = try std.Thread.spawn(.{}, worker, .{@as(u32, @intCast(i))});
    }

    var timer = try std.time.Timer.start();
    while (true) {
        std.Thread.sleep(1 * std.time.ns_per_s);
        const elapsed = timer.lap();
        const hashes = global_hashes.swap(0, .monotonic);

        const ghps = @as(f64, @floatFromInt(hashes)) / (@as(f64, @floatFromInt(elapsed)) / 1e9) / 1e9;
        std.debug.print("\rPipeline-Maxed Hardware Speed: {d:.4} GH/s", .{ghps});
    }
}
