`timescale 1ns/1ps

module comparator_8 (
	i_a	,
	i_b	,
	o_eq	,
	o_gt	,
	o_lt
);


input	[7:0]	i_a;
input	[7:0]	i_b;

output		o_eq;
output		o_gt;
output		o_lt;


assign o_eq = (i_a == i_b);
assign o_gt = (i_a > i_b);
assign o_lt = (i_a < i_b);


endmodule
