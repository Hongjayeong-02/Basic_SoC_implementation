`timescale 1ns/1ps

module and_8 (
	i_a	,
	i_b	,
	o_and
);


input	[7:0]	i_a	;
input	[7:0]	i_b	;

output	[7:0]	o_and	;


assign o_and = i_a & i_b;


endmodule
