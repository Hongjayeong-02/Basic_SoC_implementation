`timescale 1ns/1ps

module register(

	i_rst_n,
	i_clk,

	i_in1,
	i_in2,

	o_out1,
	o_out2

);

input i_rst_n;
input i_clk;

input i_in1;
input [31:0] i_in2;

output reg o_out1;
output reg [31:0] o_out2;

always @(posedge i_clk or negedge i_rst_n) begin

	if(i_rst_n)
		o_out1 <= 1'b0;
	else
		o_out1 <= i_in1;
end

always @(posedge i_clk or negedge i_rst_n) begin

	if(i_rst_n)
		o_out2 <= 32'h00000000;
	else
		o_out2 <= i_in2;
end

endmodule

