`timescale 1ns/1ps

module tb_parity;

reg	[31:0] 	i_din	;

wire		o_even	;
wire		o_odd	;

parity u_parity (
	.i_din	(i_din	),
	.o_even	(o_even	),
	.o_odd	(o_odd	)
);

initial begin
	i_din = 32'h0000_0000;

	#10 i_din = 32'h0000_0001;
	#10 i_din = 32'h0000_0003;
	#10 i_din = 32'hFFFF_FFFF;
	#10 i_din = 32'hAAAA_AAAA;

	#10 $finish;
end

initial begin
	$dumpfile("./parity.vcd");
	$dumpvars(0, tb_parity	);
end

initial begin
	$monitor(
		"TIME = %0t | DIN = %h | EVEN = %b | ODD = %b ",
		$time, i_din, o_even, o_odd
	);
end

endmodule
