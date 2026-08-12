`timescale 1ns/1ps

module tb_priority_encoder;

reg 	[31:0] 	i_din	;

wire 	[4:0] 	o_code	;
wire		o_valid	;

priority_encoder u_priority_encoder (
	.i_din	(i_din	),
	.o_code	(o_code	),
	.o_valid(o_valid)
);

initial begin
	i_din = 32'h0000_0000;

	#10;
	i_din = 32'h0000_0001;

	#10;
	i_din = 32'h0000_0009;
	
	#10;
	i_din = 32'h8000_0001;

	#10;
	i_din = 32'hFFFF_FFFF;

	#10;
	$finish;

end

initial begin
	$dumpfile("../priority_encoder.vcd"	);
	$dumpvars(0, tb_priority_encoder	);
end

initial begin
	$monitor (
		"TIME = %t | DIN = %h | CODE = %d | VALID = %b ",
		$time	,
		i_din	,
		o_code	,
		o_valid
	);
end

endmodule
