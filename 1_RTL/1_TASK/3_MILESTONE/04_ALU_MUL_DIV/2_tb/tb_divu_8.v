`timescale 1ns/1ps

module tb_divu_8;

reg     [7:0]   i_a     ;
reg     [7:0]   i_b	;

wire	[7:0]	o_quotient	;
wire	[7:0]	o_remainder	;


divu_8 u_divu_8 (
	.i_a	(i_a	),
	.i_b	(i_b	),
	.o_quotient	(o_quotient	),
	.o_remainder	(o_remainder	)
);



initial begin

	i_a = 8'd0;	
	i_b = 8'd1;

	#10;

	// 100 / 10 = 10 remainder 0
	i_a = 8'd100;
	i_b = 8'd10;

	#10;

	// 100 / 30 = 3 remainder 0
	i_a = 8'd100;
	i_b = 8'd30;

	#10;

	// 255 / 15 = 17 remainder 0
	i_a = 8'd255;	
	i_b = 8'd15;

	#10;

	// 7 / 3 = 2 remainder 1
	i_a = 8'd7;
	i_b = 8'd3;

	#10;

	// 5 / 8 = 0 remainder 5
	i_a = 8'd5;
	i_b = 8'd8;

	#10;

	// Divide by zero
	i_a = 8'd100;
	i_b = 8'd0;

	#10;

	$finish;

end


initial begin

	$dumpfile("./divu_8.vcd");
	$dumpvars(0, tb_divu_8	);

end


initial begin
	
	$monitor(
		"TIME = %0t | A = %3d | B = %3d | QUOTIENT = %3d | REMAINDER = %3d",
		$time, i_a, i_b, o_quotient, o_remainder
	);

end


endmodule	
