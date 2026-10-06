`timescale 1ns / 1ps

module dot(
    input RESET,
    input CLK,
    input TIME_UP,
    input [15:0] SCORE,
    output reg [9:0] DOT_COL,
    output reg [13:0] DOT_RAW
);

reg [3:0] DOT_Data;
reg [3:0] COL_counter;
reg [9:0] dot_col_reg;
reg [6:0] dot_raw_reg;

// SCORE -> 0~9
always @(posedge CLK or posedge RESET) begin
    if (RESET)
        DOT_Data <= 4'd0;
    else
        DOT_Data <= SCORE % 10;
end

always @(posedge CLK or posedge RESET) begin
    if (RESET)
        COL_counter <= 4'd0;
    else if (TIME_UP)
        COL_counter <= COL_counter;   // hold
    else if (COL_counter < 4'd9)
        COL_counter <= COL_counter + 1'b1;
    else
        COL_counter <= 4'd0;
end

always @(*) begin
    case (DOT_Data)

        4'd0: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'b0111110; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'b1111111; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'b1100011; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'b1100011; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'b1100011; end
             5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'b1100011; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'b1100011; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'b1111111; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'b1111111; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'b0111110; end
        endcase
		  
		   4'd1: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'b0001100; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'b0011100; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'b0111100; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'b0001100; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'b0001100; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'b0001100; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'b0001100; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'b0001100; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'b0001100; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'b1111111; end
        endcase

        4'd2: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'b0111110; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'b1111111; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'b0000011; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'b0000110; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'b0001100; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'b0011000; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'b0110000; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'b1111111; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'b1111111; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'b1111111; end
        endcase

        4'd3: case (COL_counter)
             0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'b0111110; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'b1111111; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'b0000011; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'b0000110; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'b0011110; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'b0000110; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'b0000011; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'b1111111; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'b1111111; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'b0111110; end
        endcase
		  
		  4'd4: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'h60; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'h66; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'h66; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'h66; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'h66; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'h66; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'h7f; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'h7f; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'h06; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'h06; end
        endcase
		  
		   4'd5: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'h7f; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'h7f; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'h60; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'h60; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'h7e; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'h7f; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'h03; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'h03; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'h7f; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'h7e; end
        endcase
		  
		  4'd6: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'h60; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'h60; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'h60; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'h60; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'h7e; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'h7f; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'h63; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'h63; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'h7f; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'h3e; end
        endcase

        // ===== 7 =====
        4'd7: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'h7f; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'h7f; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'h63; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'h63; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'h03; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'h03; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'h03; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'h03; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'h03; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'h03; end
        endcase

        // ===== 8 =====
        4'd8: case (COL_counter)
            0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'h3e; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'h7f; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'h63; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'h63; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'h7f; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'h7f; end
            6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'h63; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'h63; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'h7f; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'h3e; end
        endcase

        // ===== 9 =====
        4'd9: case (COL_counter)
             0: begin dot_col_reg=10'b0000000001; dot_raw_reg=~7'h3e; end
            1: begin dot_col_reg=10'b0000000010; dot_raw_reg=~7'h7f; end
            2: begin dot_col_reg=10'b0000000100; dot_raw_reg=~7'h63; end
            3: begin dot_col_reg=10'b0000001000; dot_raw_reg=~7'h63; end
            4: begin dot_col_reg=10'b0000010000; dot_raw_reg=~7'h7f; end
            5: begin dot_col_reg=10'b0000100000; dot_raw_reg=~7'h3f; end
             6: begin dot_col_reg=10'b0001000000; dot_raw_reg=~7'h03; end
            7: begin dot_col_reg=10'b0010000000; dot_raw_reg=~7'h03; end
            8: begin dot_col_reg=10'b0100000000; dot_raw_reg=~7'h03; end
            9: begin dot_col_reg=10'b1000000000; dot_raw_reg=~7'h03; end
        endcase

        default: begin
				dot_col_reg = 10'b0000000000;
            dot_raw_reg = 7'b1111111;
        end
    endcase
end

always @(*) begin
    DOT_COL = dot_col_reg;
    DOT_RAW = {dot_raw_reg, dot_raw_reg};
end

endmodule