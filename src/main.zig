const std = @import("std");
const os = std.os;
const net = std.net;
const Stream = net.Stream;
const playback = @import("playback.zig");
const status = @import("status.zig");
//==================//
const addr = "127.0.0.1";
const port: u16 = 6601;

pub fn main() !void {}

pub fn getConnection() !Stream {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    const conn = try net.tcpConnectToHost(allocator, addr, port);
    return conn;
}

// test "status" {
//     var buf: [14]u8 = undefined;
//     const conn = try getConnection();
//     defer conn.close();

//     const writer = conn.writer();
//     const reader = conn.reader();

//     var read = try reader.readUntilDelimiter(&buf, '\n');

//     std.debug.print("\nRead: {s}\n", .{read});

//     _ = try stt.getStatus(&writer, &reader);
//     //_ = try playback.play(&writer, &reader, 1);
//     // _ = try playback.pause(&writer);
//     // _ = try playback.previous(&writer, &reader);
//     //_ = try playback.seek(&writer, &reader, 1, 60);}

//     std.debug.print("\n\n", .{});
// }
