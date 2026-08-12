`timescale 1ns/1ps

module priority_encoder_8 (
	i_din	, 
	o_code	,
	o_valid
);

input 	[7:0] 	i_din	;

output	[2:0] 	o_code	;
output	      	o_valid	;

reg	[2:0] 	o_code	;
reg 		o_valid	;

always @(*) begin
	o_code 	= 3'd0;
	o_valid = 1'b1;

	casex(i_din) 
		8'b1xxxxxxx: o_code = 3'd7;
		8'b01xxxxxx: o_code = 3'd6;
		8'b001xxxxx: o_code = 3'd5;
		8'b0001xxxx: o_code = 3'd4;
		8'b00001xxx: o_code = 3'd3;
		8'b000001xx: o_code = 3'd2;
		8'b0000001x: o_code = 3'd1;
		8'b00000001: o_code = 3'd0;
		default: begin
			o_code 	= 3'd0;
			o_valid = 1'b0;
		end
	endcase
end
endmodule
