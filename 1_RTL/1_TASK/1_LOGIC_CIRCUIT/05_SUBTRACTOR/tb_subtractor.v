`timescale 1ns/1ps

module tb_subtractor		;

reg 	[31:0] 	i_a		;
reg 	[31:0] 	i_b		;

wire 	[31:0] 	o_diff		;
wire		o_borrow	;

subtractor u_subtractor (
	.i_a		(i_a		),
	.i_b		(i_b		),
	.o_diff		(o_diff		),
	.o_borrow	(o_borrow	)
);

initial begin
	// initialize
	i_a = 32'h0000_0000;
	i_b = 32'h0000_0000;

	#10;

	// 5 - 3 = 2
	i_a = 32'h0000_0005;
	i_b = 32'h0000_0003;
	
	#10;

	// 10 - 5 = 5
	i_a = 32'h0000_000A;
	i_b = 32'h0000_0005;

	#10;

	// 0x12345678 - ox11111111
	i_a = 32'h1234_5678;
	i_b = 32'h1111_1111;

	#10;

	// 0 - 1
	i_a = 32'h0000_0000;
	i_b = 32'h0000_0001;

	#10;

	// 1 - 5
	i_a = 32'h0000_0001;
	i_b = 32'h0000_0005;

	#10;

	// FFFFFFFF - 1
	i_a = 32'hFFFF_FFFF;
	i_b = 32'h0000_0001;

	#10;

	// same value
	i_a = 32'hAAAAA_AAAA;
	i_b = 32'hAAAAA_AAAA;

	#10;

	$finish;
end

initial begin
	$dumpfile("./subtractor.vcd"	);
	$dumpvars(0, tb_subtractor	);
end

initial begin
	$monitor(
		"Time = %0t | A = %h | B = %h | DIFF = %h | BORROW = %b",
		$time	,
		i_a	,
		i_b	,
		o_diff	,
		o_borrow
	);
end

endmodule
