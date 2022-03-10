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
wire	[1:0] miso_tb;
wire    [1:0] mosi_tb;
reg	[1:0] ss;
						
wire [15:0]	pad_tb[1:0];

reg [15:0] reg_mosi_tb [1:0];
reg [15:0] reg_miso_tb [1:0];
reg [15:0] reg_pad;

reg [15:0] pad_tb_i; 


assign (strong0, strong1) pad_tb[1] = pad_tb_i;

gpio_expander i0(.sclk(sclk), .resetn(resetn), .miso(miso_tb[0]), .mosi(mosi_tb[0]), .ss(ss[0]), .pad(pad_tb[0]));

gpio_expander i1(.sclk(sclk), .resetn(resetn), .miso(miso_tb[1]), .mosi(mosi_tb[1]), .ss(ss[1]), .pad(pad_tb[1]));


function automatic reg [15:0] spi_xfer_ndrive;
input 	[DATA_WIDTH-1:0] 	data_in;
reg 	[15:0] 				rd_mosi;
        begin
                reg_mosi_tb[0] = data_in << 1;
                rd_mosi[15:1] = 'h0;
                rd_mosi = miso_tb[0];
                spi_xfer_ndrive = rd_mosi;
        end
endfunction

function automatic reg [15:0] spi_xfer_wdrive;
input   [DATA_WIDTH-1:0]    data_in;
reg     [15:0]              rd_mosi;
        begin
                reg_mosi_tb[1] = data_in << 1;
                rd_mosi[15:1] = 'h0;
                rd_mosi = miso_tb[1];
                spi_xfer_wdrive = rd_mosi;
        end
endfunction


assign mosi_tb[0] = reg_mosi_tb[0][15];
assign mosi_tb[1] = reg_mosi_tb[1][15];

task write_reg(input [1:0] sel, input [2:0] addr, input [PDATA_WIDTH-1:0] data);
integer i;
        begin

             @(posedge clk);
                ss[0] = 0;
                reg_mosi_tb [0][15] = 1;  
                reg_mosi_tb [0][14:13] = sel;
                reg_mosi_tb [0][12:10] = addr;
                reg_mosi_tb [0][9:8] = 'h0;
                reg_mosi_tb [0][7:0] = data;   

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        reg_miso_tb[0] = reg_miso_tb[0] << 1;
                        #10
                        reg_miso_tb[0] =  reg_miso_tb[0] + spi_xfer_ndrive(reg_mosi_tb[0]);
                        @(posedge clk);
                        sclk = !sclk;
                end
                @(posedge clk);
                ss[0] = 1;
        end
endtask

task read_reg(input [1:0] sel, input [2:0] addr);
integer i;
        begin

             @(posedge clk);
                ss[0] = 0;
                reg_mosi_tb [0][15] = 0;  
                reg_mosi_tb [0][14:13] = sel;
                reg_mosi_tb [0][12:10] = addr;
                reg_mosi_tb [0][9:8] = 'h0;
                reg_mosi_tb [0][7:0] = 'h0;  

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        reg_miso_tb[0] = reg_miso_tb[0] << 1;
                        #10
                        reg_miso_tb[0] =  reg_miso_tb[0] + spi_xfer_ndrive(reg_mosi_tb[0]);
                        @(posedge clk);
                        sclk = !sclk;
                end
                @(posedge clk);
                ss[0] = 1;
        end
endtask

task read_with_driver(input [1:0] sel, input [2:0] addr, input [15:0] y);
    begin
        @(posedge clk);
                ss[1] = 0;
                reg_mosi_tb [1][15] = 0;  
                reg_mosi_tb [1][14:13] = sel;
                reg_mosi_tb [1][12:10] = addr;
                reg_mosi_tb [1][9:8] = sel;
                reg_mosi_tb [1][7:0] = 'h0;  

                pad_tb_i = y;

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        reg_miso_tb[1] = reg_miso_tb[1] << 1;
                        #10
                        reg_miso_tb[1] =  reg_miso_tb[1] + spi_xfer_wdrive(reg_mosi_tb[1]);
                        @(posedge clk);
                        sclk = !sclk;
                end
                @(posedge clk);
                ss[1] = 1;
    end
endtask

initial begin
        clk = 0;
        sclk = 0;
        resetn = 1;
        ss[1:0] = 1;
        reg_mosi_tb[0] = 16'h0000;
        reg_miso_tb[0] = 16'h0000;
        reg_mosi_tb[1] = 16'h0000;
        reg_miso_tb[1] = 16'h0000;
        pad_tb_i = 'h0;
end

integer i;

reg [7:0] data = 'h0;


initial begin
        $dumpfile("gpio_expander_tb.vcd");
        $dumpvars(0, gpio_expander_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
        $display("Write no driver: ");
        write_reg(2'b01, 3'b000, 8'hff);
        write_reg(2'b10, 3'b000, 8'hff);
        $display("pad = %h ", pad_tb[0]);

        $display("Read no driver: ");
        read_reg(2'b01, 3'b000);
        $display("reg_miso = %h ", reg_miso_tb[0]);

        $display("Read with driver: ");
        read_with_driver(2'b01, 3'b100, 16'hffff);
        $display("reg_miso = %h ", reg_miso_tb[1]);

        #500 $finish;
end

always #10 clk = !clk;
endmodule