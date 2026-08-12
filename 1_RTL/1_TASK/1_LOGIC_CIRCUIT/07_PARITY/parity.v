`timescale 1ns/1ps

module parity (
	i_din	,
	o_even	,
	o_odd
);

input	[31:0] 	i_din	;

output		o_even	;
output		o_odd	;

assign o_even = ~^i_din	;
assign o_odd  = ^i_din	;

endmodule
