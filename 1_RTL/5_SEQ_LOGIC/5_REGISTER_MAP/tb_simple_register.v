`timescale 1ns/1ps

module tb_simple_register;

reg clk;
reg rst_n;
reg i_wen;
reg [31:0] i_wdata;
wire [31:0] o_rdata;

simple_register uut(
	.clk(clk),
	.rst_n(rst_n),
	.i_wen(i_wen),
	.i_wdata(i_wdata),
	.o_rdata(o_rdata)
);

initial begin
	$dumpfile("./simple_register.vcd");
	$dumpvars(0, uut);
end

initial begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

initial begin
	$monitor("T=%0t | rst=%b | wdata=%h | rdata=%h",
	$time,
	rst_n,
	i_wen,
	i_wdata,
	o_rdata);
end

initial begin
	rst_n = 1'b0;
	i_wen = 1'b0;
	i_wdata = 32'h00000000;

	#20 rst_n = 1'b1;

	#10 i_wen = 1'b1;
	i_wdata = 32'h12345678;

	#10 i_wen = 1'b0;

	#20 i_wen = 1'b1;
	i_wdata = 32'hABCDEF12;

	#10 i_wen = 1'b0;

	#20 rst_n = 1'b0;

	#20 rst_n = 1'b1;

	#20 $finish;
end

endmodule	
