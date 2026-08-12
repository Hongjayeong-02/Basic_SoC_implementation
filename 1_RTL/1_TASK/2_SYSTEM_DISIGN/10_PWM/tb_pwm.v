`timescale 1ns/1ps

module tb_pwm;
	
reg		i_clk	;
reg 		i_rst_n	;
reg 	[7:0] 	i_duty	;

wire		o_pwm	;


pwm u_pwm (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_duty	(i_duty	),
	.o_pwm	(o_pwm	)
);


initial begin
	i_clk = 1'b0;
	forever #5 i_clk = ~i_clk;
end


initial begin

	i_rst_n = 1'b0;
	i_duty 	= 8'd0;

	#10 i_rst_n = 1'b1;

	// 25%
	#10 i_duty = 8'd64;

	// 50%
	#2560 i_duty = 8'd128;
	
	// 75%
	#2560 i_duty = 8'd192;

	// 100%
	#2560 i_duty = 8'd255;

	#2560 $finish;

end


initial begin
	$dumpfile("./pwm.vcd"	);
	$dumpvars(0, tb_pwm	);
end


initial begin
	$monitor(
		"TIME = %0t | DUTY = %d | PWM = %b",
		$time, i_duty, o_pwm
	);
end


endmodule
