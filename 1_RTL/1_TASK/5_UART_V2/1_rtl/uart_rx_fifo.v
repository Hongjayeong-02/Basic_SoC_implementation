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
wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;

wire    [7:0]   w_fifoRdData;
wire            w_fifoFull;
wire            w_fifoEmpty;
wire    [4:0]   w_fifoCount;

wire            w_fifoWrEn;


// ---------------------------------------------------------
// UART RX
// ---------------------------------------------------------
uart_rx uut_rx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (i_tick16),
        .i_uartRx       (i_uartRx),

        .i_data7        (i_data7),
        .i_parityMode   (i_parityMode),
        .i_stop2        (i_stop2),

        .o_rxData       (w_rxData),
        .o_rxValid      (w_rxValid),
        .o_rxBusy       (w_rxBusy),

        .o_parityErr    (w_parityErr),
        .o_frameErr     (w_frameErr),
        .o_falseStart   (w_falseStart)
);


// ---------------------------------------------------------
// RX FIFO Write Enable
// ---------------------------------------------------------
assign w_fifoWrEn = w_rxValid && !w_fifoFull;


// ---------------------------------------------------------
// RX FIFO
// ---------------------------------------------------------
uart_fifo uut_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_wrEn         (w_fifoWrEn),
        .i_wrData       (w_rxData),

        .i_rdEn         (i_rdEn),

        .o_rdData       (w_fifoRdData),
        .o_full         (w_fifoFull),
        .o_empty        (w_fifoEmpty),
        .o_count        (w_fifoCount)
);


// ---------------------------------------------------------
// Outputs
// ---------------------------------------------------------
assign o_rdData     = w_fifoRdData;

assign o_fifoFull   = w_fifoFull;
assign o_fifoEmpty  = w_fifoEmpty;
assign o_fifoCount  = w_fifoCount;

assign o_rxValid    = w_rxValid;
assign o_rxBusy     = w_rxBusy;

assign o_parityErr  = w_parityErr;
assign o_frameErr   = w_frameErr;
assign o_falseStart = w_falseStart;


endmodule
