module gpio_pad(
				inout 	pad,	
				input 	a,
				input	oe,				//driver enable signal
				input	pu,				//enabling the built-in resistive power pull-up
				input	pd,				//enabling the built-in resistive pull-up to ground
				output	y				//receiver output
				);			

assign (pull0, pull1) pad = (oe)? a : 1'bz;
assign (weak1, weak0) pad = (pu)? 1'b1 : 1'bz;
assign (weak1, weak0) pad = (pd)? 1'b0 : 1'bz;
assign y = pad;

endmodule
