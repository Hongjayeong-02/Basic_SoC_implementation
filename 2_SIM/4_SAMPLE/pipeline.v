`timescale 1ns / 1ps

module pipeline(

input clk,
input rst_n,
input [9:0] in1,
input [9:0] in2,
input [9:0] in3,
input state,
output reg [11:0] out
);

reg [10:0] temp_sum; // 11*bit_reg
reg [9:0] in3_save;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp_sum <= 11'd0;
        in3_save <= 10'd0;
    end
    else if (!state) begin
            temp_sum <= in1 + in2;
            in3_save <= in3;
        end
    end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        out <= 12'd0;
    else if (!state)
        out <= temp_sum + in3_save;
end
endmodule
