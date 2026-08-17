`timescale 1ns/1ps

module divs_8 (
	i_a		,
	i_b	 	,
	o_quotient	,
	o_remainder
);


input   signed [7:0] i_a ;
input   signed [7:0] i_b ;


output  signed [7:0] o_quotient  ;
output  signed [7:0] o_remainder ;


assign o_quotient  = (i_b != 0) ? (i_a / i_b) : 8'sd0;
assign o_remainder = (i_b != 0) ? (i_a % i_b) : 8'sd0;


endmodule
