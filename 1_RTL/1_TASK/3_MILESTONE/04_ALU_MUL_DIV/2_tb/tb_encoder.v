`timescale 1ns/1ps

module tb_encoder;

reg	[7:0]	i_result;
reg		i_valid	;

wire	[7:0] 	o_data	;
wire	[7:0]	o_valid	;


encoder u_encoder (
	.i_result(i_result	),
	.i_valid (i_valid	),
	.o_data	 (o_data	),
	.o_valid (o_valid	)
);


initial begin

	i_result = 8'd0;
	i_valid	 = 1'b0;

	// 5 -> ASCII '5'
	#10;
	i_result = 8'd5;
	i_valid  = 1'b1;

	#10;
	i_valid  = 1'b0;

	// 9 -> ASCII '9'
	#10;
	i_result = 8'd9;
	i_valid	 = 1'b1;

	#10;
	i_valid  = 1'b0;

	#20 $finish;

end


initial begin
	$dumpfile("./encoder.vcd");
	$dumpvars(0, tb_encoder	 );
end


initial begin
	$monitor(
		"TIME = %0t | RESULT = %d | DATA = %h | VALID = %b",
		$time, i_result, o_data, o_valid
	);
end


endmodule
