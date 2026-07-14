`timescale 1ns/1ps

module traffic_light (
	clk		,
	rst_n		,
	o_red		,
	o_yellow	,
	o_green
);

input clk		;
input rst_n		;
output reg o_red	;
output reg o_yellow	;
output reg o_green	;

parameter GREEN  = 2'b00	;
parameter YELLOW = 2'b01	;
parameter RED    = 2'b10	;

reg [1:0] r_state	;
reg [1:0] r_cnt		; 

always @(posedge clk) begin
	if(~rst_n) begin
		r_state <= GREEN;
		r_cnt <= 2'd0;
	end
	else begin
		case(r_state)
			GREEN : begin
				if(r_cnt == 2'd3) begin
					r_state <= YELLOW;
					r_cnt <= 2'd0;
				end
				else
					r_cnt <= r_cnt + 1'b1;
				end
			YELLOW : begin
				if(r_cnt == 2'd1) begin
					r_state <= RED;
					r_cnt <= 2'd0;
				end
				else
					r_cnt <= r_cnt + 1'b1;
				end
			RED : begin
				if(r_cnt == 2'd3) begin
					r_state <= GREEN;
					r_cnt <= 2'd0;
				end
				else
					r_cnt <= r_cnt + 1'b1;
				end
			default : begin
					r_state <= GREEN;
					r_cnt <= 2'd0;
			end
		endcase
	end
end

always @(*) begin
	o_green   = 1'b0;
	o_yellow  = 1'b0;
	o_red 	  = 1'b0;
	
	case(r_state)
		GREEN 	: o_green  = 1'b1;
		YELLOW 	: o_yellow = 1'b1;
		RED 	: o_red    = 1'b1;

		default : begin
			o_green  = 1'b0;
			o_yellow = 1'b0;
			o_red    = 1'b0;
		end
	endcase
end

endmodule
