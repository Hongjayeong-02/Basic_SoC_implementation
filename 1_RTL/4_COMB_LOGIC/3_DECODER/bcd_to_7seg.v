`timescale 1ns/1ps

module bcd_to_7seg (

	i_bcd,
	o_seg

);

input 		[3:0	] i_bcd;
output reg 	[6:0	] o_seg;

always @(*) begin
	case (i_bcd)

	4'b0000: o_seg = 7'b1111110; // 0
	4'b0001: o_seg = 7'b0110000; // 1
	4'b0010: o_seg = 7'b1101101; // 2 
	4'b0011: o_seg = 7'b1111001; // 3
	4'b0100: o_seg = 7'b0110011; // 4
	4'b0101: o_seg = 7'b1011011; // 5
	4'b0110: o_seg = 7'b1011111; // 6
	4'b0111: o_seg = 7'b1110000; // 7
	4'b1000: o_seg = 7'b1111111; // 8
	4'b1001: o_seg = 7'b1111011; // 9
	
	default: o_seg = 7'b0000000; // OFF
	
	endcase
end

endmodule
