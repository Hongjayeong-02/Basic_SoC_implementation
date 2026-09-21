`timescale 1ns/1ps

module uart_core (
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_enable,
        input   wire    [15:0]  i_baudDiv,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,

        input   wire            i_txWrEn,
        input   wire    [7:0]   i_txData,

        input   wire            i_rxRdEn,

        input   wire            i_uartRx,
        output  wire            o_uartTx,

        output  wire            o_txFifoFull,
        output  wire            o_txFifoEmpty,
        output  wire    [4:0]   o_txFifoCount,

        output  wire            o_txReady,
        output  wire            o_txBusy,
        output  wire            o_txDone,

        output  wire    [7:0]   o_rxData,

        output  wire            o_rxFifoFull,
        output  wire            o_rxFifoEmpty,
        output  wire    [4:0]   o_rxFifoCount,

        output  wire            o_rxValid,
        output  wire            o_rxBusy,

        output  wire            o_parityErr,
        output  wire            o_frameErr,
        output  wire            o_falseStart
);


wire            w_tick16;


// ---------------------------------------------------------
// Baud Generator
// ---------------------------------------------------------
uart_baud_gen uut_baud_gen (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (i_enable),
        .i_baudDiv      (i_baudDiv),

        .o_tick16       (w_tick16)
);


// ---------------------------------------------------------
// TX FIFO + UART TX
// ---------------------------------------------------------
uart_tx_fifo uut_tx_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),

        .i_wrEn         (i_txWrEn),
        .i_wrData       (i_txData),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_fifoFull     (o_txFifoFull),
        .o_fifoEmpty    (o_txFifoEmpty),
        .o_fifoCount    (o_txFifoCount),

        .o_txReady      (o_txReady),
        .o_txBusy       (o_txBusy),
        .o_txDone       (o_txDone),
        .o_uartTx       (o_uartTx)
);


// ---------------------------------------------------------
// UART RX + RX FIFO
// ---------------------------------------------------------
uart_rx_fifo uut_rx_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),
        .i_uartRx       (i_uartRx),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .i_rdEn         (i_rxRdEn),

        .o_rdData       (o_rxData),

        .o_fifoFull     (o_rxFifoFull),
        .o_fifoEmpty    (o_rxFifoEmpty),
        .o_fifoCount    (o_rxFifoCount),

        .o_rxValid      (o_rxValid),
        .o_rxBusy       (o_rxBusy),

        .o_parityErr    (o_parityErr),
        .o_frameErr     (o_frameErr),
        .o_falseStart   (o_falseStart)
);


endmodule
