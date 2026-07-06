`timescale 1ns/1ps

module tb_bcd_to_7seg;

reg 	[31:0	] i_bcd;
wire 	[6:0	] o_seg;

bcd_to_7seg uut (
	.i_bcd(i_bcd),
	.o_seg(o_seg)
);

initial begin
	$dumpfile("./bcd_to_7seg.vcd"	);
	$dumpvars(0, tb_bcd_to_7seg	);
end

initial begin
	$monitor("Time=%0t | i_bcd Input=%b | Seven Segment Output=%b", $time, i_bcd, o_seg);

	i_bcd = 32'd0; #10;
	i_bcd = 32'd1; #10;
	i_bcd = 32'd2; #10;
	i_bcd = 32'd3; #10;
	i_bcd = 32'd4; #10;
	i_bcd = 32'd5; #10;
	i_bcd = 32'd6; #10;
	i_bcd = 32'd7; #10; 
	i_bcd = 32'd8; #10;
	i_bcd = 32'd9; #10;

	i_bcd = 32'd10; #10;
	i_bcd = 32'd11; #10;
	i_bcd = 32'd12; #10;
	i_bcd = 32'd13; #10;
	i_bcd = 32'd14; #10;
	i_bcd = 32'd15; #10;

	$finish;
end 	

endmodule
