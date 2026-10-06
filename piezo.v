`timescale 1ns / 1ps

module piezo(
    input RESET,
    input CLK,
    input GAME_ACTIVE,   
    input GAME_CLEAR,    
    input TIME_UP,       
    output wire BUZZER
);

/* =========================
   Tone Parameters (24MHz clock 기준)
   ========================= */
parameter reg_do  = 16'd11659;
parameter reg_re  = 16'd10388;
parameter reg_mi  = 16'd9253;
parameter reg_sol = 16'd7782;

/* =========================
   Buzzer Signals 
   ========================= */
reg [15:0] b_max; 
reg [15:0] b_cnt; 
reg        b_reg; 

/* =========================
   Music FSM States
   ========================= */
localparam ST_IDLE = 2'd0;
localparam ST_PLAY = 2'd1;
localparam ST_GAP  = 2'd2;

reg [1:0]  state;
reg [24:0] timer;
reg [1:0]  note_idx;

/* =========================
   Sync Flags
   ========================= */
reg p_done; // 전원 후 최초 도레미
reg f_done; // 게임 오버 소리 재생 완료 플래그
reg ga_sync, ga_prev; // GAME_ACTIVE 상태 변화 감지용

/* =========================
   Control FSM (소리 순서 제어)
   ========================= */
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        state    <= ST_IDLE;
        timer    <= 0;
        note_idx <= 0;
        b_max    <= 16'd0;
        p_done   <= 1'b0;
        f_done   <= 1'b0; 
        ga_sync  <= 1'b0;
        ga_prev  <= 1'b0;
    end else begin
        // 신호 동기화 및 엣지 감지
        ga_sync <= GAME_ACTIVE;
        ga_prev <= ga_sync;
        
        // 게임이 다시 시작(GAME_ACTIVE 가 1이 됨)되면, 다음 종료음을 위해 플래그 초기화
        if (ga_sync) f_done <= 1'b0;

        case (state)
            ST_IDLE: begin
                b_max <= 16'd0;
                timer <= 0;
                
                // 1. 전원/리셋 후 최초 1회 도레미
                if (!p_done) begin
                    note_idx <= 0;
                    state <= ST_PLAY;
                    p_done <= 1'b1;
                end
                // 2. 게임 종료 감지 (GAME_ACTIVE 가 1에서 0으로 떨어질 때 또는 TIME_UP 발생)
                else if (((ga_prev == 1'b1 && ga_sync == 1'b0) || TIME_UP) && !f_done) begin
                    note_idx <= 3; // '솔' 위치
                    state <= ST_PLAY;
                    f_done <= 1'b1;
                end
            end

            ST_PLAY: begin
                case (note_idx)
                    2'd0: b_max <= reg_do;
                    2'd1: b_max <= reg_re;
                    2'd2: b_max <= reg_mi;
                    default: b_max <= reg_sol; // note_idx 3일 때 솔
                endcase

                // 게임 오버(솔)는 0.8초간 길게, 시작음은 0.2초씩 짧게
                if (timer < (note_idx == 3 ? 25'd19_200_000 : 25'd4_800_000))
                    timer <= timer + 1'b1;
                else begin
                    timer <= 0;
                    state <= ST_GAP;
                end
            end

            ST_GAP: begin
                b_max <= 16'd0;
                if (timer < 25'd1_200_000)
                    timer <= timer + 1'b1;
                else begin
                    timer <= 0;
                    if (note_idx < 2) begin
                        note_idx <= note_idx + 1'b1;
                        state <= ST_PLAY;
                    end else begin
                        state <= ST_IDLE;
                    end
                end
            end
            default: state <= ST_IDLE;
        endcase
    end
end

/* =========================
   Buzzer Generator (노이즈 방지)
   ========================= */
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        b_cnt <= 16'd0;
    else if (b_max == 16'd0 || b_cnt >= b_max)
        b_cnt <= 16'd0;
    else
        b_cnt <= b_cnt + 1;
end

always @(posedge CLK or posedge RESET) begin
    if (RESET)
        b_reg <= 1'b1; 
    else if (b_max == 16'd0)
        b_reg <= 1'b1; 
    else if (b_cnt == 16'd1) 
        b_reg <= ~b_reg;
end

assign BUZZER = b_reg;

endmodule
