`timescale 1ns/1ps

module tb_uart_v2_s;


localparam ADDR_CTRL        = 8'h00;
localparam ADDR_BAUDDIV     = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_TXDATA      = 8'h0C;
localparam ADDR_RXDATA      = 8'h10;
localparam ADDR_IRQ_EN      = 8'h18;

localparam CTRL_8N1         = 32'h0000_0001;
localparam BAUD_DIV         = 16'd312;


reg             clk;
reg             rst_n;

reg             r_psel;
reg             r_penable;
reg             r_pwrite;

reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;


wire    [31:0]  w_prdata;
wire            w_pready;
wire            w_pslverr;

wire            w_uartTx;
wire            w_uartRx;

wire            w_irq;


reg     [31:0]  r_readData;

integer         r_errorCnt;


// TX -> RX Loopback
assign w_uartRx = w_uartTx;


// DUT
uart_v2_top uut (
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

        .i_uartRx       (w_uartRx),
        .o_uartTx       (w_uartTx),

        .o_irq          (w_irq)
);


// 48 MHz Clock
always #10.41667 clk = ~clk;


// APB Write
task apb_write;

        input   [7:0]   addr;
        input   [31:0]  data;

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


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB WRITE addr=%02h",
                                addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;
                r_pwdata  = 32'd0;

        end

endtask


// APB Read
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
                                "FAIL: APB READ addr=%02h",
                                addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;

        end

endtask


// Wait RX FIFO Count
task wait_rx_count;

        input [4:0] expectedCount;

        begin

                r_readData = 32'd0;


                while (
                        r_readData[28:24] != expectedCount
                ) begin

                        apb_read(
                                ADDR_STATUS,
                                r_readData
                        );

                end

        end

endtask


// RX Data Check
task rx_check;

        input [7:0] expectedData;

        begin

                apb_read(
                        ADDR_RXDATA,
                        r_readData
                );


                if (
                        r_readData[7:0] !==
                        expectedData
                ) begin

                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                end

        end

endtask


initial begin

        $dumpfile("uart_v2_s.vcd");
        $dumpvars(0, tb_uart_v2_s);


        clk         = 1'b0;
        rst_n       = 1'b0;

        r_psel      = 1'b0;
        r_penable   = 1'b0;
        r_pwrite    = 1'b0;

        r_paddr     = 8'd0;
        r_pwdata    = 32'd0;

        r_readData  = 32'd0;

        r_errorCnt  = 0;


        // Reset
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (3)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V2 SIMPLE TEST START");
        $display("========================================");


        // -----------------------------------------
        // TEST 1 : UART Configuration
        // -----------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : UART 8N1 CONFIG");
        $display("----------------------------------------");


        apb_write(
                ADDR_BAUDDIV,
                BAUD_DIV
        );


        apb_write(
                ADDR_CTRL,
                CTRL_8N1
        );


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[4:0] !== 5'b00001) begin

                $display(
                        "FAIL: CTRL = %05b",
                        r_readData[4:0]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: UART 8N1 CONFIG"
                );

        end


        // -----------------------------------------
        // TEST 2 : RX FIFO IRQ Enable
        // -----------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : RX FIFO IRQ ENABLE");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0001
        );


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ should be LOW"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ = 0"
                );

        end


        // -----------------------------------------
        // TEST 3 : TX -> RX Loopback
        // -----------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : UART LOOPBACK");
        $display("----------------------------------------");


        apb_write(
                ADDR_TXDATA,
                32'h0000_0055
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_00AA
        );


        // Wait RX FIFO = 2
        wait_rx_count(
                5'd2
        );


        $display(
                "PASS: RX FIFO COUNT = 2"
        );


        // RX FIFO Not Empty -> IRQ
        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: RX FIFO IRQ expected=1"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO IRQ = 1"
                );

        end


        // -----------------------------------------
        // TEST 4 : RX Data
        // -----------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : RX DATA");
        $display("----------------------------------------");


        rx_check(
                8'h55
        );


        rx_check(
                8'hAA
        );


        // -----------------------------------------
        // TEST 5 : FIFO Empty + IRQ Clear
        // -----------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : RX FIFO EMPTY");
        $display("----------------------------------------");


        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[4] !== 1'b1) begin

                $display(
                        "FAIL: RX FIFO EMPTY = 0"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO EMPTY = 1"
                );

        end


        if (r_readData[28:24] !== 5'd0) begin

                $display(
                        "FAIL: RX FIFO COUNT = %0d",
                        r_readData[28:24]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 0"
                );

        end


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ should be LOW after RX FIFO empty"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ = 0"
                );

        end


        // -----------------------------------------
        // Result
        // -----------------------------------------
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V2 SIMPLE TEST: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V2 SIMPLE TEST: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


// Timeout
initial begin

        #20000000;

        $display("");
        $display("========================================");
        $display(" UART V2 SIMPLE TEST: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
