`timescale 1ns/1ps

module uart_apb (
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_psel,
        input   wire            i_penable,
        input   wire            i_pwrite,
        input   wire    [7:0]   i_paddr,
        input   wire    [31:0]  i_pwdata,

        output  reg     [31:0]  o_prdata,
        output  reg             o_pready,
        output  reg             o_pslverr,

        input   wire            i_uartRx,
        output  wire            o_uartTx,

        output  wire            o_irq
);


localparam ADDR_CTRL        = 8'h00;
localparam ADDR_BAUDDIV     = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_TXDATA      = 8'h0C;
localparam ADDR_RXDATA      = 8'h10;
localparam ADDR_ERRCLR      = 8'h14;

localparam ADDR_IRQ_EN      = 8'h18;
localparam ADDR_IRQ_STATUS  = 8'h1C;
localparam ADDR_IRQ_CLEAR   = 8'h20;


localparam PARITY_NONE = 2'b00;


// ---------------------------------------------------------
// Configuration Registers
// ---------------------------------------------------------
reg             r_enable;
reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;

reg     [15:0]  r_baudDiv;


// ---------------------------------------------------------
// IRQ Enable Register
// ---------------------------------------------------------
reg     [4:0]   r_irqEn;


// ---------------------------------------------------------
// RX APB Read Control
// ---------------------------------------------------------
reg             r_rxReadPending;


// ---------------------------------------------------------
// UART Core Signals
// ---------------------------------------------------------
wire            w_txFifoFull;
wire            w_txFifoEmpty;
wire    [4:0]   w_txFifoCount;

wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;

wire    [7:0]   w_rxData;

wire            w_rxFifoFull;
wire            w_rxFifoEmpty;
wire    [4:0]   w_rxFifoCount;

wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;


// ---------------------------------------------------------
// IRQ Signals
// ---------------------------------------------------------
wire    [4:0]   w_irqStatus;
wire    [4:0]   w_irqClear;


// ---------------------------------------------------------
// APB Internal Control
// ---------------------------------------------------------
wire            w_apbAccess;
wire            w_txWrEn;
wire            w_rxRdEn;


assign w_apbAccess =
        i_psel &&
        i_penable;


assign w_txWrEn =
        w_apbAccess &&
        i_pwrite &&
        (i_paddr == ADDR_TXDATA) &&
        !w_txFifoFull;


assign w_rxRdEn =
        w_apbAccess &&
        !i_pwrite &&
        (i_paddr == ADDR_RXDATA) &&
        !r_rxReadPending &&
        !w_rxFifoEmpty;


// ---------------------------------------------------------
// IRQ Clear
//
// IRQ_CLEAR
// bit[4:0] directly maps to IRQ sources.
//
// ERRCLR is kept for compatibility:
//
// ERRCLR bit[0] -> Parity Error
// ERRCLR bit[1] -> Frame Error
// ERRCLR bit[2] -> False Start
// ---------------------------------------------------------
assign w_irqClear =
        (
                w_apbAccess &&
                i_pwrite &&
                (i_paddr == ADDR_IRQ_CLEAR)
        ) ? i_pwdata[4:0] :

        (
                w_apbAccess &&
                i_pwrite &&
                (i_paddr == ADDR_ERRCLR)
        ) ? {i_pwdata[2:0], 2'b00} :

        5'b00000;


// ---------------------------------------------------------
// UART Core
// ---------------------------------------------------------
uart_core uut_uart_core (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_baudDiv      (r_baudDiv),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),

        .i_txWrEn       (w_txWrEn),
        .i_txData       (i_pwdata[7:0]),

        .i_rxRdEn       (w_rxRdEn),

        .i_uartRx       (i_uartRx),
        .o_uartTx       (o_uartTx),

        .o_txFifoFull   (w_txFifoFull),
        .o_txFifoEmpty  (w_txFifoEmpty),
        .o_txFifoCount  (w_txFifoCount),

        .o_txReady      (w_txReady),
        .o_txBusy       (w_txBusy),
        .o_txDone       (w_txDone),

        .o_rxData       (w_rxData),

        .o_rxFifoFull   (w_rxFifoFull),
        .o_rxFifoEmpty  (w_rxFifoEmpty),
        .o_rxFifoCount  (w_rxFifoCount),

        .o_rxValid      (w_rxValid),
        .o_rxBusy       (w_rxBusy),

        .o_parityErr    (w_parityErr),
        .o_frameErr     (w_frameErr),
        .o_falseStart   (w_falseStart)
);


// ---------------------------------------------------------
// IRQ Controller
// ---------------------------------------------------------
uart_irq uut_uart_irq (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_irqEn        (r_irqEn),
        .i_irqClear     (w_irqClear),

        .i_rxFifoEmpty  (w_rxFifoEmpty),
        .i_txFifoEmpty  (w_txFifoEmpty),

        .i_parityErr    (w_parityErr),
        .i_frameErr     (w_frameErr),
        .i_falseStart   (w_falseStart),

        .o_irqStatus    (w_irqStatus),
        .o_irq          (o_irq)
);


// ---------------------------------------------------------
// Configuration Register Write
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_enable       <= 1'b0;
                r_data7        <= 1'b0;
                r_parityMode   <= PARITY_NONE;
                r_stop2        <= 1'b0;

                r_baudDiv      <= 16'd312;

                r_irqEn        <= 5'b00000;

        end else begin

                // CTRL
                if (
                        w_apbAccess &&
                        i_pwrite &&
                        (i_paddr == ADDR_CTRL)
                ) begin

                        r_enable       <= i_pwdata[0];
                        r_data7        <= i_pwdata[1];
                        r_parityMode   <= i_pwdata[3:2];
                        r_stop2        <= i_pwdata[4];

                end


                // BAUDDIV
                if (
                        w_apbAccess &&
                        i_pwrite &&
                        (i_paddr == ADDR_BAUDDIV)
                ) begin

                        r_baudDiv <= i_pwdata[15:0];

                end


                // IRQ ENABLE
                if (
                        w_apbAccess &&
                        i_pwrite &&
                        (i_paddr == ADDR_IRQ_EN)
                ) begin

                        r_irqEn <= i_pwdata[4:0];

                end
        end
end


// ---------------------------------------------------------
// RXDATA Read Wait-State Control
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_rxReadPending <= 1'b0;

        end else begin

                if (!w_apbAccess) begin

                        r_rxReadPending <= 1'b0;

                end else if (w_rxRdEn) begin

                        r_rxReadPending <= 1'b1;

                end
        end
end


// ---------------------------------------------------------
// APB Read / Response Logic
// ---------------------------------------------------------
always @(*) begin

        o_prdata  = 32'd0;
        o_pready  = 1'b1;
        o_pslverr = 1'b0;


        if (w_apbAccess) begin

                case (i_paddr)

                        // ---------------------------------
                        // CTRL
                        // ---------------------------------
                        ADDR_CTRL: begin

                                if (!i_pwrite) begin

                                        o_prdata[0]   = r_enable;
                                        o_prdata[1]   = r_data7;
                                        o_prdata[3:2] = r_parityMode;
                                        o_prdata[4]   = r_stop2;

                                end
                        end


                        // ---------------------------------
                        // BAUDDIV
                        // ---------------------------------
                        ADDR_BAUDDIV: begin

                                if (!i_pwrite)
                                        o_prdata[15:0] = r_baudDiv;

                        end


                        // ---------------------------------
                        // STATUS
                        // ---------------------------------
                        ADDR_STATUS: begin

                                if (i_pwrite) begin

                                        o_pslverr = 1'b1;

                                end else begin

                                        o_prdata[0] = w_txFifoEmpty;
                                        o_prdata[1] = w_txFifoFull;
                                        o_prdata[2] = w_txBusy;
                                        o_prdata[3] = w_txReady;

                                        o_prdata[4] = w_rxFifoEmpty;
                                        o_prdata[5] = w_rxFifoFull;
                                        o_prdata[6] = w_rxBusy;

                                        o_prdata[7] = w_irqStatus[2];
                                        o_prdata[8] = w_irqStatus[3];
                                        o_prdata[9] = w_irqStatus[4];

                                        o_prdata[20:16] =
                                                w_txFifoCount;

                                        o_prdata[28:24] =
                                                w_rxFifoCount;

                                end
                        end


                        // ---------------------------------
                        // TXDATA
                        // ---------------------------------
                        ADDR_TXDATA: begin

                                if (!i_pwrite) begin

                                        o_pslverr = 1'b1;

                                end else if (w_txFifoFull) begin

                                        o_pslverr = 1'b1;

                                end
                        end


                        // ---------------------------------
                        // RXDATA
                        // ---------------------------------
                        ADDR_RXDATA: begin

                                if (i_pwrite) begin

                                        o_pslverr = 1'b1;

                                end else if (
                                        w_rxFifoEmpty &&
                                        !r_rxReadPending
                                ) begin

                                        o_pready  = 1'b1;
                                        o_pslverr = 1'b1;

                                end else if (!r_rxReadPending) begin

                                        o_pready = 1'b0;

                                end else begin

                                        o_pready      = 1'b1;
                                        o_prdata[7:0] = w_rxData;

                                end
                        end


                        // ---------------------------------
                        // ERRCLR
                        // ---------------------------------
                        ADDR_ERRCLR: begin

                                if (!i_pwrite)
                                        o_pslverr = 1'b1;

                        end


                        // ---------------------------------
                        // IRQ ENABLE
                        // ---------------------------------
                        ADDR_IRQ_EN: begin

                                if (!i_pwrite)
                                        o_prdata[4:0] = r_irqEn;

                        end


                        // ---------------------------------
                        // IRQ STATUS
                        // ---------------------------------
                        ADDR_IRQ_STATUS: begin

                                if (i_pwrite) begin

                                        o_pslverr = 1'b1;

                                end else begin

                                        o_prdata[4:0] =
                                                w_irqStatus;

                                end
                        end


                        // ---------------------------------
                        // IRQ CLEAR
                        // ---------------------------------
                        ADDR_IRQ_CLEAR: begin

                                if (!i_pwrite)
                                        o_pslverr = 1'b1;

                        end


                        // ---------------------------------
                        // Invalid Address
                        // ---------------------------------
                        default: begin

                                o_prdata  = 32'd0;
                                o_pready  = 1'b1;
                                o_pslverr = 1'b1;

                        end

                endcase
        end
end


endmodule
