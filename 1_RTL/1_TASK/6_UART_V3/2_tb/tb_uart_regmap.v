`timescale 1ns/1ps

module tb_uart_regmap;


localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_IRQ_EN      = 8'h14;
localparam ADDR_IRQ_STATUS  = 8'h18;
localparam ADDR_FIFO_LEVEL  = 8'h1C;


// UART + TX + RX + LOOPBACK
localparam CTRL_LOOPBACK    = 32'h0000_0087;

localparam BAUD_DIV         = 16'd8;


reg             clk;
reg             rst_n;

reg             r_psel;
reg             r_penable;
reg             r_pwrite;

reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;

reg             r_uartRx;


wire    [31:0]  w_prdata;
wire            w_pready;
wire            w_pslverr;

wire            w_uartTx;
wire            w_irq;


reg     [31:0]  r_readData;

integer         r_errorCnt;


// ---------------------------------------------------------
// DUT
// STRICT_APB_ERR = 0
// ---------------------------------------------------------
uart_apb uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_psel         (r_psel),
        .i_penable      (r_penable),
        .i_pwrite       (r_pwrite),
        .i_paddr        (r_paddr),
        .i_pwdata       (r_pwdata),

        .o_prdata       (w_prdata),
        .o_pready       (w_pready),
        .o_pslverr      (w_pslverr),

        .i_uartRx       (r_uartRx),
        .o_uartTx       (w_uartTx),

        .o_irq          (w_irq)
);


// 48 MHz
always #10.41667 clk = ~clk;


// ---------------------------------------------------------
// APB Write
// ---------------------------------------------------------
task apb_write;

        input [7:0]  addr;
        input [31:0] data;

        begin

                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b1;

                r_paddr   = addr;
                r_pwdata  = data;


                @(negedge clk);

                r_penable = 1'b1;


                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);


                #1;


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB WRITE PSLVERR addr=%02h",
                                addr
                        );

                        r_errorCnt =
                                r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;
                r_pwdata  = 32'd0;

        end

endtask


// ---------------------------------------------------------
// APB Read
// ---------------------------------------------------------
task apb_read;

        input   [7:0]   addr;
        output  [31:0]  data;

        begin

                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = addr;
                r_pwdata  = 32'd0;


                @(negedge clk);

                r_penable = 1'b1;


                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);


                #1;

                data = w_prdata;


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB READ PSLVERR addr=%02h",
                                addr
                        );

                        r_errorCnt =
                                r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;

        end

endtask


initial begin

        $dumpfile("uart_regmap.vcd");
        $dumpvars(0, tb_uart_regmap);


        clk         = 1'b0;
        rst_n       = 1'b0;

        r_psel      = 1'b0;
        r_penable   = 1'b0;
        r_pwrite    = 1'b0;

        r_paddr     = 8'd0;
        r_pwdata    = 32'd0;

        r_uartRx    = 1'b1;

        r_readData  = 32'd0;

        r_errorCnt  = 0;


        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (3)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V3 FINAL REGISTER MAP TEST");
        $display("========================================");


        // =================================================
        // TEST 0 : RESET
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : RESET REGISTER");
        $display("----------------------------------------");


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[7:0] !== 8'h00) begin

                $display(
                        "FAIL: CONTROL RESET = %02h",
                        r_readData[7:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: CONTROL RESET = 00"
                );

        end


        apb_read(
                ADDR_BAUDDIV,
                r_readData
        );


        if (r_readData[15:0] !== 16'd325) begin

                $display(
                        "FAIL: BAUD RESET = %0d",
                        r_readData[15:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: BAUD RESET = 325"
                );

        end


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[0] !== 1'b1 ||
            r_readData[2] !== 1'b1 ||
            r_readData[4] !== 1'b0 ||
            r_readData[5] !== 1'b0) begin

                $display(
                        "FAIL: RESET STATUS = %03h",
                        r_readData[8:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RESET STATUS"
                );

        end


        // =================================================
        // TEST 1 : CONTROL / BAUD
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : CONTROL + BAUD");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_LOOPBACK
        );


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[7:0] !== 8'h87) begin

                $display(
                        "FAIL: CONTROL expected=87 actual=%02h",
                        r_readData[7:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: CONTROL = 87"
                );

        end


        apb_write(
                ADDR_BAUDDIV,
                BAUD_DIV
        );


        apb_read(
                ADDR_BAUDDIV,
                r_readData
        );


        if (r_readData[15:0] !== BAUD_DIV) begin

                $display(
                        "FAIL: BAUD expected=%0d actual=%0d",
                        BAUD_DIV,
                        r_readData[15:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: BAUD = %0d",
                        BAUD_DIV
                );

        end


        // =================================================
        // TEST 2 : IRQ ENABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : IRQ ENABLE");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0003
        );


        apb_read(
                ADDR_IRQ_EN,
                r_readData
        );


        if (r_readData[4:0] !== 5'b00011) begin

                $display(
                        "FAIL: IRQ_ENABLE = %05b",
                        r_readData[4:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ_ENABLE = 00011"
                );

        end


        // TX Enable + Empty
        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[1] !== 1'b1) begin

                $display(
                        "FAIL: TX EMPTY STATUS = 0"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX EMPTY STATUS = 1"
                );

        end


        // =================================================
        // TEST 3 : FIFO LEVEL RESET
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : FIFO LEVEL");
        $display("----------------------------------------");


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[7:0] !== 8'd0 ||
            r_readData[15:8] !== 8'd0) begin

                $display(
                        "FAIL: FIFO LEVEL TX=%0d RX=%0d",
                        r_readData[7:0],
                        r_readData[15:8]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FIFO LEVEL TX=0 RX=0"
                );

        end


        // =================================================
        // TEST 4 : TX_DATA -> RX_DATA
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : TX_DATA / RX_DATA");
        $display("----------------------------------------");


        apb_write(
                ADDR_TXDATA,
                32'h0000_0055
        );


        wait (
                uut.w_rxFifoCount ==
                5'd1
        );


        wait (
                !uut.w_txBusy
        );


        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:8] !== 8'd1) begin

                $display(
                        "FAIL: RX LEVEL expected=1 actual=%0d",
                        r_readData[15:8]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX LEVEL = 1"
                );

        end


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[2] !== 1'b0 ||
            r_readData[5] !== 1'b1) begin

                $display(
                        "FAIL: RX STATUS"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX_READY = 1"
                );

        end


        apb_read(
                ADDR_RXDATA,
                r_readData
        );


        if (r_readData[7:0] !== 8'h55) begin

                $display(
                        "FAIL: RX DATA expected=55 actual=%02h",
                        r_readData[7:0]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX DATA = 55"
                );

        end


        if (r_readData[9:8] !== 2'b00) begin

                $display(
                        "FAIL: RX ERROR BITS = %02b",
                        r_readData[9:8]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX ERROR BITS = 00"
                );

        end


        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:8] !== 8'd0) begin

                $display(
                        "FAIL: RX LEVEL expected=0 actual=%0d",
                        r_readData[15:8]
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX LEVEL = 0"
                );

        end


        // =================================================
        // TEST 5 : DEFAULT ILLEGAL ACCESS
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : DEFAULT ILLEGAL ACCESS");
        $display("----------------------------------------");


        // TX_DATA is Write Only
        apb_read(
                ADDR_TXDATA,
                r_readData
        );


        if (r_readData !== 32'd0) begin

                $display(
                        "FAIL: TX_DATA READ"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX_DATA READ = 0"
                );

        end


        // Empty RX_DATA
        apb_read(
                ADDR_RXDATA,
                r_readData
        );


        if (r_readData !== 32'd0) begin

                $display(
                        "FAIL: EMPTY RX_DATA READ"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: EMPTY RX_DATA READ = 0"
                );

        end


        // Invalid Address
        apb_read(
                8'h20,
                r_readData
        );


        if (r_readData !== 32'd0) begin

                $display(
                        "FAIL: INVALID ADDRESS READ"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: INVALID ADDRESS = 0"
                );

        end


        // RO Register Write -> ignored (and PSLVERR asserted)
        apb_write(
                ADDR_STATUS,
                32'hFFFF_FFFF
        );


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[8:6] !== 3'b000) begin

                $display(
                        "FAIL: STATUS WRITE CHANGED ERROR"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: STATUS WRITE IGNORED"
                );

        end


        // =================================================
        // TEST 6 : IRQ_STATUS LEVEL W1C
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 6 : IRQ_STATUS RW1C");
        $display("----------------------------------------");


        // TX FIFO empty level source
        apb_write(
                ADDR_IRQ_STATUS,
                32'h0000_0002
        );


        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        // Level source라 원인이 남으면 다시 1
        if (r_readData[1] !== 1'b1) begin

                $display(
                        "FAIL: TX EMPTY LEVEL SOURCE"
                );

                r_errorCnt =
                        r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX EMPTY LEVEL SOURCE = 1"
                );

        end


        // =================================================
        // RESULT
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V3 FINAL REGISTER MAP: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V3 FINAL REGISTER MAP: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


initial begin

        #100000000;

        $display("");
        $display("========================================");
        $display(" UART V3 FINAL REGISTER MAP: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule

