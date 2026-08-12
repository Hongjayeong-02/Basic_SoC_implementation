`timescale 1ns/1ps

module tb_barrel_shifter;

reg 	[31:0] 	i_din	;
reg 	[4:0]	i_shamt	;
reg		i_dir	;

wire 	[31:0]	o_dout	;

barrel_shifter u_barrel_shifter (
	.i_din	(i_din	),
	.i_shamt(i_shamt),
	.i_dir	(i_dir	),
	.o_dout (o_dout	)
);

initial begin
	i_din 	= 32'h0000_0001 ;
	i_shamt = 5'd1		;
	i_dir   = 1'b0		;

	#10;
	i_din	= 32'h0000_0001 ;
	i_shamt = 5'd8		;
	i_dir	= 1'b0		;

	#10;
	i_din	= 32'h8000_0000	;
	i_shamt = 5'd4		;
	i_dir 	= 1'b1		;

	#10;
	i_din 	= 32'h1234_5678	;
	i_shamt = 5'd13		;
	i_dir	= 1'b0		;

	#10
	i_din	= 32'h1234_5678	;
	i_shamt = 5'd13		;
	i_dir	= 1'b1		;

	#10;
	$finish;
end

initial begin
	$dumpfile("./barrel_shifter.vcd");
	$dumpvars(0, tb_barrel_shifter	);
end

initial begin
	$monitor(
		"TIME = %0t | DIN = %h | SHAMT = %d | DIR = %b | DOUT = %h ",
		$time, i_din, i_shamt, i_dir, o_dout
	);
end

endmodule
