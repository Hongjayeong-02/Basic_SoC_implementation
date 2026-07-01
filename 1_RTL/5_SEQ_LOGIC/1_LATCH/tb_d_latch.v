`timescale 1ns/1ps

module tb_d_latch;

reg 		i_clk	;
reg [31:0] 	i_d	;

wire [31:0] 	o_q	;

d_latch uut(
	.i_clk(i_clk)	,
	.i_d(i_d)	,
	.o_q(o_q)
);

always #5 i_clk = ~i_clk;

initial begin
	$dumpfile("./d_latch.vcd");
	$dumpvars(0, uut);
end

initial begin
	i_clk = 1'b0		;
	i_d = 32'h00000000	;

	#15 i_d = 32'h12345678	;
	#20 i_d = 32'hAAAAAAAA	;
	#10 i_d = 32'h55555555	;
	#10 i_d = 32'hFFFFFFFF	;
	#10 i_d = 32'h0000FFFF	;
	#10 i_d = 32'h87654321	;

	#50
	$finish;
end

endmodule
