`timescale 1ns/1ps

module tb_not_8  ;


reg  [7:0] i_a	 ;

wire [7:0] o_not ;


not_8 u_not_8 (
	.i_a	(i_a	),
	.o_not	(o_not	)
);


initial begin

	i_a = 8'h0000_0000;

	// ~00 = FF
	#10;
	i_a = 8'h00;

	// ~FF = 00
	#10;
	i_a = 8'hFF;

	// ~AA = 55
	#10;
	i_a = 8'hAA;

	// ~55 = AA
	#10;
	i_a = 8'h55;

	// ~F0 = 0F
	#10;
	i_a = 8'hF0;

	#10 $finish;

end


initial begin

	$dumpfile("./not_8.vcd"	);
	$dumpvars(0, tb_not_8	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %h | NOT = %h",
		$time, i_a, o_not
	);

end


endmodule
