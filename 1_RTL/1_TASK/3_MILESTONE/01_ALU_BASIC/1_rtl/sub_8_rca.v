`timescale 1ns/1ps

module sub_8_rca (
	i_a	,
	i_b	,
	i_bin	,
	o_diff	,
	o_bout
);


input	[7:0]	i_a	;
input	[7:0]	i_b	;
input		i_bin	;

output	[7:0] 	o_diff	;
output		o_bout	;

wire	[8:0]	borrow	;


assign borrow[0] = i_bin;


genvar i;


generate 
	for(i = 0; i < 8; i = i + 1) begin
		assign o_diff[i] = 
			i_a[i] ^ i_b[i] ^ borrow[i];

		assign borrow[i+1] = 
			(~i_a[i] & i_b[i]) | 
			(~i_a[i] & borrow[i]) |
			(i_b[i] & borrow[i]);
		end
endgenerate


assign o_bout = borrow[8];

endmodule
