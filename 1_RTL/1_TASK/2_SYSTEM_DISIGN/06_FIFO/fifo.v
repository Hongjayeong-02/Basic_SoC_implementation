`timescale 1ns/1ps

module fifo (
	i_clk	,
	i_rst_n	,
	i_wr_en	,
	i_rd_en	,
	i_din	,
	o_dout	,
	o_full	,
	o_empty
);

input	i_clk		;
input	i_rst_n		;
input	i_wr_en		;
input	i_rd_en		;
input	[31:0] i_din	;

output reg [31:0] o_dout ;
output 		  o_full ;
output  	  o_empty;

reg [31:0] mem [0:7];

reg [2:0] wr_ptr;
reg [2:0] rd_ptr;
reg [3:0] count	;


assign  o_full  = (count == 4'd8);
assign  o_empty = (count == 4'd0);


always @(posedge i_clk or negedge i_rst_n) begin

	if(~i_rst_n) begin
		wr_ptr 	<= 3'd0	;
		rd_ptr 	<= 3'd0	;
		count  	<= 4'd0	;
		o_dout 	<= 32'd0;
	end

	else begin

		if(i_wr_en && !o_full) begin
			mem[wr_ptr] <= i_din;
			wr_ptr	    <= wr_ptr + 3'd1;
		end

		if(i_rd_en && !o_empty) begin
			o_dout <= mem[rd_ptr];
			rd_ptr <= rd_ptr + 3'd1;
		end

		case ({i_wr_en && !o_full, i_rd_en && !o_empty})
			2'b10: count <= count + 4'd1;
			2'b01: count <= count - 4'd1;
			default: count <= count;
		endcase
	
	end
end

endmodule
