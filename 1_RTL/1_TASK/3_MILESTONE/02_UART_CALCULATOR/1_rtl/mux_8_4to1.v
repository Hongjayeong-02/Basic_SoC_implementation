`timescale 1ns/1ps

module mux_8_4to1 (
	i_a	,
	i_b	,
	i_c	,
	i_d	,
	i_sel	,
	o_y
);


input	[7:0] i_a	;
input	[7:0] i_b	;
input 	[7:0] i_c	;
input	[7:0] i_d	;
input	[1:0] i_sel	;

output reg [7:0] o_y	;


always @(*) begin
	
	case(i_sel)
		2'b00: o_y = i_a;
		2'b01: o_y = i_b;
		2'b10: o_y = i_c;
		2'b11: o_y = i_d;
	endcase

end


endmodule
