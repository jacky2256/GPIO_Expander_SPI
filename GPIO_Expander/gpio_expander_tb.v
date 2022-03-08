`timescale 1ns/1ps
//`include "gpio_pad.v"
//`include "gbas.v"
//`include "spi2apb_bridge.v"
`include "gpio_expander.v"

module gpio_expander_tb#(
			        		parameter BANK_NUM      = 	2,
							parameter DATA_WIDTH 	= 	16,
                 			parameter PDATA_WIDTH 	=  	8,
							parameter ADDR_WIDTH	=	7,
                  			parameter PADDR_WIDTH   = 	3
				    		)(
				    		);

reg clk;
reg	sclk;
reg	resetn;
wire	miso_tb;
wire    mosi_tb;
reg	ss;
						
wire [7:0]	pad_tb;

reg [15:0] reg_mosi_tb;
reg [15:0] reg_miso_tb;


gpio_expander bridge(.sclk(sclk), .resetn(resetn), .miso(miso_tb), .mosi(mosi_tb), .ss(ss), .pad(pad_tb));
//gbas bank();
//gpio_pad pins();

function automatic reg [15:0] spi_xfer;
input 	[DATA_WIDTH-1:0] 	data_in;
reg 	[15:0] 				rd_mosi;
        begin
                reg_mosi_tb = data_in << 1;
                rd_mosi[15:1] = 'h0;
                rd_mosi[0] = miso_tb;
                spi_xfer = rd_mosi;
        end
endfunction


assign mosi = reg_mosi_tb[15];

task write_reg(input [ADDR_WIDTH-1:0] addr, input [PDATA_WIDTH-1:0] data);
integer i;
        begin

             @(posedge clk);
                ss = 0;
                reg_mosi_tb [15] = 1;  
                reg_mosi_tb [14:8] = addr;
                reg_mosi_tb [7:0] = data;  

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        reg_miso_tb = reg_miso_tb << 1;
                        #10
                        reg_miso_tb =  reg_miso_tb + spi_xfer(reg_mosi_tb);
                        @(posedge clk);
                        sclk = !sclk;
                end
                @(posedge clk);
                ss = 1;
        end
endtask

task read_reg(input [ADDR_WIDTH-1:0] addr);
integer i;
        begin

             @(posedge clk);
                ss = 0;
                reg_mosi_tb [15] = 0;  
                reg_mosi_tb [14:8] = addr;
                reg_mosi_tb [7:0] = 'h0;  

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        reg_miso_tb = reg_miso_tb << 1;
                        #10
                        reg_miso_tb =  reg_miso_tb + spi_xfer(reg_mosi_tb);
                        @(posedge clk);
                        sclk = !sclk;
                end
                @(posedge clk);
                ss = 1;
        end
endtask

initial begin
        clk = 0;
        sclk = 0;
        resetn = 1;
        ss = 1;
        reg_mosi_tb = 16'h0000;
        reg_miso_tb = 16'h0000;
end

initial begin
        $dumpfile("gpio_expander_tb.vcd");
        $dumpvars(0, gpio_expander_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
       // $display("Write: ") ;
        //write_reg(7'h20, 8'h81);
        //#100
        $display("Read: ") ;
        read_reg(7'h20);
        #500 $finish;
end

always #10 clk = !clk;
endmodule