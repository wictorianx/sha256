const std = @import("std");
const Sha2 = std.crypto.hash.sha2.Sha256;
const initial_h = [8]u32{
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
};
const k = [64]u32{
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

pub const Sha256 = struct {
    h: [8]u32,
    buffer: [64]u8,
    buf_len: usize,
    total_len_bits: u64,

    fn init() Sha256 {
        return Sha256{
            .h = initial_h,
            .buffer = [_]u8{0} ** 64,
            .buf_len = 0,
            .total_len_bits = 0,
        };
    }
    fn processBlock(self: *Sha256, block: *const [64]u8) void {
        var w = [_]u32{0} ** 64;
        for (0..16) |i| {
            w[i] = std.mem.readInt(u32, block[i * 4 ..][0..4], .big);
        }
        for (16..64) |i| {
            w[i] = sigma0(w[i - 15]) +% sigma1(w[i - 2]) +% w[i - 7] +% w[i - 16];
        }
        var a = self.h[0];
        var b = self.h[1];
        var c = self.h[2];
        var d = self.h[3];
        var e = self.h[4];
        var f = self.h[5];
        var g = self.h[6];
        var h = self.h[7];

        for (0..64) |i| {
            const t1 = h +% Sigma1(e) +% ch(e, f, g) +% k[i] +% w[i];
            const t2 = Sigma0(a) +% maj(a, b, c);

            h = g;
            g = f;
            f = e;
            e = d +% t1;
            d = c;
            c = b;
            b = a;
            a = t1 +% t2;
        }

        // 4. Update the state
        self.h[0] +%= a;
        self.h[1] +%= b;
        self.h[2] +%= c;
        self.h[3] +%= d;
        self.h[4] +%= e;
        self.h[5] +%= f;
        self.h[6] +%= g;
        self.h[7] +%= h;
    }
    fn update(self: *Sha256, data: []const u8) void {
        for (data) |byte| {
            self.buffer[self.buf_len] = byte;
            self.buf_len += 1;
            self.total_len_bits += 8;

            if (self.buf_len == 64) {
                self.processBlock(&self.buffer);
                self.buf_len = 0;
            }
        }
    }
    fn finalize(self: *Sha256) [8]u32 {
        self.buffer[self.buf_len] = 0x80;
        self.buf_len += 1;
        if (self.buf_len > 56) {
            @memset(self.buffer[self.buf_len..64], 0);
            self.processBlock(&self.buffer);

            // Reset the buffer to 0s for a brand new final block
            @memset(self.buffer[0..64], 0);
            self.buf_len = 0;
        }
        @memset(self.buffer[self.buf_len..56], 0);
        std.mem.writeInt(u64, self.buffer[56..64], self.total_len_bits, .big);

        // 5. One last crunch
        self.processBlock(&self.buffer);

        return self.h;
    }
};
fn sigma0(x: u32) u32 {
    var a = std.math.rotr(u32, x, 7);
    a = a ^ std.math.rotr(u32, x, 18);
    a = a ^ x >> 3;
    return a;
}
fn sigma1(x: u32) u32 {
    var a = std.math.rotr(u32, x, 17);
    a = a ^ std.math.rotr(u32, x, 19);
    a = a ^ x >> 10;
    return a;
}
fn Sigma0(x: u32) u32 {
    var a = std.math.rotr(u32, x, 2);
    a = a ^ std.math.rotr(u32, x, 13);
    a = a ^ std.math.rotr(u32, x, 22);
    return a;
}
fn Sigma1(x: u32) u32 {
    var a = std.math.rotr(u32, x, 6);
    a = a ^ std.math.rotr(u32, x, 11);
    a = a ^ std.math.rotr(u32, x, 25);
    return a;
}
fn ch(e: u32, f: u32, g: u32) u32 {
    return (e & f) ^ (~e & g);
}
fn maj(a: u32, b: u32, c: u32) u32 {
    return (a & b) ^ (a & c) ^ (b & c);
}
fn hasherWorker(counter: *std.atomic.Value(u64)) void {
    while (true) {
        const base = counter.fetchAdd(1000, .monotonic);
        for (0..1000) |i| {
            const unique_c = base + i; // Now every hash in the batch is different
            var s = Sha256.init();
            s.update(std.mem.asBytes(&unique_c));
            _ = s.finalize();
        }
    }
}
fn hardwareHasher(counter: *std.atomic.Value(u64)) void {
    const batch_size = 10000;
    var hash_out: [32]u8 = undefined;

    while (true) {
        const base = counter.fetchAdd(batch_size, .monotonic);

        for (0..batch_size) |i| {
            const val = base + i;
            // This call will use Intel SHA Extensions automatically
            Sha2.hash(std.mem.asBytes(&val), &hash_out, .{});
        }
    }
}
pub fn main() !void {
    var p_h: u64 = 0;
    var total_hashes = std.atomic.Value(u64).init(0);
    var hashes_total: u64 = 0;
    for (0..12) |_| {
        _ = try std.Thread.spawn(.{}, hardwareHasher, .{&total_hashes});
    }
    while (true) {
        std.Thread.sleep(std.time.ns_per_s);
        hashes_total = total_hashes.load(.monotonic);
        std.debug.print("\r{d}", .{hashes_total - p_h});
        p_h = hashes_total;
    }
}
