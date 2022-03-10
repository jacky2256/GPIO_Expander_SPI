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
                        output	reg	[DATA_WIDTH-1:0]		b_pwdata,
                        output	reg							b_pwrite,
                        output		[BANK_ADDR-1:0]			b_psel,
                        output								b_penable,
                        output	reg	[ADDR_WIDTH-1:0]		b_paddr
                        );

reg		[15: 0]				reg_mosi;
reg 	[15: 0]				reg_miso;
					
reg 	[3 : 0] 			counter_spi;
reg		[3 : 0] 			counter_apb;
reg		[BANK_ADDR-1:0]		reg_psel;

wire					en_pwrite;
wire					en_paddr;
wire					en_psel;
wire					en_penable_w;
wire					en_penable_r;
wire					en_psel_w;
wire					en_psel_r;
wire					en_pwdata;
	
reg						off_signal;
reg						en_sclk;
reg						off_penable;
reg						start;

//spi interface
always @(posedge sclk or negedge resetn) begin
	if(!resetn) begin
		reg_mosi	<=	'h0;
        counter_spi	<=  'b00;
	end else begin
		if(!ss) begin
		 	reg_mosi [0] 	<= mosi;
		 	counter_spi 	<= counter_spi + 1'b1;
		end else 
			counter_spi <= 4'b0000;
	end
end

always @(negedge sclk or negedge resetn) begin
	if(!resetn) begin
		reg_miso 	<=	'h0;
	end else begin
		if(!ss && (counter_spi != 4'b0000)) begin
		reg_mosi	<= reg_mosi << 1'b1;
		reg_miso	<= reg_miso << 1'b1;
		end
	end
end

assign miso = reg_miso[15];

// apb interface
always @(negedge sclk or negedge resetn or posedge b_pready) begin
	if(!resetn) begin
		b_pwrite	<= 'b0; 
		b_paddr		<= 'h0;
		reg_psel	<= 'h0;
	end else begin
			b_pwrite <= (en_pwrite)? reg_mosi[0] : b_pwrite;
			b_paddr	 <= (en_paddr)?  reg_mosi[2:0] : b_paddr;
			reg_psel <=	(en_reg_psel)?  reg_mosi[1:0] : reg_psel;
	end
end


always @(posedge sclk or negedge resetn or posedge b_pready) begin
	if(!resetn) begin
		off_signal <= 'b0;
	end else begin
		off_signal <= (b_pready)? 1'b1 : 1'b0; 
	end
end


assign 	b_pclk		= sclk;
assign	en_pwrite	= (counter_spi == 4'h1)? 1'b1 : 1'b0;
assign  en_paddr	= (counter_spi == 4'h6)? 1'b1 : 1'b0;		
assign  en_prdata	= (counter_spi == 4'h9)? 1'b1 : 1'b0;
assign 	en_reg_psel	= (counter_spi == 4'h3)? 1'b1 : 1'b0;

assign  en_psel_w	= ((counter_spi == 4'hf || counter_spi == 4'h0) && b_pwrite && !ss)? 1'b1 : 1'b0;
assign  en_psel_r	= ((counter_spi == 4'h7 || counter_spi == 4'h8) && !b_pwrite)? 1'b1 : 1'b0;

assign	en_penable_w	= (counter_spi == 4'h0 && b_pwrite && !ss)? 1'b1 : 1'b0;
assign	en_penable_r	= ((counter_spi == 4'h8) && !b_pwrite)? 1'b1 : 1'b0;	

assign  b_presetn	= resetn; 
assign  en_pwdata	= (counter_spi == 4'h0 && !ss)? 1'b1 : 1'b0;

assign b_psel		= (en_psel_w & start)? reg_psel : (en_psel_r)? reg_psel : 'b0;
assign b_penable	= (b_pwrite & start)? en_penable_w : en_penable_r;

always @(posedge sclk or negedge resetn or posedge ss) begin
	if(~resetn) begin
		start <= 'b0;
	end else begin
		if(!ss)
			start <= (counter_spi == 4'h1)? 1'b1 : start;
		else 
			start <= 'b0;
	end
end

always @(*) begin
	if(b_pwrite) 
		b_pwdata <= (en_pwdata)? reg_mosi[7:0] : b_pwdata;
	else
		b_pwdata <= 'h0;
end

always @(negedge sclk) begin
	if(!b_pwrite && b_penable)
		reg_miso [15:8] <= b_prdata; 
end


endmodule