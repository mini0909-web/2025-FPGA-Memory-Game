`timescale 1ns / 1ps

module top(
    input clock_12MHz,
    input RESET,

    input Mode_Switch,
    input [8:0] KEY,

    output [7:0] LED,
    output [9:0] DOT_COL,
    output [13:0] DOT_RAW,

    output [3:0] FND_COM,
    output [7:0] FND_DATA,
	 
	  output LCD_RS,
    output LCD_RW,
    output LCD_EN,
    output [7:0] LCD_DATA,

    output BUZZER,
    output [3:0] MOTOR_OUT,

    input easy,
    input normal,
    input hard,
    input vhard
);

wire clock_24MHz;

wire [15:0] score;
wire game_active;
wire game_input_active;
wire game_over;
wire game_success;

wire TIME_UP;

PLL24X2 PLL(
    .RESET(RESET),
    .CLK_IN1(clock_12MHz),
    .CLK_OUT1(clock_24MHz)
);

led_ctrl led_ctrl(
    .RESET(RESET),
    .CLK(clock_24MHz),
    .Mode_Switch(Mode_Switch),
    .KEY(KEY),

    .TIME_UP(TIME_UP),

    .EASY(easy),
    .NORMAL(normal),
    .HARD(hard),
    .VHARD(vhard),

	.LED(LED),
    .SCORE(score),
    .GAME_ACTIVE(game_active),
    .GAME_INPUT_ACTIVE(game_input_active),
    .GAME_OVER(game_over),
    .GAME_SUCCESS(game_success)
);


segment segment(
    .CLK(clock_24MHz),
    .RESET(RESET),
    .GAME_ACTIVE(game_active),
    .FND_COM(FND_COM),
    .FND_DATA(FND_DATA),
    .TIME_UP(TIME_UP)
);

textlcd textlcd(
    .RESET(RESET),
    .CLK(clock_24MHz),
    .TIMER_SEC(16'd0),
    .SCORE(score),
    .GAME_ACTIVE(game_active),

    .GAME_SUCCESS(game_success),
    .GAME_OVER(game_over),

    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_DATA(LCD_DATA)
);

piezo piezo(
    .RESET(RESET),
    .CLK(clock_24MHz),
    .GAME_ACTIVE(game_active),
    .GAME_CLEAR(1'b0),
    .TIME_UP(TIME_UP),
    .BUZZER(BUZZER)
);

motor motor(
    .RESET(RESET),
    .CLK(clock_24MHz),
    .GAME_ACTIVE(game_active && !game_over),
    .TIME_UP(TIME_UP),
    .MOTOR_OUT(MOTOR_OUT)
);

dot dot(
    .RESET(RESET),
    .CLK(clock_24MHz),
    .TIME_UP(TIME_UP),
    .SCORE(score),
    .DOT_COL(DOT_COL),
    .DOT_RAW(DOT_RAW)
);

endmodule