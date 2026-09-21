`timescale 1ns/1ps

module uart_core #(
        // Per spec sec.8.3 / sec.16: default FIFO depth is 8 for both
        // TX and RX, parameterizable if a design needs more headroom.
        parameter TX_FIFO_DEPTH = 8,
        parameter RX_FIFO_DEPTH = 8
)(
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_enable,
        input   wire            i_txEn,
        input   wire            i_rxEn,

        input   wire    [15:0]  i_baudDiv,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,
        input   wire            i_loopbackEn,

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
        output  wire            o_rxParityErrData,
        output  wire            o_rxFrameErrData,

        output  wire            o_rxFifoFull,
        output  wire            o_rxFifoEmpty,
        output  wire    [4:0]   o_rxFifoCount,

        output  wire            o_rxValid,
        output  wire            o_rxBusy,

        output  wire            o_parityErr,
        output  wire            o_frameErr,
        output  wire            o_falseStart,

        output  wire            o_rxOverflow
);


wire            w_tick16;

wire            w_uartTx;
wire            w_uartRx;

wire            w_txWrEn;


assign w_txWrEn = i_enable &&
                  i_txEn &&
                  i_txWrEn;


assign o_uartTx = (i_enable && i_txEn) ?
                  w_uartTx :
                  1'b1;


assign w_uartRx = (!i_enable || !i_rxEn) ?
                  1'b1 :
                  (i_loopbackEn ? w_uartTx : i_uartRx);


// Baud Generator
uart_baud_gen uut_baud_gen (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (i_enable),
        .i_baudDiv      (i_baudDiv),

        .o_tick16       (w_tick16)
);


// TX
uart_tx_fifo #(
        .FIFO_DEPTH     (TX_FIFO_DEPTH)
) uut_tx_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),

        .i_wrEn         (w_txWrEn),
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

        .o_uartTx       (w_uartTx)
);


// RX
uart_rx_fifo #(
        .FIFO_DEPTH     (RX_FIFO_DEPTH)
) uut_rx_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),
        .i_uartRx       (w_uartRx),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .i_rdEn         (i_rxRdEn),

        .o_rdData       (o_rxData),
        .o_rdParityErr  (o_rxParityErrData),
        .o_rdFrameErr   (o_rxFrameErrData),

        .o_fifoFull     (o_rxFifoFull),
        .o_fifoEmpty    (o_rxFifoEmpty),
        .o_fifoCount    (o_rxFifoCount),

        .o_rxValid      (o_rxValid),
        .o_rxBusy       (o_rxBusy),

        .o_parityErr    (o_parityErr),
        .o_frameErr     (o_frameErr),
        .o_falseStart   (o_falseStart),

        .o_rxOverflow   (o_rxOverflow)
);


endmodule
