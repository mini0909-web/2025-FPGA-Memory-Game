module motor(
    input           RESET,
    input           CLK,
    input           GAME_ACTIVE,
    input           TIME_UP,
    output reg [3:0] MOTOR_OUT
);

reg [31:0] cnt_motor;
reg sw_dir;
reg sw_on;

wire [31:0] motor_speed;
assign motor_speed = 32'd960000;

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        sw_dir <= 1'b0;
        sw_on <= 1'b0;
    end else begin
        sw_dir <= sw_dir;
        sw_on <= GAME_ACTIVE;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        cnt_motor <= 32'd0;
        MOTOR_OUT <= 4'b1001;
    end
    else if (sw_on && !TIME_UP) begin
        if (cnt_motor < motor_speed - 1)
            cnt_motor <= cnt_motor + 1;
        else
            cnt_motor <= 32'd0;

		case (cnt_motor)
            0:
                if (sw_dir) MOTOR_OUT <= 4'b0101;
                else        MOTOR_OUT <= 4'b1001;
            (motor_speed / 4):
                if (sw_dir) MOTOR_OUT <= 4'b0110;
                else        MOTOR_OUT <= 4'b1010;
            (motor_speed / 4) * 2:
                if (sw_dir) MOTOR_OUT <= 4'b1010;
                else        MOTOR_OUT <= 4'b0110;
				(motor_speed / 4) * 3:
                if (sw_dir) MOTOR_OUT <= 4'b1001;
                else        MOTOR_OUT <= 4'b0101;
        endcase
    end
    else begin
        cnt_motor <= 32'd0;
        MOTOR_OUT <= 4'b0000;
    end
end

endmodule