`timescale 1ns/1ps

module tb_full_adder;

reg 	[31:0] i_a	;
reg 	[31:0] i_b	;
reg 	[31:0] i_cin	;

wire 	[31:0] o_sum	;
wire 	[31:0] o_cout	;

full_adder u_full_adder (
	.i_a 	(i_a	),
	.i_b	(i_b	),
	.i_cin  (i_cin	),
	.o_sum 	(o_sum	),
	.o_cout	(o_cout	)
);

initial begin
	i_a 	= 32'h0000_0000;
	i_b 	= 32'h0000_0000;
	i_cin 	= 32'h0000_0000;

	#10;

	// 0 + 0
	i_a 	= 32'h0000_0000;
	i_b 	= 32'h0000_0000;
	i_cin 	= 32'h0000_0000;

	#10;

	// 1 + 1 + 0
	i_a 	= 32'h0000_0001;
	i_b 	= 32'h0000_0001;
	i_cin	= 32'h0000_0000;

	#10;

	// 1 + 1 + 1
	i_a 	= 32'h0000_0001;
	i_b	= 32'h0000_0001;
	i_cin 	= 32'h0000_0001;

	#10;

	// random pattern
	i_a 	= 32'h1234_5678;
	i_b 	= 32'h8765_4321;
	i_cin 	= 32'h0000_0000;

	#10;

	// all 1
	i_a	= 32'hFFFF_FFFF;
	i_b	= 32'hFFFF_FFFF;
	i_cin	= 32'hFFFF_FFFF;

	#10;

	// alternaitng pattern
	i_a	= 32'hAAAA_AAAA;
	i_b 	= 32'h5555_5555;
	i_cin	= 32'h0000_0000;


	#10;

	$finish;
end

initial begin
	$dumpfile("./full_adder.vcd"	)	;
	$dumpvars(0, tb_full_adder	)	;
end

initial begin
	$monitor(
	"Time = %0t | A = %h | B = %h | CIN = %h | SUM = %h | COUT = %h",
		$time	,
		i_a	, 
		i_b	,
		i_cin	,
		o_sum	,
		o_cout
	);

end

endmodule
