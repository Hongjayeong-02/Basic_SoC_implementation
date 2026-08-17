`timescale 1ns/1ps

module or_8 (
	i_a	,
	i_b	,
	o_or	
);

input	[7:0]	i_a	;
input	[7:0]	i_b	;

output	[7:0]	o_or	;


assign o_or = i_a | i_b ;


endmodule
