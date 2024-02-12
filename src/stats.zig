const std = @import("std");
const utils = @import("utils.zig");

const Writer = std.net.Stream.Writer;
const Reader = std.net.Stream.Reader;
const Stream = std.net.Stream;

const StatsError = error{parseError};
const Result = enum { uptime, playtime, artists, albums, songs, dbPlaytime, dbUpdate, err };

const Stats = struct {
    const Self = @This();

    uptime: u32,
    playtime: u32,
    artists: u32,
    albums: u32,
    songs: u32,
    dbPlaytime: u32,
    dbUpdate: i64,

    pub fn init() !Stats {
        return Stats{
            .uptime = undefined,
            .playtime = undefined,
            .artists = undefined,
            .albums = undefined,
            .songs = undefined,
            .dbPlaytime = undefined,
            .dbUpdate = undefined,
        };
    }
};

fn parseInput(input: []u8) anyerror!Stats {
    var stats = Stats.init();
    var iter = std.mem.splitSequence(u8, input, "\n");

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "OK")) {
            break;
        }

        var seq = std.mem.splitSequence(u8, line, ": ");
        var enumResult = std.meta.stringToEnum(Result, seq.first()) orelse .err;

        switch (enumResult) {
            .uptime => stats.uptime = try std.fmt.parseInt(u32, seq.rest(), 10),
            .playtime => stats.playtime = try std.fmt.parseInt(u32, seq.rest(), 10),
            .artists => stats.artists = try std.fmt.parseInt(u32, seq.rest(), 10),
            .albums => stats.albums = try std.fmt.parseInt(u32, seq.rest(), 10),
            .songs => stats.songs = try std.fmt.parseInt(u32, seq.rest(), 10),
            .dbPlaytime => stats.dbPlaytime = try std.fmt.parseInt(u32, seq.rest(), 10),
            .dbUpdate => stats.dbUpdate = try std.fmt.parseInt(i64, seq.rest(), 10),
            .err => return StatsError.parseError,
        }
    }
}

pub fn getStats(writer: Writer, reader: Reader) anyerror!Stats {
    var response: [512]u8 = undefined;

    try writer.writeAll("stats\n");

    var bufferUsed = try reader.read(&response);

    while (bufferUsed != 0 and !std.mem.eql(u8, response[bufferUsed - 3 .. bufferUsed], "OK\n")) {
        bufferUsed += try reader.read(response[bufferUsed..]);
    }

    var stts = try parseInput(&bufferUsed);

    return stts;
}
