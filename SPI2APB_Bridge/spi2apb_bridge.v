module spi2apb_bridge #(
						parameter BANK_NUM 		= 	2,
						parameter DATA_WIDTH 	= 	8,
						parameter ADDR_WIDTH	=	8
						)(
                        input 			sclk,
                        input 			resetn,
                        input 			mosi,
                        input 			ss,
                        output 			miso,

                        input		[DATA_WIDTH-1 : 0]		b_prdata,
                        input								b_pready,
                        output								b_pclk,
                        output								b_resetn,
                        output		[DATA_WIDTH-1 : 0]		b_pwdata,
                        output								b_pwrite,
                        output		[BANK_NUM-1	:	0]		b_psel,
                        output								b_penable,
                        output		[ADDR_WIDTH-1 : 0]		b_paddr
                        );

reg	[15: 0]	reg_mosi;
reg [15: 0]	reg_miso;

reg [3 : 0] counter_spi;
reg	[3 : 0] counter_apb;

wire trans_apb;

//spi interface
always @(posedge sclk or negedge resetn) begin
	if(!resetn) begin
		reg_miso 	<=	16'hf001;
		reg_mosi	<=	16'h0000;
        counter_spi	<=  4'b0000;
	end else begin
		if(!ss) begin
		 	reg_mosi [0] 	<= mosi;
		 	counter_spi 	<= counter_spi + 1'b1;
		 	reg_miso		<= reg_miso << 1'b1;
		end else 
			counter_spi <= 4'b0000;
	end
end

always @(negedge sclk) begin
	if(!ss && (counter_spi != 4'b0000)) begin
		reg_mosi	<= reg_mosi << 1'b1;
	end
end

assign miso = reg_miso[15];

assign sclk = b_pclk;

assign trans_apb =(counter_spi == 4'b1111)? !trans_apb : 1'b0;


// apb interface
always @(posedge sclk or negedge resetn) begin
	if(resetn) begin
		counter_apb <= 4'b0000;
	end else begin
		if(trans_apb) begin
			counter_apb <= counter_apb + 1'b1; 
		end
	end
end

assign	b_paddr		= reg_mosi[10:8];
assign	b_pwrite	= reg_mosi[15];
assign	b_psel		= reg_mosi[14:12];
assign	b_penable	= 1'b1;

endmodule