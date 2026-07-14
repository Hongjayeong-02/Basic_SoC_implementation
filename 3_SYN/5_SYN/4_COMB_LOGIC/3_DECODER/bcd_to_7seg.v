`timescale 1ns/1ps

module bcd_to_7seg (

	i_bcd,
	o_seg

);

input 		[31:0	] i_bcd;
output reg 	[6:0	] o_seg;

always @(*) begin

	case (i_bcd)

	32'd0: o_seg = 7'b1111110; // 0
	32'd1: o_seg = 7'b0110000; // 1
	32'd2: o_seg = 7'b1101101; // 2 
	32'd3: o_seg = 7'b1111001; // 3
	32'd4: o_seg = 7'b0110011; // 4
	32'd5: o_seg = 7'b1011011; // 5
	32'd6: o_seg = 7'b1011111; // 6
	32'd7: o_seg = 7'b1110000; // 7
	32'd8: o_seg = 7'b1111111; // 8
	32'd9: o_seg = 7'b1111011; // 9
	
	default: o_seg = 7'b0000000; // OFF
	
	endcase
end

endmodule
