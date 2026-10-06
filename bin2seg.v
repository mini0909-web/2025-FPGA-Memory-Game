`timescale 1ns / 1ps

module bin2seg(
    input      [3:0] bin_data,
    output wire [7:0] seg_data
);

assign seg_data = (bin_data==0)?8'b00000011:
                 (bin_data==1)?8'b10011111:
                 (bin_data==2)?8'b00100101:
                 (bin_data==3)?8'b00001101:
                 (bin_data==4)?8'b10011001:
                 (bin_data==5)?8'b01001001:
                 (bin_data==6)?8'b01000001:
                 (bin_data==7)?8'b00011011:
                 (bin_data==8)?8'b00000001:
                              8'b00001001;

endmodule