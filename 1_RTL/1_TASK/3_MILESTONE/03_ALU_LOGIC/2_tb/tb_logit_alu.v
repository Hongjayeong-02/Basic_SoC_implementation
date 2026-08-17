`timescale 1ns/1ps

module tb_logit_alu ;

reg [7:0] i_a 	;
reg [7:0] i_b 	;
reg [2:0] i_sel	;

wire [7:0] o_result ;


logit_alu u_logit_alu (
	.i_a	  (i_a	   ),
	.i_b	  (i_b	   ),
	.i_sel	  (i_sel   ),
	.o_result (o_result)
);


initial begin

	// AND : 100 + 50 = 150
	i_a	= 8'd100;
	i_b 	= 8'd50;
	i_sel	= 3'b000;
	#10;

	// SUB : 100 - 50 = 50
	i_sel = 3'b001;
	#10

	// AND : 64 & 32 = 0
	i_a	= 8'd64;
	i_b 	= 8'd32;
	i_sel	= 3'b010;
	#10;

	// OR : 64 | 32 = 96
	i_sel	= 3'b011;
	#10;

	// XOR : 64 ^ 32 = 96
	i_sel	= 3'b100;
	#10;

	// ADD : 200 + 55 = 255
	i_a	= 8'd200;
	i_b	= 8'd55;
	i_sel	= 3'b000;
	#10;

	$finish;

end


initial begin

	$dumpfile("./logit_alu.vcd"	);
	$dumpvars(0, tb_logit_alu	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %d | B = %d | SEL = %b | RESULT = %d",
		$time, i_a, i_b, i_sel, o_result
	);

end


endmodule
