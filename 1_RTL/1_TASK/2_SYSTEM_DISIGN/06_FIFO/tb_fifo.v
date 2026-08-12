`timescale 1ns/1ps

module tb_fifo;

reg		i_clk	;		
reg		i_rst_n	;
reg		i_wr_en	;
reg 		i_rd_en	;
reg  [31:0] 	i_din	;

wire [31:0] 	o_dout	;		 
wire		o_full	;
wire		o_empty	;


fifo u_fifo (
	.i_clk	(i_clk	),
	.i_rst_n(i_rst_n),
	.i_wr_en(i_wr_en),
	.i_rd_en(i_rd_en),
	.i_din	(i_din	),
	.o_dout	(o_dout	),
	.o_full	(o_full	),
	.o_empty(o_empty)
);

initial begin

	i_clk 	= 1'b0;
	i_rst_n = 1'b0;
	i_wr_en = 1'b0;
	i_rd_en = 1'b0;
	i_din 	= 32'd0;

	#10 i_rst_n = 1'b1;

	// WRITE
	#10 i_wr_en = 1'b1; i_din = 32'h1111_1111;
	#10 i_din = 32'h2222_2222;
	#10 i_din = 32'h3333_3333;

	#10 i_wr_en = 1'b0;

	// READ
	#10 i_rd_en = 1'b1;
	#30 i_rd_en = 1'b0;

	#20 $finish;

end

initial begin
	$dumpfile("./fifo.vcd"	);
	$dumpvars(0, tb_fifo	);
end

initial begin
	$monitor(
		"TIME = %0t | WR = %b | RD = %b | DIN = %h | DOUT = %h | FULL = %b | EMPTY = %b",
		$time, i_wr_en, i_rd_en, i_din, o_dout, o_full, o_empty
	);
end 

endmodule
