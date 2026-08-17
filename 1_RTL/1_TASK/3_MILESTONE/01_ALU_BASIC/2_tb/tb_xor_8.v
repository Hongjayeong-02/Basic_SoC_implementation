`timescale 1ns/1ps

module tb_xor_8		;

reg  [7:0] i_a		;
reg  [7:0] i_b		;

wire [7:0] o_xor	;


xor_8 u_xor_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_xor	(o_xor	)
);


initial begin

	i_a = 8'h0000_0000;
	i_b = 8'h0000_0000;

	// AA ^ F0 = 5A
	#10;
	i_a = 8'hAA;
	i_b = 8'hF0;

	// FF ^ 0F = F0
	#10;
	i_a = 8'hFF;
	i_b = 8'h0F;

	// 55 ^ AA = FF
	#10;
	i_a = 8'h55;
	i_b = 8'hAA;

	// F0 ^ 0F = FF
	#10;
	i_a = 8'hF0;
	i_b = 8'h0f;

	#10 $finish;

end


initial begin

	$dumpfile("./xor_8.vcd"	);
	$dumpvars(0, tb_xor_8	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %h | B = %h | XOR = %h",
		$time, i_a, i_b, o_xor
	);

end


endmodule
