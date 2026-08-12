`timescale 1ns/1ps

module fsm (
	i_clk	,
	i_rst_n	,
	i_din	,
	o_dout
);

input	i_clk	;
input	i_rst_n	;
input	i_din	;

output 	o_dout	;

reg [1:0] state	;
reg [1:0] next_state ; 

parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;
parameter S3 = 2'b11;

// State Register
always @(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n)
		state <= S0;
	else
		state <= next_state;
end


// Next State Logic
always @(*) begin
	case(state)
		S0: begin
			if(i_din) next_state = S1;
			else	  next_state = S0;
		end

		S1: begin
			if(i_din) next_state = S2;
			else      next_state = S0;
		end

		S2: begin
			if(i_din) next_state = S3;
			else	  next_state = S0;
		end

		S3: begin
			if(i_din) next_state = S3;
			else	  next_state = S0;
		end
	
		default: next_state = S0;
	endcase
end

// Output Logic
assign o_dout = (state == S3);

endmodule
