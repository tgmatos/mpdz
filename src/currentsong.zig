const std = @import("std");
const utils = @import("utils.zig");

const Writer = std.net.Stream.Writer;
const Reader = std.net.Stream.Reader;
const Stream = std.net.Stream;

const Result = enum { file, lastModified, format, album, artist, title, track, time, duration, pos, id, err };

const ParseError = utils.ParseError;

pub const CurrentSong = struct {
    const Self = @This();

    file: []u8,
    lastModified: []u8,
    format: []u8,
    album: []u8,
    artist: []u8,
    title: []u8,
    track: u32,
    time: u32,
    duration: f64,
    pos: u32,
    id: u32,

    pub fn init() !CurrentSong {
        return CurrentSong{
            .file = undefined,
            .lastModified = undefined,
            .format = undefined,
            .album = undefined,
            .artist = undefined,
            .title = undefined,
            .track = undefined,
            .time = undefined,
            .duration = undefined,
            .pos = undefined,
            .id = undefined,
        };
    }
};

fn parseInput(input: []u8) anyerror!CurrentSong {
    var currentSong = try CurrentSong.init();
    var iter = std.mem.splitSequence(u8, input, "\n");

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "OK")) {
            break;
        }

        var seq = std.mem.splitSequence(u8, line, ": ");
        var enumResult = std.meta.stringToEnum(Result, seq.first()) orelse .err;
        switch (enumResult) {
            .file => currentSong.file = seq.rest(),
            .lastModified => currentSong.lastModified = seq.rest(),
            .format => currentSong.format = seq.rest(),
            .album => currentSong.album = seq.rest(),
            .artist => currentSong.artist = seq.rest(),
            .title => currentSong.title = seq.rest(),
            .track => currentSong.track = try std.fmt.parseInt(u32, seq.rest(), 10),
            .time => currentSong.time = try std.fmt.parseInt(u32, seq.rest(), 10),
            .duration => currentSong.duration = try std.fmt.parseFloat(f64, seq.rest),
            .pos => currentSong.pos = try std.fmt.parseInt(u32, seq.rest(), 10),
            .id => currentSong.id = try std.fmt.parseInt(u32, seq.rest(), 10),
            .err => return ParseError.parseError,
        }
    }
}

pub fn getCurrentSong(writer: Writer, reader: Reader) anyerror!CurrentSong {
    var response: [512]u8 = undefined;

    try writer.writeAll("currentsong\n");

    var bufferUsed = try reader.read(&response);

    while (bufferUsed != 0 and !std.mem.eql(u8, response[bufferUsed - 3 .. bufferUsed], "OK\n")) {
        bufferUsed += try reader.read(response[bufferUsed..]);
    }

    return try parseInput(&response);
}
