`timescale 1ns/1ps

module tb_register;

reg i_rst_n;
reg i_clk;

reg i_in1;
reg [31:0] i_in2;

wire o_out1;
wire [31:0] o_out2;

register uut (
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_in1(i_in1),
	.i_in2(i_in2),
	.o_out1(o_out1),
	.o_out2(o_out2)
);

always #5 i_clk = ~i_clk;

initial begin
	$dumpfile("./register.vcd");
	$dumpvars(0, uut);
end

initial begin
	i_rst_n = 1'b0;
	i_clk = 1'b0;
	i_in1 = 1'b0;
	i_in2 = 32'h00000000;

	#20
	i_rst_n = 1'b1;

	#10
	i_in1 = 1'b1;

	#10
	i_in2 = 32'h12345678;

	#20
	i_in1 = 1'b0;
	i_in2 = 32'hAAAAAAAA;

 	#20
	i_rst_n = 1'b0;

	#20
	i_in1 = 1'b1;
	i_in2 = 32'hFFFFFFFF;

	#20
	i_rst_n = 1'b1;

	#20
	i_in2 = 32'h87654321;

	#50
	$finish;
end
endmodule
