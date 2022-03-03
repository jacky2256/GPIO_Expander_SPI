module spi2apb_bridge #(
						parameter BANK_NUM 		= 	2,
						parameter DATA_WIDTH 	= 	8,
						parameter ADDR_WIDTH	=	3
						)(
                        input 			sclk,
                        input 			resetn,
                        input 			mosi,
                        input 			ss,
                        output 			miso,

                        input		[DATA_WIDTH-1 : 0]		b_prdata,
                        input								b_pready,
                        output								b_pclk,
                        output								b_presetn,
                        output		[DATA_WIDTH-1 : 0]		b_pwdata,
                        output	reg							b_pwrite,
                        output	reg	[BANK_NUM-1	:	0]		b_psel,
                        output	reg							b_penable,
                        output	reg	[ADDR_WIDTH-1 : 0]		b_paddr
                        );

reg	[15: 0]	reg_mosi;
reg [15: 0]	reg_miso;

reg [3 : 0] counter_spi;
reg	[3 : 0] counter_apb;

wire en_pwrite;
wire en_paddr;
wire en_psel;
wire en_penable;

reg en_sclk;

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

// apb interface
always @(negedge sclk or negedge resetn) begin
	if(!resetn) begin
		b_pwrite <= 1'b0; 
		b_paddr	 <= 7'h0;
		b_psel	 <= 8'h0;
		b_penable <= 1'b0;
	end else begin
		if(b_pready) begin
			b_pwrite <= (en_pwrite)? reg_mosi[0] : b_pwrite;
			b_paddr	 <= (en_paddr)?  reg_mosi[2:0] : b_paddr;
			b_psel	 <= (en_psel)?	 reg_mosi[BANK_NUM-1:0] : b_psel; 
			b_penable <= (en_penable)?  1'b1 : b_penable;
		end else begin
			b_psel	<= 'b0;
			b_penable <= 1'b0;
		end
	end
end

assign 	b_pclk		= sclk;
assign	en_pwrite	= (counter_spi == 4'h1)? 1'b1 : 1'b0;
assign  en_paddr	= (counter_spi == 4'h8)? 1'b1 : 1'b0;
assign  en_psel		= (counter_spi == 4'h3)? 1'b1 : 1'b0;	
assign	en_penable	= (counter_spi == 4'hd)? 1'b1 : 1'b0;	
assign  b_presetn 	= resetn; 
assign  b_pwdata    = reg_mosi[7:0];


endmodule