`timescale 1ns/1ps

module tb_bcd_to_7seg;

reg	[31:0]	i_bcd;

wire	[6:0]	o_seg;

bcd_to_7seg u_bcd_to_7seg (
	.i_bcd(i_bcd),
	.o_seg(o_seg)
);

initial begin
	i_bcd = 32'd0;

	#10 i_bcd = 32'd1;
	#10 i_bcd = 32'd2;
	#10 i_bcd = 32'd3;
	#10 i_bcd = 32'd4;
	#10 i_bcd = 32'd5;
	#10 i_bcd = 32'd6;
	#10 i_bcd = 32'd7;
	#10 i_bcd = 32'd8;
	#10 i_bcd = 32'd9;

	#10 i_bcd = 32'd10;

	#10 $finish;

end

initial begin
	$dumpfile("./bcd_to_7seg.vcd");
	$dumpvars(0, tb_bcd_to_7seg  );
end

initial begin
	$monitor(
		"TIME = %0t | BCD = %d | SEG = %b ",
		$time, i_bcd, o_seg
	);
end

endmodule
