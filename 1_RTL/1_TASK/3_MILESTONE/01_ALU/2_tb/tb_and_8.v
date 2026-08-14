`timescale 1ns/1ps

module tb_and_8;

reg	[7:0]	i_a	;
reg	[7:0]	i_b	;

wire	[7:0]	o_and	;


and_8 u_and_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_and	(o_and	)
);


initial begin
	i_a = 8'b0000_0000;
	i_b = 8'b0000_0000;

	// 10101010 & 11110000 = 101000000
	#10;
	i_a = 8'b1010_1010;
	i_b = 8'b1111_0000;

	// FF & 0F = 0F
	#10;
	i_a = 8'hFF;
	i_b = 8'h0F;

	// 55 & AA = 00
	#10;
	i_a = 8'h55;
	i_b = 8'hAA;

	// F0 & 0F = 00
	#10;
	i_a = 8'hF0;
	i_b = 8'h0F;

	#10 $finish;
end


initial begin
	$dumpfile("./and_8.vcd"	);
	$dumpvars(0, tb_and_8	);
end


initial begin
	$monitor(
		"TIME = %0t | A = %h | B = %h | AND = %h",
		$time, i_a, i_b, o_and
	);
end


endmodule
