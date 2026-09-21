`timescale 1ns/1ps

module uart_core #(
	parameter CLK_FREQ  = 48_000_000,
	parameter BAUD_RATE = 9_600
)(
	input	wire		clk,
	input	wire		rst_n,
	input	wire		i_txValid,
	input	wire	[7:0]	i_txData,
	input	wire		i_uartRx,

	output	wire		o_uartTx,
	output	wire		o_txReady,
	output 	wire		o_txBusy,
	output	wire	[7:0]	o_rxData,
	output	wire		o_rxValid,
	output	wire		o_frameErr
);

wire w_baudTick;

uart_baud_gen #(
	.CLK_FREQ 	(CLK_FREQ),
	.BAUD_RATE	(BAUD_RATE)
) u_uart_baud_gen (
	.clk		(clk),
	.rst_n		(rst_n),
	.o_baudTick	(w_baudTick)
); 

uart_tx u_uart_tx (
	.clk		(clk),
	.rst_n		(rst_n),
	.i_baudTick	(w_baudTick),
	.i_txValid	(i_txValid),
	.i_txData	(i_txData),
	.o_txReady	(o_txReady),
	.o_uartTx	(o_uartTx),
	.o_txBusy	(o_txBusy)
);

uart_rx #(
	.CLK_FREQ	(CLK_FREQ),
	.BAUD_RATE	(BAUD_RATE)
) u_uart_rx (
	.clk		(clk),
	.rst_n		(rst_n),
	.i_uartRx	(i_uartRx),
	.o_rxData	(o_rxData),
	.o_rxValid	(o_rxValid),
	.o_frameErr	(o_frameErr)
);

endmodule

