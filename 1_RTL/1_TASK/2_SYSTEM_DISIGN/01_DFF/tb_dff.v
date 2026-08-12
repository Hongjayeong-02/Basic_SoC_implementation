`timescale 1ns/1ps

module tb_dff;

reg 	   	i_clk	;	
reg  [31:0] 	i_d	;

wire [31:0] 	o_q 	;

dff u_dff (
	.i_clk	(i_clk	),
	.i_d	(i_d	),
	.o_q	(o_q	)
);

initial begin
	i_clk = 1'b0;
	i_d   = 32'h0000_0000;

	#10 i_d = 32'h1234_5678;
	#20 i_d = 32'hAAAA_AAAA;
	#20 i_d = 32'hFFFF_0000;
 	#20 i_d = 32'h5555_5555;

	#20 $finish;
end

always #5 i_clk = ~i_clk;

initial begin
	$dumpfile("./dff.vcd"	);
	$dumpvars(0, tb_dff	);
end

initial begin
	$monitor(
		"TIME = %0t | CLK = %b | D = %h | Q = %h",
		$time, i_clk, i_d, o_q
	);
end

endmodule
