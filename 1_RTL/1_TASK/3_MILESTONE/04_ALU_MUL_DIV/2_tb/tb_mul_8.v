`timescale 1ns/1ps

module tb_mul_8;

reg	[7:0]	i_a	;
reg	[7:0]	i_b	;

wire	[15:0]	o_result;


mul_8 u_mul_8 (
	.i_a	 (i_a	  ),
	.i_b	 (i_b	  ),
	.o_result(o_result)
);


initial begin

	i_a = 8'd0;
	i_b = 8'd0;

	#10;

	// 10 * 20 = 200
	i_a = 8'd10;
	i_b = 8'd20;

	#10;

	// 15 * 15 = 225
	i_a = 8'd15;
	i_b = 8'd15;
	
	#10;

	// 100 * 2 = 200
	i_a = 8'd100;
	i_b = 8'd2;

	#10;

	// 255 * 255 = 65025 = 16'hFE01
	i_a = 8'd255;
	i_b = 8'd255;

	#10;

	// 0 * 255 = 0
	i_a = 8'd0;
	i_b = 8'd255;

	#10;

	$finish;

end


initial begin

	$dumpfile("./mul_8.vcd" );
	$dumpvars(0, tb_mul_8	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %3d | B = %3d | RESULT = %5d",
		$time, i_a, i_b, o_result
	);

end


endmodule


