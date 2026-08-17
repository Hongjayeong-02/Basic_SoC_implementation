`timescale 1ns/1ps

module tb_uart_rx;

reg	i_clk	;
reg 	i_rst_n	;
reg	i_rx	;

wire [7:0] 	o_data ;
wire		o_valid;


uart_rx u_uart_rx (
	.i_clk	(i_clk		),
	.i_rst_n(i_rst_n	),
	.i_rx	(i_rx		),
	.o_data	(o_data		),
	.o_valid(o_valid	)
);


always #5 i_clk = ~i_clk;


initial begin

	i_clk 	= 1'b0;
	i_rst_n = 1'b0;
	i_rx 	= 1'b1;

	#20;
	i_rst_n	= 1'b1;

	// UART START BIT
	#10;
	i_rx = 1'b0;

	// DATA : 8'b01010101
	#10;
	i_rx = 1'b1;
	#10;
	i_rx = 1'b0;
	#10;
	i_rx = 1'b1;
	#10;
	i_rx = 1'b0;
	#10;
	i_rx = 1'b1;
	#10;
	i_rx = 1'b0;
	#10;
	i_rx = 1'b1;
	#10;
	i_rx = 1'b0;

	// STOP BIT
	#10;
	i_rx = 1'b1;

	#20;

	$finish;

end


initial begin
	
	$dumpfile("./uart_rx.vcd" 	);
	$dumpvars(0, tb_uart_rx		);

end


initial begin

	$monitor(
		"TIME = %0t | RX = %b | DATA = %h | VALID = %b",	
		$time, i_rx, o_data, o_valid
	);

end


endmodule
	
