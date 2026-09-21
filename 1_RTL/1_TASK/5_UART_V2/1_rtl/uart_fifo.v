`timescale 1ns/1ps

module uart_fifo (
        input   wire            clk,
        input   wire            rst_n,

        input   wire            i_wrEn,
        input   wire    [7:0]   i_wrData,

        input   wire            i_rdEn,

        output  reg     [7:0]   o_rdData,
        output  wire            o_full,
        output  wire            o_empty,
        output  wire    [4:0]   o_count
);

localparam FIFO_DEPTH = 16;

reg     [7:0]   r_mem [0:FIFO_DEPTH-1];

reg     [3:0]   r_wrPtr;
reg     [3:0]   r_rdPtr;
reg     [4:0]   r_count;


assign o_full  = (r_count == 5'd16);
assign o_empty = (r_count == 5'd0);
assign o_count = r_count;


// FIFO Control
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_wrPtr   <= 4'd0;
                r_rdPtr   <= 4'd0;
                r_count   <= 5'd0;
                o_rdData  <= 8'd0;

        end else begin

                case ({
                        (i_wrEn && !o_full),
                        (i_rdEn && !o_empty)
                })

                        // Write Only
                        2'b10: begin
                                r_mem[r_wrPtr] <= i_wrData;
                                r_wrPtr        <= r_wrPtr + 1'b1;
                                r_count        <= r_count + 1'b1;
                        end


                        // Read Only
                        2'b01: begin
                                o_rdData       <= r_mem[r_rdPtr];
                                r_rdPtr        <= r_rdPtr + 1'b1;
                                r_count        <= r_count - 1'b1;
                        end


                        // Write + Read
                        2'b11: begin
                                r_mem[r_wrPtr] <= i_wrData;
                                r_wrPtr        <= r_wrPtr + 1'b1;

                                o_rdData       <= r_mem[r_rdPtr];
                                r_rdPtr        <= r_rdPtr + 1'b1;

                                r_count        <= r_count;
                        end


                        // No Operation
                        default: begin
                                r_count <= r_count;
                        end

                endcase
        end
end

endmodule
