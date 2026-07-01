`timescale 1ns/1ps

module tb_gpio_mux();

reg [1:0]	 i_sel			;
reg 	 	 i_uartTx 		;
reg 	 	 i_uartRx 		; 
reg 	 	 i_pwm			;
reg      	 i_peri			;
wire 	 	 o_gpio			;

gpio_mux uut ( 
	.i_sel		(i_sel		)		,
	.i_uartTx	(i_uartTx	)		,
	.i_uartRx 	(i_uartRx	)		,
	.i_pwm		(i_pwm		)		,
	.i_peri		(i_peri		)		,
	.o_gpio 	(o_gpio		)
);

	initial begin
		$dumpfile("./gpio.vcd")		;
		$dumpvars(0, tb_gpio_mux)	;
	end


	initial begin
		i_uartTx = 1'b0; i_uartRx = 1'b1; i_pwm = 1'b0; i_peri = 1'b1;

		i_sel = 2'b00; #10;
		i_sel = 2'b01; #10;


		i_uartTx = 1'b1; i_uartRx = 1'b0; i_pwm = 1'b1; i_peri = 1'b0;

		i_sel = 2'b11; #10;
		i_sel = 2'b10; #10;

		$finish;
	end


endmodule
