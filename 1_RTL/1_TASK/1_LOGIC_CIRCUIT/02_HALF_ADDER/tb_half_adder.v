`timescale 1ns/1ps

module tb_half_adder	;

reg 	[31:0] i_a	;
reg 	[31:0] i_b	;

wire 	[31:0] o_sum	;
wire 	[31:0] o_carry	;

half_adder u_half_adder (
	.i_a		(i_a	),
	.i_b		(i_b	),
	.o_sum		(o_sum	),
	.o_carry	(o_carry)
);

initial begin
	i_a = 32'h0000_0000;
	i_b = 32'h0000_0000;

	#10;

	// 0 + 0 
	i_a = 32'h0000_0000;
	i_b = 32'h0000_0000;

	#10;

	// 1 + 1
	i_a = 32'h0000_0001;
	i_b = 32'h0000_0001;

	#10;

	i_a = 32'h1234_5678;
	i_b = 32'h8765_4321;

	#10;

	// all 1
	i_a = 32'hFFFF_FFFF;
	i_b = 32'hFFFF_FFFF;	

	#10;
	
	// alternating pattern
	i_a = 32'hAAAA_AAAA;
	i_b = 32'h5555_5555;

	#10;

	$finish;
end

initial begin
	$dumpfile("./half_adder.vcd")	;
	$dumpvars(0, tb_half_adder)	;
end

initial begin
	$monitor(
	"TIME = %0t | A = %h | B = %h | SUM = %h | CARRY = %h",
	$time	,
	i_a	,
	i_b	,
	o_sum	,
	o_carry
);
end

endmodule


