`timescale 1ns/1ps

module ripple_carry_adder(
	i_a	, 
	i_b	, 
	i_cin	,
	o_sum	,
	o_cout	
);

input 	[31:0] i_a		;
input 	[31:0] i_b		;
input	       i_cin		;	

output 	[31:0] o_sum		;
output 	[31:0] o_cout		;

wire 	[32:0] w_carry		;

assign w_carry[0] = i_cin	;

genvar i			;

generate
	for(i=0; i<32; i=i+1) begin: GEN_FULL_ADDER

	full_adder #(
		.WIDTH(1)
	) u_full_adder (
		.i_a	(i_a[i]		),
		.i_b	(i_b[i]		),
		.i_cin	(w_carry[i]	),
		.o_sum	(o_sum[i]	),
		.o_cout	(w_carry[i+1]	)
	);
	end
endgenerate

assign o_cout = w_carry[32]	;

endmodule
