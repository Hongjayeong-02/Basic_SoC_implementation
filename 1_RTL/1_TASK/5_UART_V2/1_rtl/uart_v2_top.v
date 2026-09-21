`timescale 1ns/1ps

module uart_v2_top (
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


uart_apb uut_uart_apb (
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
