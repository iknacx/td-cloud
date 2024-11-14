const std = @import("std");
const w4 = @import("wasm4.zig");

var prng: std.rand.DefaultPrng = undefined;
var rand: std.rand.Random = undefined;

const WIDTH = 5;
const HEIGHT = 15;
const BALL_SIZE = 5;

fn checkCollision(y1: i32, y2: i32, ball_x: i32, ball_y: i32) i32 {
    if (ball_x < WIDTH and ball_y < y2 + HEIGHT and ball_y + BALL_SIZE > y2) return 1;
    if (ball_x + BALL_SIZE > w4.SCREEN_SIZE - WIDTH and ball_y < y1 + HEIGHT and ball_y + BALL_SIZE > y1) return -1;
    return 0;
}

export fn start() void {
    prng = std.rand.DefaultPrng.init(0);
    rand = prng.random();
}

export fn update() void {
    const static = struct {
        var score1: usize = 0;
        var score2: usize = 0;

        var ball_x: i32 = w4.SCREEN_SIZE / 2;
        var ball_y: i32 = w4.SCREEN_SIZE / 2;

        var dir_x: i32 = 1;
        var dir_y: i32 = 1;

        var y1: i32 = w4.SCREEN_SIZE / 2;
        var y2: i32 = w4.SCREEN_SIZE / 2;
    };

    const input = w4.GAMEPAD1.*;
    if (input & w4.BUTTON_UP != 0 and static.y1 > 0)
        static.y1 -= 2
    else if (input & w4.BUTTON_DOWN != 0 and static.y1 + HEIGHT < w4.SCREEN_SIZE)
        static.y1 += 2;

    static.y2 = static.ball_y;

    const dir_now = checkCollision(static.y1, static.y2, static.ball_x, static.ball_y);
    if (dir_now != 0) {
        static.dir_x = dir_now;
        w4.tone(2000, 5, 100, w4.TONE_PULSE1);

        const dy: i16 = if (rand.int(u16) % 2 == 0) -1 else 1;
        static.dir_y = dir_now * dy;
    }

    static.ball_x += static.dir_x;
    static.ball_y += static.dir_y;

    if (static.ball_y > w4.SCREEN_SIZE or static.ball_y < 0) {
        w4.tone(2000, 5, 100, w4.TONE_PULSE1);
        static.dir_y *= -1;
    }

    if (static.ball_x < 0 or static.ball_x > w4.SCREEN_SIZE) {
        if (static.ball_x < 0) static.score1 += 1;
        if (static.ball_x > w4.SCREEN_SIZE) static.score2 += 1;
        static.ball_x = w4.SCREEN_SIZE / 2;
        static.ball_y = w4.SCREEN_SIZE / 2;

        w4.tone(1000, 5, 100, w4.TONE_PULSE1);
        static.dir_x *= -1;
    }

    w4.DRAW_COLORS.* = 0x04;

    var score1_buf: [32]u8 = undefined;
    var score2_buf: [32]u8 = undefined;

    const score1_str = std.fmt.bufPrint(&score1_buf, "{d}", .{static.score1}) catch unreachable;
    const score2_str = std.fmt.bufPrint(&score2_buf, "{d}", .{static.score2}) catch unreachable;

    w4.text(score2_str, 70, 0);
    w4.text(score1_str, 85, 0);
    w4.rect(w4.SCREEN_SIZE / 2, 0, 2, w4.SCREEN_SIZE);

    w4.DRAW_COLORS.* = 0x32;

    w4.oval(static.ball_x, static.ball_y, BALL_SIZE, BALL_SIZE);
    w4.rect(0, static.y2, WIDTH, HEIGHT);
    w4.rect(w4.SCREEN_SIZE - WIDTH, static.y1, WIDTH, HEIGHT);
}
