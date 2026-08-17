`timescale 1ns/1ps

module tb_uart_tx;


reg		i_clk	;
reg		i_rst_n	;
reg	[7:0]	i_data	;
reg		i_valid	;

wire		o_tx	;
wire		o_busy	;


uart_tx u_uart_tx (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_data (i_data	),
	.i_valid(i_valid),
	.o_tx	(o_tx	),
	.o_busy	(o_busy	)
);
	

always #5 i_clk = ~i_clk;


initial begin

	i_clk   = 1'b0;
	i_rst_n = 1'b0;

	i_data  = 8'd0;
	i_valid = 1'b0;

	#20;
	i_rst_n = 1'b1;

	// ASCII '5'
	#10;
	i_data  = 8'h35;
	i_valid	= 1'b1;

	#10;
	i_valid = 1'b0;

	#120;

	$finish;

end


initial begin
	$dumpfile("./uart_tx.vcd");
	$dumpvars(0, tb_uart_tx  );
end


initial begin
	$monitor(
		"TIME = %0t | DATA = %h | VALID = %b | TX = %b | BUSY = %b",
		$time, i_data, i_valid, o_tx, o_busy
	);
end


endmodule
