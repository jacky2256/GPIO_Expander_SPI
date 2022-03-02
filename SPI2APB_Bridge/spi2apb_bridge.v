module spi2apb_bridge(
                        input 			sclk,
                        input 			resetn,
                        input 			mosi,
                        input 			ss,
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

reg	[15: 0]	reg_mosi;
reg [15: 0]	reg_miso;
reg [3 : 0] counter;

always @(posedge sclk or negedge resetn) begin
	if(!resetn) begin
		reg_miso 	<=	16'hffff;
		reg_mosi	<=	16'h0000;
        counter     <=  4'b0000;
	end else begin
		if(!ss) begin
		 	reg_mosi [15] 	<= mosi;
		 	counter 		<= counter + 1'b1;
		 	reg_miso	<= reg_miso << 1'b1;
		end else 
			counter <= 4'b0000;
	end
end

always @(negedge sclk) begin
	if(!ss && (counter != 4'b0000)) begin
		reg_mosi	<= reg_mosi >> 1'b1;
	end
end

assign miso = reg_miso[15];

endmodule