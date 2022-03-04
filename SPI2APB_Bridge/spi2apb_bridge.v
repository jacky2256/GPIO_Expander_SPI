module spi2apb_bridge #(
						parameter BANK_ADDR		= 	2,
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
                        output	reg	[BANK_ADDR-1	:	0]		b_psel,
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
wire en_penable_w;
wire en_penable_r;
reg en_pwdata;
reg en_sclk;

//spi interface
always @(posedge sclk or negedge resetn) begin
	if(!resetn) begin
		reg_miso 	<=	16'hffff;
		reg_mosi	<=	16'h0000;
        counter_spi	<=  4'b0000;
	end else begin
		if(!ss) begin
		 	reg_mosi [0] 	<= mosi;
		 	counter_spi 	<= counter_spi + 1'b1;
		end else 
			counter_spi <= 4'b0000;
	end
end

always @(negedge sclk) begin
	if(!ss && (counter_spi != 4'b0000)) begin
		reg_mosi	<= reg_mosi << 1'b1;
		reg_miso	<= reg_miso << 1'b1;
	end
end

assign miso = reg_miso[15];

// apb interface
always @(negedge sclk or negedge resetn or posedge b_pready) begin
	if(!resetn) begin
		b_pwrite <= 1'b0; 
		b_paddr	 <= 7'h0;
		b_psel	 <= 8'h0;
	end else begin
		if(b_pready) begin
			b_psel	<= 'b0;
		end else begin
			b_pwrite <= (en_pwrite)? reg_mosi[0] : b_pwrite;
			b_paddr	 <= (en_paddr)?  reg_mosi[2:0] : b_paddr;
			b_psel	 <= (en_psel)?	 reg_mosi[BANK_ADDR-1:0] : b_psel; 
		end
	end
end

always @(posedge sclk or negedge resetn or negedge b_pready) begin
	if(!resetn) begin
		b_penable <= 1'b0;
	end else begin
		if(!b_pready) begin
			b_penable <= 1'b0;
		end else begin 
			b_penable <= (en_penable_w || en_penable_r)?  1'b1 : b_penable;
		end
	end
end

assign 	b_pclk			= sclk;
assign	en_pwrite		= (counter_spi == 4'h1)? 1'b1 : 1'b0;
assign  en_paddr		= (counter_spi == 4'h6)? 1'b1 : 1'b0;
assign  en_psel			= (counter_spi == 4'h3)? 1'b1 : 1'b0;		
assign  en_prdata		= (counter_spi == 4'h8)? 1'b1 : 1'b0;

assign	en_penable_w	= ((counter_spi == 4'h0 || counter_spi == 4'hf) && b_pwrite)? 1'b1 : 1'b0;
assign	en_penable_r	= ((counter_spi == 4'h6 || counter_spi == 4'h7) && !b_pwrite)? 1'b1 : 1'b0;	

assign  b_presetn 	= resetn; 
assign  b_pwdata    = reg_mosi[7:0];

always @(negedge sclk or negedge resetn) begin
	//if(!b_pwrite && counter_spi == 4'h8)
	if(!b_pwrite && b_penable)
		reg_miso [15:8] <= b_prdata; 
end


endmodule