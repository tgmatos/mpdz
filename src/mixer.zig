const std = @import("std");
const utils = @import("utils.zig");
const status = @import("status.zig");

const Writer = std.net.Stream.Writer;
const Reader = std.net.Stream.Reader;
const Stream = std.net.Stream;
const Status = status.Status;

const StatusError = error{ numberTooLarge, boolError };

pub fn setVolume(mpdStatus: *Status, writer: Writer, reader: Reader, volume: u32) anyerror!void {
    var previousVolume = mpdStatus.volume;
    mpdStatus.volume = volume;

    try writer.print("setvol {d}\n", .{mpdStatus.volume});

    var resp = try utils.getResponse(reader);

    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        mpdStatus.volume = previousVolume;
        return StatusError.numberTooLarge;
    }
}

pub fn setRepeat(mpdStatus: *Status, writer: Writer, reader: Reader, repeat: bool) anyerror!void {
    var previousValue = mpdStatus.repeat;
    mpdStatus.repeat = repeat;

    try writer.print("repeat {d}\n", .{@intFromBool(mpdStatus.repeat)});

    var resp = try utils.getResponse(reader);

    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        mpdStatus.repeat = previousValue;
        return StatusError.boolError;
    }
}

pub fn setRandom(mpdStatus: *Status, writer: Writer, reader: Reader, random: bool) anyerror!void {
    var previousValue = mpdStatus.random;
    mpdStatus.random = random;

    try writer.print("random {d}\n", .{@intFromBool(mpdStatus.random)});

    var resp = try utils.getResponse(reader);

    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        mpdStatus.random = previousValue;
        return StatusError.boolError;
    }
}

pub fn setSingle(mpdStatus: *Status, writer: Writer, reader: Reader, single: bool) anyerror!void {
    var previousValue = mpdStatus.single;
    mpdStatus.single = single;

    try writer.print("single {d}\n", .{@intFromBool(mpdStatus.single)});

    var resp = try utils.getResponse(reader);

    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        mpdStatus.single = previousValue;
        return StatusError.boolError;
    }
}

pub fn setConsume(mpdStatus: *Status, writer: Writer, reader: Reader, consume: bool) anyerror!void {
    var previousValue = mpdStatus.consume;
    mpdStatus.consume = consume;

    try writer.print("consume {d}\n", .{@intFromBool(mpdStatus.consume)});

    var resp = try utils.getResponse(reader);

    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        mpdStatus.consume = previousValue;
        return StatusError.boolError;
    }
}

pub fn setMixrampdb(mpdStatus: *Status, writter: Writer, reader: Reader, value: i32) anyerror!void {
    var previousValue = mpdStatus.mixrampdb;

    try writter.print("mixrampdb {d}\n", .{value});

    var resp = try utils.getResponse(reader);

    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        mpdStatus.mixrampdb = previousValue;
        return StatusError.numberTooLarge;
    }
}
