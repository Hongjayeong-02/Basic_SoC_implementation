`timescale 1ns/1ps

module top_uart_calculator (
	i_clk	,
	i_rst_n	,
	i_rx	,
	o_tx
);

input		i_clk	    ; 
input		i_rst_n	    ;
input		i_rx	    ;
 
output		o_tx	    ;

wire		w_tick      ; 

wire	[7:0]	w_rx_data   ;
wire		w_rx_valid  ;

wire	[7:0]	w_a	    ;
wire	[7:0] 	w_b	    ;
wire	[1:0]	w_sel	    ;
wire		w_start	    ;

wire	[7:0]	w_result    ;

wire	[7:0]	w_enc_data  ;
wire		w_enc_valid ;

wire		w_tx_busy   ;


// Baud Generator

baud_gen u_baud_gen (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.o_tick	(w_tick	)
);


// UART Rx 9600

uart_rx_9600 u_uart_rx_9600 (
	.i_clk	(i_clk		),
	.i_rst_n(i_rst_n	),
	.i_rx	(i_rx		),
	.i_tick	(w_tick		),

	.o_data	(w_rx_data	),
	.o_valid(w_rx_valid	)
);


// Calculator Controller

calculator u_calculator (
	.i_clk	(i_clk		),
	.i_rst_n(i_rst_n	),

	.i_data	(w_rx_data	),
	.i_valid(w_rx_valid	),

	.o_a	(w_a	),
	.o_b	(w_b	),
	.o_sel	(w_sel	),
	.o_start(w_start)
);


// ALU

alu_8 u_alu_8 (
	.i_a	 (w_a	  ),
	.i_b	 (w_b	  ),
	.i_sel	 (w_sel	  ),
	.o_result(w_result)
);


// Result encoder

encoder u_encoder (
	.i_result(w_result),
	.i_valid (w_start ),

	.o_data	 (w_enc_data ),
	.o_valid (w_enc_valid)
);


// UART Tx 9600

uart_tx_9600 u_uart_tx_9600 (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),

	.i_data	(w_enc_data ),
	.i_valid(w_enc_valid),
	.i_tick	(w_tick	    ),

	.o_tx	(o_tx	  ),
	.o_busy (w_tx_busy)
);


endmodule	
