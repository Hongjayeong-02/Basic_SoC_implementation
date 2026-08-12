`timescale 1ns/1ps

module bcd_to_7seg (
	i_bcd,
	o_seg
);

input	[31:0]	i_bcd;

output	[6:0] 	o_seg;

reg 	[6:0]	o_seg;

always @(*) begin

	case (i_bcd[3:0])
	
		4'd0: o_seg = 7'b1111110;
		4'd1: o_seg = 7'b0110000;
		4'd2: o_seg = 7'b1101101;
		4'd3: o_seg = 7'b1111001;
		4'd4: o_seg = 7'b0110011;
		4'd5: o_seg = 7'b1011011;
		4'd6: o_seg = 7'b1011111;
		4'd7: o_seg = 7'b1110000;
		4'd8: o_seg = 7'b1111111;
		4'd9: o_seg = 7'b1111011;

		default: o_seg = 7'b0000000;

	endcase
end

endmodule

