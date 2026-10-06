`timescale 1ns / 1ps

module led_ctrl(
    input RESET,
    input CLK,
    input Mode_Switch,
    input [8:0] KEY,
    input TIME_UP, 

    input EASY,
    input NORMAL,
    input HARD,
    input VHARD,
     
    output wire [7:0] LED,
    output reg [15:0] SCORE,
    output reg GAME_ACTIVE,       
    output reg GAME_INPUT_ACTIVE, 
    output reg GAME_OVER,
    output reg GAME_SUCCESS       
);

    reg [7:0] regLED;

    // ==========================================
    // 1. RANDOMNESS
    // ==========================================
    reg [15:0] lfsr;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) 
            lfsr <= 16'hACE1;
        else 
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    // ==========================================
    // 2. KEY MAPPING
    // ==========================================
    wire [8:0] KEY_REVERSED;
    assign KEY_REVERSED = {KEY[7],KEY[0],KEY[1],KEY[2],KEY[3],KEY[4],KEY[5],KEY[6],KEY[8]};

    reg [2:0] pressed_idx;
    reg pressed_valid;
    
    reg [8:0] prev_key_sync;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) prev_key_sync <= 0;
        else prev_key_sync <= KEY;
    end
    wire key_posedge = (KEY != 0) && (KEY != prev_key_sync);

    always @(*) begin
        pressed_idx = 0;
        pressed_valid = 0;
        if      (KEY[7])          begin pressed_idx=3'd0; pressed_valid=1; end 
        else if (KEY_REVERSED[1]) begin pressed_idx=3'd1; pressed_valid=1; end 
        else if (KEY_REVERSED[2]) begin pressed_idx=3'd2; pressed_valid=1; end 
        else if (KEY_REVERSED[3]) begin pressed_idx=3'd3; pressed_valid=1; end 
        else if (KEY_REVERSED[4]) begin pressed_idx=3'd4; pressed_valid=1; end
        else if (KEY_REVERSED[5]) begin pressed_idx=3'd5; pressed_valid=1; end
        else if (KEY_REVERSED[6]) begin pressed_idx=3'd6; pressed_valid=1; end
        else if (KEY_REVERSED[7]) begin pressed_idx=3'd7; pressed_valid=1; end 
    end

    // ==========================================
    // 3. PARAMETERS & DIFFICULTY (Latching)
    // ==========================================
    reg [2:0] pattern [0:2]; 
    reg [24:0] cnt;
    reg [31:0] SHOW_TIME; 
    
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            SHOW_TIME <= 32'd15_000_000;
        end else if (state == ST_IDLE) begin
            if      (EASY)   SHOW_TIME <= 32'd25_000_000;
            else if (NORMAL) SHOW_TIME <= 32'd15_000_000;
            else if (HARD)   SHOW_TIME <= 32'd8_000_000;
            else if (VHARD)  SHOW_TIME <= 32'd4_000_000;
        end
    end
    
    parameter BLINK_PERIOD  = 25'd6_000_000; 
    parameter DEBOUNCE_TIME = 25'd10_000_000; 
    parameter SUCCESS_DELAY = 25'd25_000_000; 

    // States
    localparam ST_IDLE          = 4'd0;
    localparam ST_GEN_SEQ       = 4'd1;
    localparam ST_SHOW          = 4'd2;
    localparam ST_GAP           = 4'd3;
    localparam ST_INPUT         = 4'd4;
    localparam ST_CHECK         = 4'd5; 
    localparam ST_WAIT_DEBOUNCE = 4'd6; 
    localparam ST_SUCCESS       = 4'd7; 
    localparam ST_SUCCESS_ANIM  = 4'd8; 
    localparam ST_FAIL_ANIM     = 4'd9;
    localparam ST_FAIL_STOP     = 4'd10;

    reg [3:0] state; 
    reg [1:0] seq_idx;   
    reg [2:0] input_idx; 

    // 힌트 기능을 위한 추가 레지스터
    reg is_hint;
    reg ms_sync, ms_prev;
    always @(posedge CLK) begin
        ms_sync <= Mode_Switch;
        ms_prev <= ms_sync;
    end
    wire ms_falling = (ms_prev == 1'b1) && (ms_sync == 1'b0);

    // ==========================================
    // 4. MAIN FSM
    // ==========================================
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            state <= ST_IDLE;
            SCORE <= 0;
            GAME_ACTIVE <= 0;
            GAME_INPUT_ACTIVE <= 0;
            GAME_OVER <= 0;
            GAME_SUCCESS <= 0;
            regLED <= 8'hFF;
            cnt <= 0;
            seq_idx <= 0;
            input_idx <= 0;
            is_hint <= 0;
        end else begin
            case (state)
                ST_IDLE: begin
                    GAME_ACTIVE <= 0;
                    GAME_OVER <= 0;
                    GAME_SUCCESS <= 0;
                    GAME_INPUT_ACTIVE <= 0;
                    regLED <= 8'hFF;
                    is_hint <= 0;
                    if (EASY || NORMAL || HARD || VHARD) begin
                        state <= ST_GEN_SEQ; 
                    end
                end

                ST_GEN_SEQ: begin
                    GAME_ACTIVE <= 1;
                    GAME_SUCCESS <= 0; 
                    state <= ST_SHOW;
                    pattern[0] <= lfsr[2:0]; 
                    pattern[1] <= lfsr[5:3]; 
                    pattern[2] <= lfsr[8:6];
                    seq_idx <= 0;
                    input_idx <= 0;
                    cnt <= 0;
                end

                ST_SHOW: begin
                    GAME_INPUT_ACTIVE <= 0;
                    regLED <= ~(8'd1 << pattern[seq_idx]);
                    if (cnt < SHOW_TIME) cnt <= cnt + 1;
                    else begin
                        cnt <= 0;
                        regLED <= 8'hFF;
                        state <= ST_GAP;
                    end
                end
                
                ST_GAP: begin
                    regLED <= 8'hFF; 
                    if (cnt < (SHOW_TIME >> 1)) cnt <= cnt + 1;
                    else begin
                        cnt <= 0;
                        if (seq_idx < 2) begin
                            seq_idx <= seq_idx + 1;
                            state <= ST_SHOW;
                        end else begin
                            // 힌트 모드였다면 다시 입력 상태로, 아니면 정상 진행
                            state <= ST_INPUT;
                            if (!is_hint) input_idx <= 0;
                            is_hint <= 0;
                            cnt <= 0; 
                        end
                    end
                end

                ST_INPUT: begin
                    GAME_INPUT_ACTIVE <= 1;
                    if (cnt < (BLINK_PERIOD >> 1)) regLED <= 8'h00; 
                    else                           regLED <= 8'hFF; 
                    if (cnt < BLINK_PERIOD) cnt <= cnt + 1;
                    else cnt <= 0;

                    // 힌트 발생: Mode_Switch가 1->0으로 변할 때
                    if (ms_falling) begin
                        is_hint <= 1;
                        seq_idx <= 0;
                        state <= ST_SHOW;
                        cnt <= 0;
                    end
                    else if (key_posedge && pressed_valid) begin
                        if (pressed_idx == pattern[input_idx]) begin
                            state <= ST_CHECK;
                        end else begin
                            state <= ST_FAIL_ANIM;
                        end
                    end 
                end
                
                ST_CHECK: begin
                    input_idx <= input_idx + 1; 
                    state <= ST_WAIT_DEBOUNCE;
                    cnt <= 0;
                end
                
                ST_WAIT_DEBOUNCE: begin
                    GAME_INPUT_ACTIVE <= 1;
                    regLED <= 8'hFF; 
                    if (cnt < DEBOUNCE_TIME) begin
                        cnt <= cnt + 1;
                    end else begin
                        if (KEY == 0) begin
                            cnt <= 0;
                            if (input_idx >= 3) begin
                                state <= ST_SUCCESS;
                            end else begin
                                state <= ST_INPUT; 
                            end
                        end
                    end
                end
                
                ST_SUCCESS: begin
                    SCORE <= SCORE + 1;
                    GAME_SUCCESS <= 1;
                    cnt <= 0;
                    regLED <= 8'h00; 
                    state <= ST_SUCCESS_ANIM;
                end
                
                ST_SUCCESS_ANIM: begin
                    if (cnt < SUCCESS_DELAY) cnt <= cnt + 1;
                    else begin
                         cnt <= 0;
                         state <= ST_GEN_SEQ; 
                    end
                end

                ST_FAIL_ANIM: begin
                    GAME_ACTIVE <= 0;
                    GAME_OVER <= 1;
                    regLED <= 8'h00; 
                    state <= ST_FAIL_STOP;
                end

                ST_FAIL_STOP: begin
                    GAME_ACTIVE <= 0; 
                    GAME_OVER <= 1;   
                    regLED <= 8'h00; 
                end
                
                default: state <= ST_IDLE;
            endcase
        end
    end
    
    assign LED = (!Mode_Switch) ? regLED : 8'hFF;

endmodule