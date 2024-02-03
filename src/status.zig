const std = @import("std");
const main = @import("main.zig");
const utils = @import("utils.zig");

const Writer = std.net.Stream.Writer;
const Reader = std.net.Stream.Reader;
const Stream = std.net.Stream;

const StatusError = error{ parseError, statusNull, numberTooLarge, boolError };

const State = enum { play, stop, pause };
const Result = enum { volume, repeat, random, single, consume, partition, playlist, playlistlength, mixrampdb, state, xfade, song, songid, time, elapsed, bitrate, duration, audio, nextsong, nextsongid, err };

const Status = struct {
    const Self = @This();

    volume: u32,
    repeat: bool,
    random: bool,
    single: bool,
    consume: bool,
    partition: []const u8,
    playlist: u32,
    playlistlength: u32,
    mixrampdb: i32,
    state: State,
    xfade: u32,
    song: ?u32 = null,
    songid: ?u32 = null,
    time: ?[]const u8 = null,
    elapsed: ?f32 = null,
    bitrate: ?u32 = null,
    duration: ?f32 = null,
    audio: ?[]const u8 = null,
    nextsong: ?u32 = null,
    nextsongid: ?u32 = null,

    pub fn init() !Status {
        return Status{
            .volume = undefined,
            .repeat = undefined,
            .random = undefined,
            .single = undefined,
            .consume = undefined,
            .partition = undefined,
            .playlist = undefined,
            .playlistlength = undefined,
            .mixrampdb = undefined,
            .state = undefined,
            .xfade = undefined,
        };
    }

    pub fn setVolume(self: *Self, writer: Writer, reader: Reader, volume: u32) anyerror!void {
        var previousVolume = self.volume;
        self.volume = volume;

        try writer.print("setvol {d}\n", .{self.volume});

        var resp = try utils.getResponse(reader);

        if (!std.mem.eql(u8, resp[0..2], "OK")) {
            self.volume = previousVolume;
            return StatusError.numberTooLarge;
        }
    }

    pub fn setRepeat(self: *Self, writer: Writer, reader: Reader, repeat: bool) anyerror!void {
        var previousValue = self.repeat;
        self.repeat = repeat;

        try writer.print("repeat {d}\n", .{@intFromBool(self.repeat)});

        var resp = try utils.getResponse(reader);

        if (!std.mem.eql(u8, resp[0..2], "OK")) {
            self.repeat = previousValue;
            return StatusError.boolError;
        }
    }

    pub fn setRandom(self: *Self, writer: Writer, reader: Reader, random: bool) anyerror!void {
        var previousValue = self.random;
        self.random = random;

        try writer.print("random {d}\n", .{@intFromBool(self.random)});

        var resp = try utils.getResponse(reader);

        if (!std.mem.eql(u8, resp[0..2], "OK")) {
            self.random = previousValue;
            return StatusError.boolError;
        }
    }

    pub fn setSingle(self: *Self, writer: Writer, reader: Reader, single: bool) anyerror!void {
        var previousValue = self.single;
        self.single = single;

        try writer.print("single {d}\n", .{@intFromBool(self.single)});

        var resp = try utils.getResponse(reader);

        if (!std.mem.eql(u8, resp[0..2], "OK")) {
            self.single = previousValue;
            return StatusError.boolError;
        }
    }

    pub fn setConsume(self: *Self, writer: Writer, reader: Reader, consume: bool) anyerror!void {
        var previousValue = self.consume;
        self.consume = consume;

        try writer.print("consume {d}\n", .{@intFromBool(self.consume)});

        var resp = try utils.getResponse(reader);

        if (!std.mem.eql(u8, resp[0..2], "OK")) {
            self.consume = previousValue;
            return StatusError.boolError;
        }
    }

    pub fn setMixrampdb(self: *Self, writter: Writer, reader: Reader, value: i32) anyerror!void {
        var previousValue = self.mixrampdb;

        try writter.print("mixrampdb {d}\n", .{value});

        var resp = try utils.getResponse(reader);

        if (!std.mem.eql(u8, resp[0..2], "OK")) {
            self.mixrampdb = previousValue;
            return StatusError.numberTooLarge;
        }
    }
};

fn intToBool(x: u32) bool {
    return x != 0;
}

fn parseInput(input: []u8) anyerror!Status {
    var status = try Status.init();
    var iter = std.mem.splitSequence(u8, input, "\n");

    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "OK")) {
            break;
        }

        var seq = std.mem.splitSequence(u8, line, ": ");
        var t = std.meta.stringToEnum(Result, seq.first()) orelse .err;

        switch (t) {
            .volume => status.volume = try std.fmt.parseInt(u32, seq.rest(), 10),
            .repeat => status.repeat = intToBool(try std.fmt.parseInt(u32, seq.rest(), 10)),
            .random => status.random = intToBool(try std.fmt.parseInt(u32, seq.rest(), 10)),
            .single => status.single = intToBool(try std.fmt.parseInt(u32, seq.rest(), 10)),
            .consume => status.consume = intToBool(try std.fmt.parseInt(u32, seq.rest(), 10)),
            .partition => status.partition = seq.rest(),
            .playlist => status.playlist = try std.fmt.parseInt(u32, seq.rest(), 10),
            .playlistlength => status.playlistlength = try std.fmt.parseInt(u32, seq.rest(), 10),
            .mixrampdb => status.mixrampdb = try std.fmt.parseInt(i32, seq.rest(), 10),
            .state => status.state = std.meta.stringToEnum(State, seq.rest()) orelse State.stop,
            .xfade => status.xfade = try std.fmt.parseInt(u32, seq.rest(), 10),
            .song => status.song = try std.fmt.parseInt(u32, seq.rest(), 10),
            .songid => status.songid = try std.fmt.parseInt(u32, seq.rest(), 10),
            .time => status.time = seq.rest(),
            .elapsed => status.elapsed = try std.fmt.parseFloat(f32, seq.rest()),
            .bitrate => status.bitrate = try std.fmt.parseInt(u32, seq.rest(), 10),
            .duration => status.duration = try std.fmt.parseFloat(f32, seq.rest()),
            .audio => status.audio = seq.rest(),
            .nextsong => status.nextsong = try std.fmt.parseInt(u32, seq.rest(), 10),
            .nextsongid => status.nextsongid = try std.fmt.parseInt(u32, seq.rest(), 10),
            .err => return StatusError.parseError,
        }
    }

    return status;
}

pub fn getStatus(writer: Writer, reader: Reader) !Status {
    var response: [512]u8 = undefined;

    try writer.writeAll("status\n");

    var bufferUsed = try reader.read(&response);

    while (bufferUsed != 0 and !std.mem.eql(u8, response[bufferUsed - 3 .. bufferUsed], "OK\n")) {
        bufferUsed += try reader.read(response[bufferUsed..]);
    }

    var stt = try parseInput(&response);

    return stt;
}

test "status" {
    var buf: [14]u8 = undefined;
    const conn = try main.getConnection();
    defer conn.close();

    const writer = conn.writer();
    const reader = conn.reader();

    var read = try reader.readUntilDelimiter(&buf, '\n');

    std.debug.print("\nRead: {s}", .{read});

    var stt = try getStatus(writer, reader);

    //stt.partition = "test";

    _ = try stt.setVolume(writer, reader, 100);

    std.debug.print("\n\n", .{});
}
