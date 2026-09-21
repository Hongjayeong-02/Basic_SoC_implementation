`timescale 1ns/1ps

// Renamed from uart_v2_top.v (v3 cleanup): the wrapper name was still
// carrying the "v2" tag after the v3 register-map/FIFO/overflow rework,
// which was confusing in regression logs. Purely a name change - same
// single-instance passthrough of uart_apb, now also forwarding the
// STRICT_APB_ERR / TX_FIFO_DEPTH / RX_FIFO_DEPTH parameters.
module uart_v2_top #(
        // Defaults follow the spec: STRICT_APB_ERR off (silent drop is
        // the base behavior, sec.10.2), FIFO depth 8/8 (sec.8.3, sec.16).
        parameter STRICT_APB_ERR = 1'b0,
        parameter TX_FIFO_DEPTH  = 8,
        parameter RX_FIFO_DEPTH  = 8
)(
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_psel,
        input   wire            i_penable,
        input   wire            i_pwrite,
        input   wire    [7:0]   i_paddr,
        input   wire    [31:0]  i_pwdata,

        output  wire    [31:0]  o_prdata,
        output  wire            o_pready,
        output  wire            o_pslverr,

        input   wire            i_uartRx,
        output  wire            o_uartTx,

        output  wire            o_irq
);


uart_apb #(
        .STRICT_APB_ERR (STRICT_APB_ERR),
        .TX_FIFO_DEPTH  (TX_FIFO_DEPTH),
        .RX_FIFO_DEPTH  (RX_FIFO_DEPTH)
) uut_uart_apb (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_psel         (i_psel),
        .i_penable      (i_penable),
        .i_pwrite       (i_pwrite),
        .i_paddr        (i_paddr),
        .i_pwdata       (i_pwdata),

        .o_prdata       (o_prdata),
        .o_pready       (o_pready),
        .o_pslverr      (o_pslverr),

        .i_uartRx       (i_uartRx),
        .o_uartTx       (o_uartTx),

        .o_irq          (o_irq)
);


endmodule
