`timescale 1ns/1ps

module interrupt_controller (
	i_int		, 
	i_intAck	,
	o_intId		,
	o_intReq	

);


input [7:0]	i_int		;
input 		i_intAck	;

output [2:0]	o_intId 	;
output 		o_intReq	;

reg [2:0] 	o_intId		;
reg 		o_intReq	;

always @(*) begin
		o_intReq = 1'b0	;
		o_intId	= 3'd0	;

	if (!i_intAck) begin
		case (1'b1)

			i_int[7] : begin
			o_intReq = 1'b1; 
			o_intId = 3'd7;
			end

			i_int[6] : begin
			o_intReq = 1'b1;
			o_intId = 3'd6;
			end

			i_int[5] : begin
			o_intReq = 1'b1;
			o_intId = 3'd5;
			end
	
			i_int[4] : begin
			o_intReq = 1'b1;
			o_intId = 3'd4;
			end

			i_int[3] : begin
			o_intReq = 1'b1;
			o_intId = 3'd3;
			end

			i_int[2] : begin
			o_intReq = 1'b1;
			o_intId = 3'd2;
			end
	
			i_int[1] : begin
			o_intReq = 1'd1;
			o_intId = 3'd1;
			end

			i_int[0] : begin
			o_intReq = 1'b1;
			o_intId = 3'd0;
			end

		endcase
	end
end
			

endmodule
