`timescale 1ns/1ps

module uart_apb #(
        // Per spec sec.10.2: the base/default behavior is a silent drop
        // (checked via STATUS/FIFO_LEVEL polling) - PSLVERR-on-illegal-
        // access is an opt-in "strict mode", not the default. Keep this
        // at 0 unless the system integrator explicitly wants strict APB
        // error reporting.
        parameter STRICT_APB_ERR = 1'b0,
        // Per spec sec.8.3 / sec.16: default FIFO depth is 8 for both
        // TX and RX, parameterizable if a design needs more headroom.
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

        output  reg     [31:0]  o_prdata,
        output  reg             o_pready,
        output  reg             o_pslverr,

        input   wire            i_uartRx,
        output  wire            o_uartTx,

        output  wire            o_irq
);


// ---------------------------------------------------------
// Register Address
// ---------------------------------------------------------
localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_IRQ_EN      = 8'h14;
localparam ADDR_IRQ_STATUS  = 8'h18;
localparam ADDR_FIFO_LEVEL  = 8'h1C;


// ---------------------------------------------------------
// CONTROL Register
// ---------------------------------------------------------
reg             r_uartEn;
reg             r_txEn;
reg             r_rxEn;

reg     [1:0]   r_parityMode;

reg             r_stop2;
reg             r_data7;
reg             r_loopbackEn;


// ---------------------------------------------------------
// BAUD_DIV
// ---------------------------------------------------------
reg     [15:0]  r_baudDiv;


// ---------------------------------------------------------
// IRQ ENABLE
// ---------------------------------------------------------
reg     [4:0]   r_irqEn;


// ---------------------------------------------------------
// RX Read
// ---------------------------------------------------------
reg             r_rxReadPending;


// ---------------------------------------------------------
// UART Core
// ---------------------------------------------------------
wire            w_txFifoFull;
wire            w_txFifoEmpty;
wire    [4:0]   w_txFifoCount;

wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;


wire    [7:0]   w_rxData;

wire            w_rxParityErrData;
wire            w_rxFrameErrData;

wire            w_rxFifoFull;
wire            w_rxFifoEmpty;
wire    [4:0]   w_rxFifoCount;

wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;
wire            w_rxOverflow;


// ---------------------------------------------------------
// IRQ
// ---------------------------------------------------------
wire    [4:0]   w_irqStatus;
wire    [4:0]   w_irqClear;


// ---------------------------------------------------------
// APB
// ---------------------------------------------------------
wire            w_apbAccess;

wire            w_txWrEn;
wire            w_rxRdEn;


assign w_apbAccess = i_psel &&
                     i_penable;


// TX_DATA Write
assign w_txWrEn = w_apbAccess &&
                  i_pwrite &&
                  (i_paddr == ADDR_TXDATA) &&
                  r_uartEn &&
                  r_txEn &&
                  !w_txFifoFull;


// RX_DATA Read
assign w_rxRdEn = w_apbAccess &&
                  !i_pwrite &&
                  (i_paddr == ADDR_RXDATA) &&
                  !r_rxReadPending &&
                  !w_rxFifoEmpty;


// IRQ_STATUS = RW1C
assign w_irqClear =
        (w_apbAccess &&
         i_pwrite &&
         (i_paddr == ADDR_IRQ_STATUS)) ?

        i_pwdata[4:0] :

        5'b00000;


// ---------------------------------------------------------
// UART Core
// ---------------------------------------------------------
uart_core #(
        .TX_FIFO_DEPTH      (TX_FIFO_DEPTH),
        .RX_FIFO_DEPTH      (RX_FIFO_DEPTH)
) uut_uart_core (
        .clk                (clk),
        .rst_n              (rst_n),

        .i_enable           (r_uartEn),
        .i_txEn             (r_txEn),
        .i_rxEn             (r_rxEn),

        .i_baudDiv          (r_baudDiv),

        .i_data7            (r_data7),
        .i_parityMode       (r_parityMode),
        .i_stop2            (r_stop2),
        .i_loopbackEn       (r_loopbackEn),

        .i_txWrEn           (w_txWrEn),
        .i_txData           (i_pwdata[7:0]),

        .i_rxRdEn           (w_rxRdEn),

        .i_uartRx           (i_uartRx),
        .o_uartTx           (o_uartTx),

        .o_txFifoFull       (w_txFifoFull),
        .o_txFifoEmpty      (w_txFifoEmpty),
        .o_txFifoCount      (w_txFifoCount),

        .o_txReady          (w_txReady),
        .o_txBusy           (w_txBusy),
        .o_txDone           (w_txDone),

        .o_rxData           (w_rxData),
        .o_rxParityErrData  (w_rxParityErrData),
        .o_rxFrameErrData   (w_rxFrameErrData),

        .o_rxFifoFull       (w_rxFifoFull),
        .o_rxFifoEmpty      (w_rxFifoEmpty),
        .o_rxFifoCount      (w_rxFifoCount),

        .o_rxValid          (w_rxValid),
        .o_rxBusy           (w_rxBusy),

        .o_parityErr        (w_parityErr),
        .o_frameErr         (w_frameErr),
        .o_falseStart       (w_falseStart),

        .o_rxOverflow       (w_rxOverflow)
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

        // TX Empty IRQ는 TX Enable일 때만 발생
        .i_txFifoEmpty  (w_txFifoEmpty && r_txEn),

        .i_parityErr    (w_parityErr),
        .i_frameErr     (w_frameErr),
        .i_rxOverflow   (w_rxOverflow),

        .o_irqStatus    (w_irqStatus),
        .o_irq          (o_irq)
);


// ---------------------------------------------------------
// Register Write
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                r_uartEn       <= 1'b0;
                r_txEn         <= 1'b0;
                r_rxEn         <= 1'b0;

                r_parityMode   <= 2'b00;

                r_stop2        <= 1'b0;
                r_data7        <= 1'b0;
                r_loopbackEn   <= 1'b0;

                // Target board: CORE-5300 (Zynq-7000 SoC lab kit), PL fabric
                // clock = 50MHz (board pin U18, PL_clk). Default baud = 9600.
                // BAUD_DIV = round(PCLK/(16*BAUD)) - 1
                //          = round(50_000_000/(16*9600)) - 1 = 325
                // Actual baud = 50_000_000/(16*(325+1)) = 9585.9 bps
                // (~-0.15% error, well within the spec's 2% budget).
                // NOTE: simulation testbenches use their own fast-sim
                // BAUD_DIV values (8, 312, etc.) written explicitly over
                // APB and do not rely on this reset default.
                r_baudDiv      <= 16'd325;

                r_irqEn        <= 5'b00000;

        end else begin

                // CONTROL
                if (w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_CTRL)) begin

                        r_uartEn       <= i_pwdata[0];
                        r_txEn         <= i_pwdata[1];
                        r_rxEn         <= i_pwdata[2];

                        r_parityMode   <= i_pwdata[4:3];

                        r_stop2        <= i_pwdata[5];
                        r_data7        <= i_pwdata[6];
                        r_loopbackEn   <= i_pwdata[7];

                end


                // BAUD_DIV
                if (w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_BAUDDIV)) begin

                        r_baudDiv <= i_pwdata[15:0];

                end


                // IRQ_ENABLE
                if (w_apbAccess &&
                    i_pwrite &&
                    (i_paddr == ADDR_IRQ_EN)) begin

                        r_irqEn <= i_pwdata[4:0];

                end

        end
end


// ---------------------------------------------------------
// RX FIFO Synchronous Read
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

                r_rxReadPending <= 1'b0;

        end else begin

                if (!w_apbAccess)
                        r_rxReadPending <= 1'b0;

                else if (w_rxRdEn)
                        r_rxReadPending <= 1'b1;

        end
end


// ---------------------------------------------------------
// APB Read / Response
// ---------------------------------------------------------
always @(*) begin

        o_prdata  = 32'd0;
        o_pready  = 1'b1;
        o_pslverr = 1'b0;


        if (w_apbAccess) begin

                case (i_paddr)

                        // ---------------------------------
                        // 0x00 TX_DATA
                        // Write Only
                        // ---------------------------------
                        ADDR_TXDATA: begin

                                if (!i_pwrite) begin

                                        o_prdata = 32'd0;

                                        if (STRICT_APB_ERR)
                                                o_pslverr = 1'b1;

                                end else if (w_txFifoFull) begin

                                        if (STRICT_APB_ERR)
                                                o_pslverr = 1'b1;

                                end

                        end


                        // ---------------------------------
                        // 0x04 RX_DATA
                        // Read Only
                        // ---------------------------------
                        ADDR_RXDATA: begin

                                if (i_pwrite) begin

                                        if (STRICT_APB_ERR)
                                                o_pslverr = 1'b1;

                                end else if (w_rxFifoEmpty &&
                                             !r_rxReadPending) begin

                                        o_prdata = 32'd0;

                                        if (STRICT_APB_ERR)
                                                o_pslverr = 1'b1;

                                end else if (!r_rxReadPending) begin

                                        // FIFO synchronous read
                                        o_pready = 1'b0;

                                end else begin

                                        o_prdata[7:0] =
                                                w_rxData;

                                        o_prdata[8] =
                                                w_rxParityErrData;

                                        o_prdata[9] =
                                                w_rxFrameErrData;

                                end

                        end


                        // ---------------------------------
                        // 0x08 STATUS
                        // Read Only
                        // ---------------------------------
                        ADDR_STATUS: begin

                                if (i_pwrite) begin

                                        if (STRICT_APB_ERR)
                                                o_pslverr = 1'b1;

                                end else begin

                                        o_prdata[0] =
                                                w_txFifoEmpty;

                                        o_prdata[1] =
                                                w_txFifoFull;

                                        o_prdata[2] =
                                                w_rxFifoEmpty;

                                        o_prdata[3] =
                                                w_rxFifoFull;

                                        o_prdata[4] =
                                                w_txBusy;

                                        o_prdata[5] =
                                                !w_rxFifoEmpty;

                                        o_prdata[6] =
                                                w_irqStatus[2];

                                        o_prdata[7] =
                                                w_irqStatus[3];

                                        o_prdata[8] =
                                                w_irqStatus[4];

                                end

                        end


                        // ---------------------------------
                        // 0x0C CONTROL
                        // ---------------------------------
                        ADDR_CTRL: begin

                                if (!i_pwrite) begin

                                        o_prdata[0] =
                                                r_uartEn;

                                        o_prdata[1] =
                                                r_txEn;

                                        o_prdata[2] =
                                                r_rxEn;

                                        o_prdata[4:3] =
                                                r_parityMode;

                                        o_prdata[5] =
                                                r_stop2;

                                        o_prdata[6] =
                                                r_data7;

                                        o_prdata[7] =
                                                r_loopbackEn;

                                end

                        end


                        // ---------------------------------
                        // 0x10 BAUD_DIV
                        // ---------------------------------
                        ADDR_BAUDDIV: begin

                                if (!i_pwrite)
                                        o_prdata[15:0] =
                                                r_baudDiv;

                        end


                        // ---------------------------------
                        // 0x14 IRQ_ENABLE
                        // ---------------------------------
                        ADDR_IRQ_EN: begin

                                if (!i_pwrite)
                                        o_prdata[4:0] =
                                                r_irqEn;

                        end


                        // ---------------------------------
                        // 0x18 IRQ_STATUS
                        // Read / Write-1-to-Clear
                        // ---------------------------------
                        ADDR_IRQ_STATUS: begin

                                if (!i_pwrite)
                                        o_prdata[4:0] =
                                                w_irqStatus;

                        end


                        // ---------------------------------
                        // 0x1C FIFO_LEVEL
                        //
                        // [7:0]  TX Count
                        // [15:8] RX Count
                        // ---------------------------------
                        ADDR_FIFO_LEVEL: begin

                                if (i_pwrite) begin

                                        if (STRICT_APB_ERR)
                                                o_pslverr = 1'b1;

                                end else begin

                                        o_prdata[7:0] =
                                                {3'b000,
                                                 w_txFifoCount};

                                        o_prdata[15:8] =
                                                {3'b000,
                                                 w_rxFifoCount};

                                end

                        end


                        // ---------------------------------
                        // Invalid Address
                        // ---------------------------------
                        default: begin

                                o_prdata = 32'd0;

                                if (STRICT_APB_ERR)
                                        o_pslverr = 1'b1;

                        end

                endcase

        end
end


endmodule

