`timescale 1ns/1ps

module tb_top_uart_calculator;

reg	i_clk	;
reg	i_rst_n	;
reg	i_rx	;

wire	o_tx	;


top_uart_calculator u_uart_calculator (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_rx	(i_rx	),
	.o_tx	(o_tx	)
);

always #5 i_clk = ~i_clk;


// send byte to UART RX
task send_uart_byte;
	input [7:0] data;
	integer i;

	begin
		// START BIT
		i_rx = 1'b0;
		#10;

		// DATA : LSB FIRST
		for (i = 0; i < 8; i = i + 1) begin
			i_rx = data[i];
			#10;
		end

		// STOP BIT
		i_rx = 1'b1;
		#10;
	end

endtask


initial begin
	i_clk 	= 1'b0;
	i_rst_n = 1'b0;
	i_rx	= 1'b1;

	#20;
	i_rst_n = 1'b1;


	// 5 + 3 
	
	send_uart_byte(8'h35);	// '5'
	
	#20;

	send_uart_byte(8'h2B);	// '+'

	#20;

	send_uart_byte(8'h33);	// '3'

	#100;

	$finish;

end


initial begin
	$dumpfile("./top_uart_calculator.vcd"	);
	$dumpvars(0, tb_top_uart_calculator	);
end


endmodule	 		
