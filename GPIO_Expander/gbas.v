 module gbas#(
				parameter DATA_WIDTH = 8,
				parameter ADDR_WIDTH = 3,
				parameter PREADY_DEL = 0
				)(
				input 							pclk,
				input 							presetn,
				input 		[ADDR_WIDTH-1 : 0]	paddr,
				input 							pwrite,
				input 							pselx,
				input 							penable,
				input 		[DATA_WIDTH-1 : 0]	pwdata,
				output  reg	[DATA_WIDTH-1 : 0]	prdata,
				output 							pready,

				input		[7 : 0]            	y,
				output		[7 : 0]            	oe,
				output		[7 : 0]            	pu,
				output		[7 : 0]            	pd,
				output		[7 : 0]            	a
				);

reg [7:0] reg_oe;
reg [7:0] reg_pu;
reg [7:0] reg_pd;
reg [7:0] reg_a;
reg [7:0] reg_y;


reg 	[1:0] 	 counter;
wire 	[7:0]	 wire_y;
wire 			 r_counter_en;
wire 			 w_counter_en;
reg 			 pready_reg;
wire 			 write_en;
wire 			 read_en;

assign write_en = 	 pwrite & pselx;
assign read_en	=	!pwrite & pselx;

always @(negedge presetn) begin
	if(!presetn) begin
		reg_oe	<= 8'h00;
		reg_pd	<= 8'h00;
		reg_pu	<= 8'h00;
		reg_a	<= 8'h00;
	end 
end

always @(*) begin
	if(read_en & penable & pready) begin
		case (paddr)
			8'h00 : prdata <= reg_oe;
			8'h01 : prdata <= reg_pu;
			8'h02 : prdata <= reg_pd;
			8'h03 : prdata <= reg_a;
			8'h04 : prdata <= reg_y;
			default : prdata <= 8'h00;
		endcase
	end else if(write_en & pready & penable) begin
		case (paddr)
			8'h00 : reg_oe	<= pwdata;
			8'h01 : reg_pu	<= pwdata;
			8'h02 : reg_pd	<= pwdata;
			8'h03 : reg_a 	<= pwdata;
		endcase
	end else 
		prdata <= 8'h00;
end

always @(posedge pclk or negedge presetn) begin
	if(!presetn) begin
		counter <= 2'b0;
		pready_reg <= 1'b0;
	end else begin
		if(read_en || write_en) begin
			pready_reg <= (PREADY_DEL == 0)? 1'b1 : (counter == PREADY_DEL)? 1'b1 : 1'b0;
			counter <= (pready_reg)? 2'b00 : counter + 1'b1;
		end else 
			pready_reg <= 1'b0; 
	end
end

always @(posedge pclk or  negedge presetn) begin
	if(!presetn)
		reg_y <= 1'b0;
	else 
		reg_y <= y;
end

assign pready = (read_en && penable)? pready_reg : (write_en && penable)? (pselx & penable) : 1'b0;

assign pready = pselx & penable;

assign oe = reg_oe;
assign pu = reg_pu;
assign pd = reg_pd;
assign a  = reg_a;

endmodule

