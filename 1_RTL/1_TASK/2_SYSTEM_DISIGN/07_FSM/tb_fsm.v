`timescale 1ns/1ps

module tb_fsm;

reg	i_clk	;
reg	i_rst_n	;
reg 	i_din	;

wire	o_dout	;


fsm u_fsm (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_din	(i_din	),
	.o_dout	(o_dout	)
);

initial begin
	i_clk = 1'b0;
	forever #5 i_clk = ~i_clk;
end

initial begin

	i_rst_n = 1'b0;
	i_din 	= 1'b0;

	#10 i_rst_n = 1'b1;

	// 0011
	#10 i_din = 1'b0;
	#10 i_din = 1'b0;
	#10 i_din = 1'b0;
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;

	// 0
	#10 i_rst_n = 1'b1;

	// 00111
	#10 i_din = 1'b0;
	#10 i_din = 1'b0;
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;

	// 0 
	#10 i_rst_n = 1'b0;

	// 111
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;
	#10 i_din = 1'b1;

	#10 $finish;
end

initial begin
	$dumpfile("./fsm.vcd"	);
	$dumpvars(0, tb_fsm	);
end

initial begin
	$monitor(
		"TIME = %0t | DIN = %b | DOUT = %b",
		$time, i_din, o_dout
	);
end

endmodule
