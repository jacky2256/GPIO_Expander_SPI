module spi2apb_bridge(
                        input 			sclk,
                        input 			resetn,
                        input 			mosi,
                        input 	[2:0]	ss,
                        output 			miso,

                        input			b_prdata,
                        input			b_pready,
                        output			b_pclk,
                        output			b_resetn,
                        output			b_pwdata,
                        output			b_pwrite,
                        output			b_psel,
                        output			b_penable,
                        output			b_paddr
                        );



endmodule