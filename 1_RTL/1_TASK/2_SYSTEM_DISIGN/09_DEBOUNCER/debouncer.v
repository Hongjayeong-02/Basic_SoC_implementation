`timescale 1ns/1ps

module debouncer (
	i_clk	,
	i_rst_n	,
	i_btn	,
	o_btn
);

input	i_clk	;
input	i_rst_n	;
input	i_btn	;

output 	o_btn	;

reg 	btn_ff1	;
reg 	btn_ff2	;

always @(posedge i_clk or negedge i_rst_n) begin

	if(!i_rst_n) begin
		btn_ff1 <= 1'b0;
		btn_ff2 <= 1'b0;
	end

	else begin
		btn_ff1 <= i_btn;
		btn_ff2 <= btn_ff1;
	end

end

assign o_btn = btn_ff2;

endmodule
