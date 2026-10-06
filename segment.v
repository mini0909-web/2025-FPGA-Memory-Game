`timescale 1ns / 1ps

module segment(
    input               CLK,
    input               RESET,
    input               GAME_ACTIVE, // top의 .GAME_ACTIVE에 대응
    output  reg [3:0]   FND_COM,
    output  reg [7:0]   FND_DATA,
    output  reg         TIME_UP
);

    reg [31:0] cnt_1s;
    reg sec;

    // ===================================
    // 1. 1초 생성 (GAME_ACTIVE 가 1일 때만 동작)
    // ===================================
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            cnt_1s <= 32'd0;
            sec <= 1'b0;
        end else if (GAME_ACTIVE) begin // GAME_ACTIVE 신호 사용
            if (cnt_1s < 32'd23999999) begin
                cnt_1s <= cnt_1s + 1;
                sec <= 1'b0;
            end else begin
                cnt_1s <= 32'd0;
                sec <= 1'b1;
            end
        end else begin
            // GAME_ACTIVE가 0이면 카운트 일시 정지 및 sec 발생 차단
            sec <= 1'b0;
        end
    end

    // ===================================
    // 2. 4자리 카운터
    // ===================================
    reg [3:0] t_thou, t_hund, t_tens, t_ones;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            t_thou <= 0; t_hund <= 0; t_tens <= 0; t_ones <= 0;
            TIME_UP <= 0;
        end else if (sec) begin
            // 1초마다 증가
            if (t_ones < 9) t_ones <= t_ones + 1;
            else begin
                t_ones <= 0;
                if (t_tens < 9) t_tens <= t_tens + 1;
                else begin
                    t_tens <= 0;
                    if (t_hund < 9) t_hund <= t_hund + 1;
                    else begin
                         t_hund <= 0;
                         if (t_thou < 9) t_thou <= t_thou + 1;
                         else t_thou <= 0;
                    end
                end
            end
        end
    end

    // ===================================
    // 3. 스캐닝 & 잔상 삭제 (Blanking)
    // ===================================
    reg [15:0] cnt64k;
    reg [1:0]  cnt4;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) cnt64k <= 16'd0;
        else cnt64k <= cnt64k + 1;
    end
    
    always @(posedge CLK or posedge RESET) begin
        if (RESET) cnt4 <= 2'b00;
        else if (cnt64k == 16'hFFFF) cnt4 <= cnt4 + 1;
    end
    
    reg [3:0] current_val;
    always @(*) begin
        case (cnt4)
            2'b00: current_val = t_ones;  
            2'b01: current_val = t_tens;  
            2'b10: current_val = t_hund;  
            2'b11: current_val = t_thou; 
            default: current_val = 4'd0;
        endcase
    end

    wire [7:0] seg_decoded;
    bin2seg u_decode (.bin_data(current_val), .seg_data(seg_decoded));

    // 출력 + 간단한 Blanking
    always @(*) begin
        if (cnt64k < 1000) begin 
            FND_COM = 4'b0000; 
            FND_DATA = 8'hFF; 
        end else begin
            FND_DATA = seg_decoded;
            case (cnt4)
                2'b00: FND_COM = 4'b0001; 
                2'b01: FND_COM = 4'b0010; 
                2'b10: FND_COM = 4'b0100; 
                2'b11: FND_COM = 4'b1000; 
                default: FND_COM = 4'b0000;
            endcase
        end
    end

endmodule