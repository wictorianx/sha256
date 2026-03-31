const std = @import("std");
var w = [_]u32{0} ** 64;
var h0: u32 = 0x6a09e667;
var h1: u32 = 0xbb67ae85;
var h2: u32 = 0x3c6ef372;
var h3: u32 = 0xa54ff53a;
var h4: u32 = 0x510e527f;
var h5: u32 = 0x9b05688c;
var h6: u32 = 0x1f83d9ab;
var h7: u32 = 0x5be0cd19;
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
const input_message = "hello world";

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
pub fn main() void {
    var buffer = [_]u8{0} ** 64;
    @memcpy(buffer[0..input_message.len], input_message);

    // 3. Add the "1" bit (0x80)
    buffer[input_message.len] = 0x80;
    const len_bits: u64 = input_message.len * 8;
    std.mem.writeInt(u64, buffer[56..64], len_bits, .big);

    for (0..16) |i| {
        const start = i * 4;
        // The [0..4] at the end coerces the slice into a pointer to a 4-byte array
        w[i] = std.mem.readInt(u32, buffer[start..][0..4], .big);
    }
    for (16..64) |i| {
        const s0 = sigma0(w[i - 15]);
        const s1 = sigma1(w[i - 2]);

        // We use a temporary variable to make it super clear for the compiler
        w[i] = s0 +% s1 +% w[i - 7] +% w[i - 16];
    }
    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;
    var f = h5;
    var g = h6;
    var h = h7;
    for (0..64) |i| {
        // 1. Calculate the Chaos (T1 and T2)
        const t1 = h +% Sigma1(e) +% ch(e, f, g) +% k[i] +% w[i];
        const t2 = Sigma0(a) +% maj(a, b, c);

        // 2. The Shift (Musical Chairs)
        // You MUST do this in exact order so you don't overwrite values early
        h = g;
        g = f;
        f = e;
        e = d +% t1; // e gets injected with t1
        d = c;
        c = b;
        b = a;
        a = t1 +% t2; // a gets the combined chaos
    }
    h0 +%= a;
    h1 +%= b;
    h2 +%= c;
    h3 +%= d;
    h4 +%= e;
    h5 +%= f;
    h6 +%= g;
    h7 +%= h;
    std.debug.print("{x:0>8}{x:0>8}{x:0>8}{x:0>8}{x:0>8}{x:0>8}{x:0>8}{x:0>8}\n", .{ h0, h1, h2, h3, h4, h5, h6, h7 });
}
