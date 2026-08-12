`timescale 1ns/1ps

module tb_ripple_carry_adder;

reg 	[31:0] 	i_a	;
reg 	[31:0] 	i_b	;
reg		i_cin	;

wire [31:0] 	o_sum	;
wire 		o_cout	;

ripple_carry_adder u_ripple_adder_adder(
	.i_a	(i_a	),
	.i_b	(i_b	),
	.i_cin	(i_cin	),
	.o_sum	(o_sum	),
	.o_cout	(o_cout	)
);

initial begin
	i_a 	= 32'h0000_0000	;
	i_b 	= 32'h0000_0000	;
	i_cin 	= 1'b0		;

	#10			;

	// 1 + 1
	i_a 	= 32'h0000_0001	;
	i_b	= 32'h0000_0001	;
	i_cin 	= 1'b0		;
	
	#10			;

	// 0x12345678 + 0x87654321
	i_a	= 32'h1234_5678	;
	i_b 	= 32'h8765_4321	;
	i_cin	= 1'b0		;

	#10			;	

	// MAX + 1
	i_a	= 32'hFFFF_FFFF	;
	i_b 	= 32'h0000_0001	;
	i_cin 	= 1'b1		;
	
	#10			;
	
	// MAX + MAX
	i_a	= 32'hFFFF_FFFF	;
	i_b	= 32'hFFFF_FFFF	;
	i_cin	= 1'b0		;

	#10			;

	// MAX + MAX + 1
	i_a	= 32'hFFFF_FFFF	;
	i_b 	= 32'hFFFF_FFFF	;
	i_cin	= 1'b1		;

	#10			;

	// alternating pattern
	i_a	= 32'hAAAA_AAAA	;
	i_b 	= 32'h5555_5555	;
	i_cin	= 1'b0		;

	#10			;

	$finish;
end

initial begin
	$dumpfile("./ripple_carry_adder.vcd"	);
	$dumpvars(0, tb_ripple_carry_adder	);
end

initial begin
	$monitor(
		"Time = %0t | A = %h | B = %h | CIN = %b | SUM = %h | COUT = %b",
		$time	,
		i_a	,
		i_b	,
		i_cin	,
		o_sum	,
		o_cout
	);
end

endmodule
