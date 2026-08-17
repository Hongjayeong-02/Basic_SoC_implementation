`timescale 1ns/1ps

module tb_05_uart_calculator;


reg	i_clk	;
reg	i_rst_n	;
reg	i_rx	;

wire	o_tx	;


top_uart_calculator u_top (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_rx	(i_rx	),
	.o_tx	(o_tx	)
);


always #5 i_clk = ~i_clk;


// UART 9600 baud -> 1 bit = 104.166 us

task uart_send_byte;

	input [7:0] data;

	integer i;

	begin

		// Start bit
		i_rx = 1'b0;
		#104166;

		// Data bit 0 ~ 7
		for (i = 0; i < 8; i = i + 1) begin

			i_rx = data[i];
			#104166;

		end

		// Stop bit
		i_rx = 1'b1;
		#104166;

		// IDLE GAP
		#100000;

	end


endtask


initial begin

	i_clk = 1'b0;
	i_rst_n = 1'b0;
	i_rx = 1'b1;

	#100;

	i_rst_n = 1'b1;

	#100000;

	// I -> Instruction / S -> Signed / F6 -> operand A / * -> Multiply
	// 02 -> operand B / = -> Execute 
	
	// test 1
	// ISF6*02 = EC
	uart_send_byte("I");
	uart_send_byte("S");
	uart_send_byte("F");
	uart_send_byte("6");
	uart_send_byte(8'h2A);
	uart_send_byte("0");
	uart_send_byte("2");
	uart_send_byte("=");

	#3000000;

	// test 2
	// IU10/04 = 02
	uart_send_byte("I");
	uart_send_byte("U");
	uart_send_byte("1");
	uart_send_byte("0");
	uart_send_byte(8'h2F);
	uart_send_byte("0");
	uart_send_byte("4");
	uart_send_byte("=");

	#3000000;

	// test 3
	// ISF0*02 = 00
	uart_send_byte("I");
	uart_send_byte("S");
	uart_send_byte("F");
	uart_send_byte("0");
	uart_send_byte(8'h2A);
	uart_send_byte("0");
	uart_send_byte("2");
	uart_send_byte("=");

	#3000000;
	
	$finish;

end


endmodule
