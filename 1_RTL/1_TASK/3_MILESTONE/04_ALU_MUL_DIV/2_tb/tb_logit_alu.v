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

	// AND 
	i_a	= 8'd100;
	i_b 	= 8'd50;
	i_sel	= 3'b000;
	#10;

	// SUB 
	i_sel = 3'b001;
	#10

	// AND
	i_a	= 8'd64;
	i_b 	= 8'd32;
	i_sel	= 3'b010;
	#10;

	// OR 
	i_a	= 8'd64;
	i_b 	= 8'd32;
	i_sel	= 3'b011;

	#10;

	// XOR 
	i_a 	= 8'd64;
	i_b 	= 8'd32;
	i_sel	= 3'b100;

	#10;

	// MUL 
	i_a	= 8'd15;
	i_b	= 8'd15;
	i_sel	= 3'b101;

	#10;

	// DIVU
	i_a 	= 8'd100;
	i_b 	= 8'd30;
	i_sel	= 3'b110;

	#10;

	// DIVS
	i_a 	= -8'sd7;
	i_b	= 8'sd3;
	i_sel	= 3'b111;

	#10;

	$finish;

end


initial begin

	$dumpfile("./logit_alu.vcd"	);
	$dumpvars(0, tb_logit_alu	);

end


initial begin

	$monitor(
		"TIME = %0t | A = %4d | B = %4d | SEL = %03b | RESULT = %4d",
		$time, 
		i_a,
		i_b,
		i_sel,
		o_result
	);

end


endmodule
