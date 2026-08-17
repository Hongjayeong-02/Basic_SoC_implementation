`timescale 1ns/1ps

module tb_divs_8;

reg signed [7:0] i_a ;
reg signed [7:0] i_b ;

wire signed [7:0] o_quotient  ;
wire signed [7:0] o_remainder ;


divs_8 u_divs_8 (
        .i_a        (i_a        ),
        .i_b        (i_b        ),
        .o_quotient (o_quotient ),
        .o_remainder(o_remainder)
);



initial begin

	 // 100 / 10 = 10 remainder 0
	 i_a = 8'sd100;
	 i_b = 8'sd10;
	 
	#10;

	// -100 / 10 = -10 remainder 0
	i_a = -8'sd100;
	i_b = 8'sd10;

	#10;

	// 100 / -10 = -10 remainder 0
	i_a = 8'sd100;
	i_b = -8'sd10;

	#10;

	// -100 / -10 = 10 remainder 0
	i_a = -8'sd100;
	i_b = -8'sd100;

	#10;

	// 7 / 3 = 2 remainder 1
	i_a = 8'd7;
	i_b = 8'd3;

	#10;

	// -7 / 3 = -2 remainder -1
	i_a = -8'd7;
	i_b = 8'd3;

	#10;

	// 7 / -3 = -2 remainder 1
	i_a = 8'd7;
	i_b = -8'd3;

	#10;

	// -7 / -3 = 2 remainder -1
	i_a = -8'd7;
	i_b = -8'd3;

	#10;

	// Divide by zero
	i_a = 8'sd100;
	i_b = 8'sd0;

	#10;

	$finish;

end


initial begin

	$dumpfile("./divs_8.vcd");
	$dumpvars(0, tb_divs_8	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %4d | B = %4d | QUOTIENT = %4d | REMAINDER = %4d",
		$time, i_a, i_b, o_quotient, o_remainder
	);

end


endmodule	
