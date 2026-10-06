`timescale 1ns / 1ps

module textlcd(
    input               RESET,
    input               CLK,

    input      [15:0]   TIMER_SEC,
    input      [15:0]   SCORE,
    input               GAME_ACTIVE,

    input               GAME_SUCCESS,
    input               GAME_OVER,

    output wire         LCD_RS,
    output wire         LCD_RW,
    output reg          LCD_EN,
    output wire [7:0]   LCD_DATA
);

reg [10:0] delay_lcdclk;
reg [5:0]  count_lcd;
reg [8:0]  set_data;

/* 점수 래치 */
reg [15:0] latched_score;

/* 자리수 */
reg [3:0] score_tens;
reg [3:0] score_ones;
reg [3:0] prev_ones;

/* LCD 문자열 */
reg [127:0] line_1;
reg [127:0] line_2;

/* 초기 문구 */
initial begin
    line_1 = "SCORE : 00      "; // 16 chars
    line_2 = "RESULT: ----    "; // 16 chars
end

/* 점수 래치 */
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        latched_score <= 16'd0;
    else if (GAME_ACTIVE)
        latched_score <= SCORE;
end

/* 점수 자리 계산 */
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        score_tens <= 4'd0;
        score_ones <= 4'd0;
        prev_ones  <= 4'd0;
    end
    else if (GAME_ACTIVE) begin
        score_ones <= latched_score % 10;
        
        if (prev_ones == 4'd9 && (latched_score % 10) == 4'd0)
            score_tens <= score_tens + 1'b1;

        prev_ones <= latched_score % 10;
    end
end

/* LCD 표시 갱신 (Combinational) */
always @(*) begin
    // LINE 1: "SCORE : XX      "
    line_1[127:64] = "SCORE : "; // 8 chars
    line_1[63:56] = score_tens + 8'd48;
    line_1[55:48] = score_ones + 8'd48;
    line_1[47:0]  = "      "; // 6 spaces padding

    // LINE 2: "RESULT: [STATUS]"
    line_2[127:64] = "RESULT: "; // 8 chars
    
    if (GAME_OVER) begin
        // "FAIL    "
        line_2[63:32] = "FAIL"; 
        line_2[31:0]  = "    "; // Pad clean
    end
    else if (GAME_SUCCESS) begin
        // "COMPLETE" (8 chars)
        line_2[63:0]  = "COMPLETE"; 
    end
    else begin
        // "----    "
        line_2[63:32] = "----";
        line_2[31:0]  = "    ";
    end
end

/* LCD Enable Timing */
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        delay_lcdclk <= 0;
        LCD_EN <= 0;
    end else begin
        if (delay_lcdclk < 11'd1800)
            delay_lcdclk <= delay_lcdclk + 1;
        else
            delay_lcdclk <= 0;

        if (delay_lcdclk == 11'd200)
            LCD_EN <= 1'b1;
        else if (delay_lcdclk == 11'd1800)
            LCD_EN <= 1'b0;
    end
end

/* LCD 상태 카운터 */
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        count_lcd <= 0;
    else if (delay_lcdclk == 11'd0) begin
        if (count_lcd < 6'd39)
            count_lcd <= count_lcd + 1;
        else
            count_lcd <= 6'd6; 
    end
end

/* LCD Data FSM */
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        set_data <= 9'd0;
    else begin
        case (count_lcd)
            // Init Sequence
            6'd0  : set_data <= {1'b0, 8'h38};
            6'd1  : set_data <= {1'b0, 8'h38};
            6'd2  : set_data <= {1'b0, 8'h0E};
            6'd3  : set_data <= {1'b0, 8'h06};
            6'd4  : set_data <= {1'b0, 8'h02};
            6'd5  : set_data <= {1'b0, 8'h01};
            6'd6  : set_data <= {1'b0, 8'h80}; // Line 1 Addr 0
            
            // Line 1 Data (16 Chars)
            6'd7  : set_data <= {1'b1, line_1[127:120]};
            6'd8  : set_data <= {1'b1, line_1[119:112]};
            6'd9  : set_data <= {1'b1, line_1[111:104]};
            6'd10 : set_data <= {1'b1, line_1[103:96]};
            6'd11 : set_data <= {1'b1, line_1[95:88]};
            6'd12 : set_data <= {1'b1, line_1[87:80]};
            6'd13 : set_data <= {1'b1, line_1[79:72]};
            6'd14 : set_data <= {1'b1, line_1[71:64]};
            6'd15 : set_data <= {1'b1, line_1[63:56]};
            6'd16 : set_data <= {1'b1, line_1[55:48]};
            6'd17 : set_data <= {1'b1, line_1[47:40]};
            6'd18 : set_data <= {1'b1, line_1[39:32]};
            6'd19 : set_data <= {1'b1, line_1[31:24]};
            6'd20 : set_data <= {1'b1, line_1[23:16]};
            6'd21 : set_data <= {1'b1, line_1[15:8]};
            6'd22 : set_data <= {1'b1, line_1[7:0]};

            // Line 2 Addr 0x40
            6'd23 : set_data <= {1'b0, 8'hC0};

            // Line 2 Data (16 Chars)
            6'd24 : set_data <= {1'b1, line_2[127:120]};
            6'd25 : set_data <= {1'b1, line_2[119:112]};
            6'd26 : set_data <= {1'b1, line_2[111:104]};
            6'd27 : set_data <= {1'b1, line_2[103:96]};
            6'd28 : set_data <= {1'b1, line_2[95:88]};
            6'd29 : set_data <= {1'b1, line_2[87:80]};
            6'd30 : set_data <= {1'b1, line_2[79:72]};
            6'd31 : set_data <= {1'b1, line_2[71:64]};
            6'd32 : set_data <= {1'b1, line_2[63:56]};
            6'd33 : set_data <= {1'b1, line_2[55:48]};
            6'd34 : set_data <= {1'b1, line_2[47:40]};
            6'd35 : set_data <= {1'b1, line_2[39:32]};
            6'd36 : set_data <= {1'b1, line_2[31:24]}; 
            6'd37 : set_data <= {1'b1, line_2[23:16]};
            6'd38 : set_data <= {1'b1, line_2[15:8]};
            6'd39 : set_data <= {1'b1, line_2[7:0]};
            
            default: set_data <= {1'b1, 8'h20}; 
        endcase
    end
end

assign LCD_RS   = set_data[8];
assign LCD_RW   = 1'b0;
assign LCD_DATA = set_data[7:0];

endmodule
