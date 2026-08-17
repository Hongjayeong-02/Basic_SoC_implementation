`timescale 1ns/1ps

module decoder (
	i_data		,
	i_valid		,
	o_operand	,
	o_operator	,
	o_valid
);

input	[7:0]	i_data	;
input		i_valid	;

output reg [7:0] o_operand ;
output reg [7:0] o_operator;
output reg 	 o_valid   ;

parameter OP_ADD = 2'b00;
parameter OP_SUB = 2'b01;
parameter OP_AND = 2'b10;
parameter OP_OR	 = 2'b11;


always @(*) begin

	o_operand  = 8'd0;
	o_operator = 2'b00;
	o_valid	   = 1'b0;

	if(i_valid) begin

		case(i_data)

			8'h28: begin
				// '+'
				o_operator = OP_ADD;
				o_valid    = 1'b1;
			end 


			8'h2D: begin
				// '-'
				o_operator = OP_SUB;
				o_valid	   = 1'b1;
			end

			
			8'h26: begin
				// '&'
				o_operator = OP_AND;
				o_valid	   = 1'b1;
			end

			
			8'h7C: begin
				// '|'
				o_operator = OP_OR;
				o_valid	   = 1'b1;
			end


			default: begin

				if((i_data >= 8'h30) &&
				   (i_data <= 8'h39)) begin

					// ASCII '0' ~ '9'
					o_operand = i_data - 8'h30;
					o_valid	  = 1'b1;
				end
			end
		endcase
	end
end


endmodule
