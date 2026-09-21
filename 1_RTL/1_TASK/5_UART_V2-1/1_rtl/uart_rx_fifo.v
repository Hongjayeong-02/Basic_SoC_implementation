`timescale 1ns/1ps

module uart_rx_fifo (
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_tick16,
        input   wire            i_uartRx,

        input   wire            i_data7,
        input   wire    [1:0]   i_parityMode,
        input   wire            i_stop2,

        input   wire            i_rdEn,

        output  wire    [7:0]   o_rdData,

        output  wire            o_fifoFull,
        output  wire            o_fifoEmpty,
        output  wire    [4:0]   o_fifoCount,

        output  wire            o_rxValid,
        output  wire            o_rxBusy,

        output  wire            o_parityErr,
        output  wire            o_frameErr,
        output  wire            o_falseStart
);


wire    [7:0]   w_rxData;
wire            w_fifoWrEn;


// RX data가 들어오고 FIFO가 안 찼으면 저장
assign w_fifoWrEn = o_rxValid && !o_fifoFull;


// UART RX
uart_rx uut_rx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (i_tick16),
        .i_uartRx       (i_uartRx),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_rxData       (w_rxData),
        .o_rxValid      (o_rxValid),
        .o_rxBusy       (o_rxBusy),

        .o_parityErr    (o_parityErr),
        .o_frameErr     (o_frameErr),
        .o_falseStart   (o_falseStart)
);


// RX FIFO
uart_fifo uut_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_wrEn         (w_fifoWrEn),
        .i_wrData       (w_rxData),

        .i_rdEn         (i_rdEn),

        .o_rdData       (o_rdData),

        .o_full         (o_fifoFull),
        .o_empty        (o_fifoEmpty),
        .o_count        (o_fifoCount)
);


endmodule
