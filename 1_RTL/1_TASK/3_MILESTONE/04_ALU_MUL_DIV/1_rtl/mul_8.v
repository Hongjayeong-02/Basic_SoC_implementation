`timescale 1ns/1ps

module mul_8 (
	i_a	,
	i_b	,
	o_result
);

input	[7:0] i_a	;
input	[7:0] i_b	;

output	[15:0]	o_result;


assign o_result = i_a * i_b;


endmodule
