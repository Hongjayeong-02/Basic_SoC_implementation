`timescale 1ns/1ps

module uart_loopback (
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_enable,
        input   wire    [15:0]  i_baudDiv,

        input   wire            i_txValid,
        input   wire    [7:0]   i_txData,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,

        output  wire            o_txReady,
        output  wire            o_txBusy,
        output  wire            o_txDone,

        output  wire    [7:0]   o_rxData,
        output  wire            o_rxValid,
        output  wire            o_rxBusy,

        output  wire            o_parityErr,
        output  wire            o_frameErr,
        output  wire            o_falseStart,

        output  wire            o_uartTx
);


wire            w_tick16;
wire            w_uartTx;


// Baud Generator
uart_baud_gen uut_baud_gen (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (i_enable),
        .i_baudDiv      (i_baudDiv),

        .o_tick16       (w_tick16)
);


// UART TX
uart_tx uut_tx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),

        .i_txValid      (i_txValid),
        .i_txData       (i_txData),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_txReady      (o_txReady),
        .o_txBusy       (o_txBusy),
        .o_txDone       (o_txDone),
        .o_uartTx       (w_uartTx)
);


// UART RX
uart_rx uut_rx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),
        .i_uartRx       (w_uartTx),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_rxData       (o_rxData),
        .o_rxValid      (o_rxValid),
        .o_rxBusy       (o_rxBusy),

        .o_parityErr    (o_parityErr),
        .o_frameErr     (o_frameErr),
        .o_falseStart   (o_falseStart)
);


assign o_uartTx = w_uartTx;


endmodule
