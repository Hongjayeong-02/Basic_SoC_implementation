`timescale 1ns/1ps

module alu (
	i_a	,
	i_b	,
	i_op	,
	o_result
);

input [7:0] i_a		;
input [7:0] i_b		;
input [2:0] i_op	;

output reg [7:0] o_result;


always @(*) begin
	case(i_op)

		// ADD
		3'b000 : o_result = i_a + i_b;

		// SUB
		3'b001 : o_result = i_a - i_b;

		// OR
		3'b011 : o_result = i_a & i_b;

		// XOR
		3'b100 : o_result = i_a ^ i_b;

		// NOT
		3'b101 : o_result = ~i_a;

		// Shift Left
		3'b110 : o_result = i_a << 1;

		// Shift Right
		3'b111 : o_result = i_a >> 1;

		default : o_result = 8'h00;

	endcase
end

endmodule
