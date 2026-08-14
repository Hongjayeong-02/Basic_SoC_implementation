`timescale 1ns/1ps

module tb_or_8	;

reg [7:0] i_a	;
reg [7:0] i_b	;

wire [7:0] o_or	;


or_8 u_or_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_or	(o_or	)
);


initial begin

	i_a = 8'h0000_0000;
	i_b = 8'h0000_0000;

	// AA | F0 = F4
	#10;
	i_a = 8'hAA;
	i_b = 8'hF0;

	// FF | 0F = FF
	#10;
	i_a = 8'hFF;
	i_b = 8'h0F;	

	// 55 | AA = FF
	#10;
	i_a = 8'h55;
	i_b = 8'hAA;

	// F0 | 0F = FF
	#10;
	i_a = 8'hF0;
	i_b = 8'h0F;

	#10 $finish;

end


initial begin

	$dumpfile("./or_8.vcd"	);
	$dumpvars(0, tb_or_8	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %h | B = %h | OR = %h",
		$time, i_a, i_b, o_or
	);

end


endmodule
