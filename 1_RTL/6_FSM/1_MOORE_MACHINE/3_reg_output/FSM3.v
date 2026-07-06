`timescale 1ns/1ps

module FSM3(
	clk	,
	rst_n	,
	go	,
	ws	, 
	rd	,
	ds
);

input clk	;
input rst_n	;
input go	;
input ws	;
output rd	;
output ds	;

parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter DLY  = 2'b11;
parameter DONE = 2'b10;

reg [1:0] state	;
reg [1:0] next	;

reg rd;
reg ds;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) state <= IDLE ;
	else	   state <= next ;
end

always @(state, go, ws) begin
	next = 2'bx;
	case(state)
		IDLE : if(go)	next = READ	;
			else	next = IDLE	;
		READ : 		next = DLY	;
		DLY  : if(!ws)  next = DONE	;
			else	next = READ	;
		DONE : 		next = IDLE	;
	endcase
end

always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		rd <= 1'b0;
		ds <= 1'b0;
	end
	else begin
		case(next)
			READ : rd <= 1'b1;
			DLY  : rd <= 1'b1;
			DONE : rd <= 1'b1;
		endcase
	end
end

endmodule
