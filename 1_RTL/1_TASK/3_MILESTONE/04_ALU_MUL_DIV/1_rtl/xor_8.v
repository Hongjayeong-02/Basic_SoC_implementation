`timescale 1ns/1ps

module xor_8 (
	i_a	,
	i_b	,
	o_xor
);

input	[7:0]	i_a	;
input	[7:0]	i_b	;

output	[7:0]	o_xor	;


assign o_xor = i_a ^ i_b;


endmodule
