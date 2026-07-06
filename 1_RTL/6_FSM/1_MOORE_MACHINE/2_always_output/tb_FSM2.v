`timescale 1ns/1ps

module tb_FSM2();

reg clk		;
reg rst_n	;
reg go		;
reg ws		;

wire rd		;
wire ds		;

FSM2 DUT (
	.clk(clk)	,
	.rst_n(rst_n)	,
	.go(go)		,
	.ws(ws)		,
	.rd(rd)		,
	.ds(ds)
);

always #5 clk = ~clk;

initial begin

end

 
endmodule
