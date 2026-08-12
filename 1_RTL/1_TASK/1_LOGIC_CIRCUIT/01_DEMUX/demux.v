`timescale 1ns/1ps

module demux (
	i_din	,
	i_sel	,
	o_y0	,
	o_y1
);

input [31:0] 	i_din;
input		i_sel;

output reg [31:0] o_y0;
output reg [31:0] o_y1;

always @(*) begin
	o_y0 = 32'b0;
	o_y1 = 32'b0;

	case(i_sel)
		1'b0: begin
			o_y0 = i_din;
		end
		
		1'b1: begin
			o_y1 = i_din;
		end

		default: begin
			o_y0 = 32'b0;
			o_y1 = 32'b0;
		end
	endcase
end

endmodule
