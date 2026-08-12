`timescale 1ns/1ps

module pwm (
	i_clk	,
	i_rst_n	,
	i_duty	,
	o_pwm
);

input		i_clk	;
input		i_rst_n	;
input 	[7:0] 	i_duty 	;

output 		o_pwm	;

reg   	[7:0]	count	;


always @(posedge i_clk or negedge i_rst_n) begin
	
	if(!i_rst_n)
		count <= 8'd0;

	else
		count <= count + 8'd1;

end

assign o_pwm = (count < i_duty);


endmodule
