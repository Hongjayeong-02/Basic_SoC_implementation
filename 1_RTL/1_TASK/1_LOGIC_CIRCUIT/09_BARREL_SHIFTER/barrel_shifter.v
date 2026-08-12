`timescale 1ns/1ps

module barrel_shifter (
	i_din	, 
	i_shamt	,
	i_dir	,
	o_dout	
);

input	[31:0] 	i_din	;
input	[4:0]  	i_shamt	;
input		i_dir	;

output	[31:0]	o_dout	;

wire 	[31:0]	w_s1	;
wire	[31:0]	w_s2	;
wire	[31:0]	w_s4	;
wire	[31:0]	w_s8	;

assign 	w_s1 = i_shamt[0] ?
		(i_dir ? {1'b0, i_din[31:1]} :
			 {i_din[31:0], 1'b0}):
		i_din;

assign	w_s2 = i_shamt[1] ?
		(i_dir ? {2'b0, i_din[31:2]} :
			 {w_s1[29:0], 2'b0}) :
		w_s1;

assign 	w_s4 = i_shamt[2] ? 
		(i_dir ? {4'b0, i_din[31:4]} :
			 {w_s2[27:0], 4'b0}) :
		w_s2;

assign	w_s8 = i_shamt[3] ?
		(i_dir ? {8'b0, i_din[31:8]} :
			 {w_s4[23:0], 8'b0}) :
		w_s4;

assign o_dout = i_shamt[4] ? 
		(i_dir ? {16'b0, w_s8[31:16]} :
			 {w_s8[15:0], 16'b0}) : 
		w_s8;

endmodule
