`timescale 1ns/1ps

module sum_8_rca (
	i_a	,
	i_b	,
	i_cin	,
	o_sum	,
	o_cout	
);

input	[7:0]	i_a	;
input 	[7:0] 	i_b	;
input		i_cin	;


output 	[7:0]	o_sum	;
output		o_cout	;


wire 	[8:0] 	carry	;


assign carry[0] = i_cin	;


genvar i;


generate 
	for(i = 0; i < 8; i = i + 1) begin
		assign o_sum[i] = i_a[i] ^ i_b[i] ^ carry[i];

		assign carry[i+1] = 
			(i_a[i] & i_b[i]) |
			(i_a[i] & carry[i]) |
			(i_b[i] & carry[i]);
		end
endgenerate


assign o_cout = carry[8];


endmodule
