`timescale 1ns/1ps

module alu (
	i_a	,
	i_b 	,
	i_op	,
	o_y	,
	o_zero
);

input	[31:0] 	i_a	;
input	[31:0] 	i_b	;
input	[2:0]	i_op	;

output	[31:0] 	o_y	;
output		o_zero	;

reg	[31:0]	o_y	;


always @(*) begin

	case(i_op)
		
		3'b000: o_y = i_a + i_b;
		3'b001: o_y = i_a - i_b;
		3'b010: o_y = i_a & i_b;
		3'b011: o_y = i_a | i_b;
		3'b100: o_y = i_a ^ i_b;
		3'b101: o_y = i_a << i_b[4:0];
		3'b110: o_y = i_a >> i_b[4:0];
		3'b111: o_y = (i_a < i_b) ? 32'd1 : 32'd0;

		default: o_y = 32'd0;
	endcase
end

assign o_zero = (o_y == 32'd0);

endmodule
