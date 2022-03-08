`include "gpio_pad.v"
`include "gbas.v"
`include "spi2apb_bridge.v"

module gpio_expander#(
						parameter BANK_NUM = 2,
						parameter ADDR_WIDTH = 7,
						parameter PADDR_WIDTH = 3,
						parameter DATA_WIDTH = 8
						)(
						input	sclk,
						input	resetn,
						input	miso,
						input	mosi,
						input	ss,
						
						output [7:0]	pad);

wire 						e_pclk_a 	;
wire 						e_pclk_b 	;

wire 						e_presetn  	;
wire	[PADDR_WIDTH-1:0]	e_paddr  	;
wire 						e_pwrite  	;
wire 	[1:0]	 			e_psel 	 	;
wire 						e_penable  	;
wire 	[DATA_WIDTH-1:0] 	e_pwdata	;
wire 						e_pready  	;
wire 	[DATA_WIDTH-1:0] 	e_prdata  	;


wire [7:0] 	e_oe;
wire [7:0]	e_pu;
wire [7:0]	e_pd;
wire [7:0]	e_a;
wire [7:0]	e_y;

assign #(0) e_pclk_b = e_pclk_a;

spi2apb_bridge bridge(	.sclk(sclk),		.resetn(resetn),		.b_pready(e_pready),	.b_prdata(e_prdata),	
						.b_pclk(e_pclk_a),	.b_presetn(e_presetn), 	.b_paddr(e_paddr),		.b_pwrite(e_pwrite),	
						.b_psel(e_psel),	.b_penable(e_penable),	.b_pwdata(e_pwdata),						
						.mosi(mosi), 		.miso(miso),			.ss(ss));

gbas 			bank0(	.paddr(e_paddr),	.pready(e_pready),		.prdata(e_prdata),	
						.pclk(e_pclk_b),	.pwdata(e_pwdata),		.pwrite(e_pwrite),
						.pselx(e_psel),		.penable(e_penable),	.presetn(e_presetn));
/*
gbas 			bank1(	.paddr(e_paddr),	.pready(e_pready),		.prdata(e_prdata),	
						.pclk(e_pclk),	 	.pwdata(e_pwdata),		.pwrite(e_pwrite),
						.pselx(e_psel),		.penable(e_penable),	.presetn(e_presetn));
*/

gpio_pad 		pin0(	.oe(e_oe[0]),		.a(e_a[0]),				.pd(e_pd[0]),
						.pu(e_pu[0]),		.y(e_y[0]),				.pad(pad[0]));

gpio_pad 		pin1(	.oe(e_oe[1]),		.a(e_a[1]),				.pd(e_pd[1]),
						.pu(e_pu[1]),		.y(e_y[1]),				.pad(pad[1]));

gpio_pad 		pin2(	.oe(e_oe[2]),		.a(e_a[2]),				.pd(e_pd[2]),
						.pu(e_pu[2]),		.y(e_y[2]),				.pad(pad[2]));

gpio_pad 		pin3(	.oe(e_oe[3]),		.a(e_a[3]),				.pd(e_pd[3]),
						.pu(e_pu[3]),		.y(e_y[3]),				.pad(pad[3]));

gpio_pad 		pin4(	.oe(e_oe[4]),		.a(e_a[4]),				.pd(e_pd[4]),
						.pu(e_pu[4]),		.y(e_y[4]),				.pad(pad[4]));

gpio_pad 		pin5(	.oe(e_oe[5]),		.a(e_a[5]),				.pd(e_pd[5]),
						.pu(e_pu[5]),		.y(e_y[5]),				.pad(pad[5]));

gpio_pad 		pin6(	.oe(e_oe[6]),		.a(e_a[6]),				.pd(e_pd[6]),
						.pu(e_pu[6]),		.y(e_y[6]),				.pad(pad[6]));

gpio_pad 		pin7(	.oe(e_oe[7]),		.a(e_a[7]),				.pd(e_pd[7]),
						.pu(e_pu[7]),		.y(e_y[7]),				.pad(pad[7]));

/*
gpio_pad 		pin8(	.oe(e_oe[8]),		.a(e_a[8])				.pd(e_pd[8])
						.pu(e_pu[8]),		.y(e_y[8]),				.pad(pad[8]));

gpio_pad 		pin9(	.oe(e_oe[9]),		.a(e_a[9])				.pd(e_pd[9])
						.pu(e_pu[9]),		.y(e_y[9]),				.pad(pad[9]));

gpio_pad 		pin10(	.oe(e_oe[10]),		.a(e_a[10])				.pd(e_pd[10])
						.pu(e_pu[10]),		.y(e_y[10]),			.pad(pad[10]));

gpio_pad 		pin11(	.oe(e_oe[11]),		.a(e_a[11])				.pd(e_pd[11])
						.pu(e_pu[11]),		.y(e_y[11]),			.pad(pad[11]));

gpio_pad 		pin12(	.oe(e_oe[12]),		.a(e_a[12])				.pd(e_pd[12])
						.pu(e_pu[12]),		.y(e_y[12]),			.pad(pad[12]));

gpio_pad 		pin13(	.oe(e_oe[13]),		.a(e_a[13])				.pd(e_pd[13])
						.pu(e_pu[13]),		.y(e_y[13]),			.pad(pad[13]));

gpio_pad 		pin14(	.oe(e_oe[14]),		.a(e_a[14])				.pd(e_pd[14])
						.pu(e_pu[14]),		.y(e_y[14]),			.pad(pad[14]));

gpio_pad 		pin15(	.oe(e_oe[15]),		.a(e_a[15])				.pd(e_pd[15])
						.pu(e_pu[15]),		.y(e_y[15]),			.pad(pad[15]));
*/

endmodule