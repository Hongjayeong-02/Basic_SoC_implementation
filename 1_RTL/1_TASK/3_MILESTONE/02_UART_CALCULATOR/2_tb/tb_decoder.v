`timescale 1ns/1ps

module tb_decoder;

reg 	[7:0] 	i_data		;
reg 	[7:0] 	i_valid		;

wire 	[7:0] 	o_operand	;
wire 	[7:0] 	o_operator	;
wire		o_valid		;


decoder u_decoder (
	.i_data		(i_data		),
	.i_valid	(i_valid	),
	.o_operand	(o_operand	),
	.o_operator	(o_operator	),
	.o_valid	(o_valid	)		
);


initial begin
	
	i_data 	= 8'd0;
	i_valid = 1'b0;

	// ASCII '5'
	#10;
	i_data  = 8'h35;
	i_valid = 1'b1;

	#10;
	i_valid = 1'b0;

	// '+'
	#10;
	i_data  = 8'h28;
	i_valid = 1'b1;

	#10;
	i_valid = 1'b0;

	// ASCII '3'
	#10;
	i_data  = 8'h2D;
	i_valid = 1'b1;

	#10;
	i_valid = 1'b0;

	// '-'
	i_data  = 8'h2D;
	i_valid = 1'b1;

	#10;
	i_valid = 1'b0;

	#10 $finish;

end


initial begin
	$dumpfile("./decoder.vcd");
	$dumpvars(0, tb_decoder	 );
end


initial begin
	$monitor(
		"TIME = %0t | DATA = %h | VALID = %b | OPERAND = %d | OPERATOR = %b | O_VALID = %b",
		$time, i_data, i_valid, o_operand, o_operator, o_valid
	);
end


endmodule  
	  
