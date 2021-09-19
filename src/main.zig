// == Darwin ==
// rm -f /opt/homebrew/opt/curl/lib/libcurl.a # workaround for UnhandledSymbolType (is a _curl_jmpenv common symbol)
// zig build-exe src/main.zig -lc -lcurl --name zigcurl -L/opt/homebrew/opt/curl/lib -dynamic

const std = @import("std");

pub extern fn curl_easy_init() ?*c_void;
pub extern fn curl_easy_setopt(curl: ?*c_void, option: c_int, ...) c_int;
pub extern fn curl_easy_cleanup(curl: ?*c_void) void;
pub extern fn curl_easy_perform(curl: ?*c_void) c_int;

const CURLE_OK = 0;
const CURLOPT_URL = 10002;

pub fn main() anyerror!void {
    const curl = curl_easy_init();
    defer curl_easy_cleanup(curl);

    const url = "https://api.ipify.org?format=json";
    if (curl_easy_setopt(curl, CURLOPT_URL, url) != CURLE_OK) {
        std.log.err("failed to set URL", .{});
        std.process.exit(1);
    }
    const res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        std.log.err("GET failed: {d}", .{res});
        std.process.exit(1);
    }

    std.log.info("curl {s}:", .{url});
}
