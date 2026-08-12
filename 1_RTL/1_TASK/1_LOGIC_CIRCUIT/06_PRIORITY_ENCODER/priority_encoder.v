`timescale 1ns/1ps

module priority_encoder (
	i_din	,
	o_code	,
	o_valid	
);

input 	[31:0]	i_din	;

output	[4:0] 	o_code	;
output		o_valid	;

wire	[2:0] 	w_code0	;
wire 	[2:0]	w_code1	;
wire	[2:0]	w_code2	;
wire 	[2:0]	w_code3	;

wire		w_valid0;
wire		w_valid1;
wire		w_valid2;
wire		w_valid3;


priority_encoder_8 u_pe0 ( 
	.i_din	(i_din[7:0]	),
	.o_code	(w_code0	),
	.o_valid(w_valid0	)	
);

priority_encoder_8 u_pe1 (
	.i_din	(i_din[15:8]	),
	.o_code	(w_code1	),
	.o_valid(w_valid1	)
);

priority_encoder_8 u_pe2 (
	.i_din	(i_din[23:16]	),
	.o_code	(w_code2	),
	.o_valid(w_valid2	)
);

priority_encoder_8 u_pe3 (
	.i_din	(i_din[31:24]	),
	.o_code	(w_code3	),
	.o_valid(w_valid3	)
);

assign o_valid = w_valid0 | w_valid2 | w_valid3;

assign o_code = 
	w_valid3 ? {2'b11, w_code3} :
	w_valid2 ? {2'b10, w_code2} : 
	w_valid1 ? {2'b01, w_code1} : 
	w_valid0 ? {2'b00, w_code0} :
		    5'd0;

endmodule	
