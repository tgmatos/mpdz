const std = @import("std");

pub const Writer = std.net.Stream.Writer;
pub const Reader = std.net.Stream.Reader;

pub fn getResponse(reader: Reader) anyerror![]u8 {
    var response: [128]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&response);
    var wrt = fbs.writer();

    _ = try reader.streamUntilDelimiter(wrt, '\n', null);
    return &response;
}
