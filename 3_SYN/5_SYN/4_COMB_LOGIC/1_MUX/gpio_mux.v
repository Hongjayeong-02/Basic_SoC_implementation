`timescale 1ns/1ps

module gpio_mux (
	i_sel,
	i_uartTx,
	i_uartRx,
	i_pwm,
	i_peri,
	o_gpio
);

input [1:0] i_sel;
input       i_uartTx;
input 	    i_uartRx;
input       i_pwm;
input       i_peri;

output      o_gpio;


assign o_gpio = (i_sel == 2'b00) ? i_uartTx:
		(i_sel == 2'b01) ? i_uartRx:
		(i_sel == 2'b10) ? i_pwm:
				   i_peri;


endmodule
