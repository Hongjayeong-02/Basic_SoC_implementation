`timescale 1ns/1ps

module divu_8 (
	i_a		,
	i_b		,
	o_quotient	,
	o_remainder
);

input	[7:0]	i_a	;
input	[7:0]	i_b	;

output	[7:0] 	o_quotient	;
output	[7:0]	o_remainder	;


assign o_quotient  = (i_b != 8'd0) ? (i_a / i_b) : 8'd0;
assign o_remainder = (i_b != 8'd0) ? (i_a % i_b) : 8'd0;


endmodule
