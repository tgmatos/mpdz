const std = @import("std");
const utils = @import("utils.zig");

pub const Writer = std.net.Stream.Writer;
pub const Reader = std.net.Stream.Reader;

const PlaybackError = error{ PauseFailure, BadSongIndex, NotPlaying, GeneralError, ReadError };

pub fn pause(writer: Writer) anyerror!void {
    _ = try writer.writeAll("pause\n");
}

pub fn play(writer: Writer, reader: Reader, pos: u32) anyerror!void {
    _ = try writer.print("play {d}\n", .{pos});

    var resp = try utils.getResponse(reader);
    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        return PlaybackError.BadSongIndex;
    }
}

pub fn previous(writer: Writer, reader: Reader) anyerror!void {
    _ = try writer.writeAll("previous\n");

    var resp = try utils.getResponse(reader);
    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        return PlaybackError.NotPlaying;
    }
}

pub fn stop(writer: Writer) anyerror!void {
    _ = try writer.writeAll("stop\n");
}

pub fn seek(writer: Writer, reader: Reader, pos: u32, seconds: u32) anyerror!void {
    _ = try writer.print("seek \"{d}\" \"{d}\"\n", .{ pos, seconds });

    var resp = try utils.getResponse(reader);
    if (!std.mem.eql(u8, resp[0..2], "OK")) {
        return PlaybackError.BadSongIndex;
    }
}
