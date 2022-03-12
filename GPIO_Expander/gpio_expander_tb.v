`timescale 1ns/1ps
`include "gpio_expander.v"

module gpio_expander_tb#(
                            parameter BANK_NUM      =   2,
                            parameter DATA_WIDTH    =   16,
                            parameter PDATA_WIDTH   =   8,
                            parameter ADDR_WIDTH    =   7,
                            parameter PADDR_WIDTH   =   3
                            )(
                            );

reg clk;
reg	sclk;
reg	resetn;
wire	miso_tb;
wire    mosi_tb;
reg	ss;
						
wire [15:0]	pad_tb[3:0];

reg [15:0] reg_mosi_tb;
reg [15:0] reg_miso_tb;
reg [15:0] reg_pad;

reg [15:0] pad_tb_i; 

integer i;
integer j;
 
assign (strong0, strong1) pad_tb[1] =(en_driver)? pad_tb_i : 1'bz;
reg en_driver;
assign pad_tb[3] = (en_driver)? pad_tb[1] : pad_tb[0];

gpio_expander i0(.sclk(sclk), .resetn(resetn), .miso(miso_tb), .mosi(mosi_tb), .ss(ss), .pad(pad_tb[3]));


task spi_xfer(input [DATA_WIDTH-1:0] data_in, output reg [DATA_WIDTH-1:0] data_out);
        begin
                data_out = 'h0;
                reg_mosi_tb[0] = data_in;

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        data_out[0] = miso_tb;
                        @(posedge clk);
                        reg_mosi_tb = reg_mosi_tb << 1;
                        data_out = (i == 15)? data_out :data_out << 1;
                        sclk = !sclk;
                end
        end
endtask

assign mosi_tb = reg_mosi_tb[15];

task write_reg(input [1:0] sel, input [2:0] addr, input [PDATA_WIDTH-1:0] data);
        begin
                en_driver = 0;
                reg_mosi_tb[15] = 1;  
                reg_mosi_tb[14:13] = sel;
                reg_mosi_tb[12:10] = addr;
                reg_mosi_tb[9:8] = 'h0;
                reg_mosi_tb[7:0] = data;
                @(posedge clk);
                ss = 0;
                spi_xfer(reg_mosi_tb, reg_miso_tb); 
                @(posedge clk);
                @(posedge clk);
                ss = 1; 
                $display("pad = %h ", pad_tb[3]);
        end
endtask

task read_reg(input [1:0] sel, input [2:0] addr);
        begin
                en_driver = 0;
                reg_mosi_tb[15] = 0;  
                reg_mosi_tb[14:13] = sel;
                reg_mosi_tb[12:10] = addr;
                reg_mosi_tb[9:8] = 'h0;
                reg_mosi_tb[7:0] = 'h0;
                @(posedge clk);
                ss = 0; 
                spi_xfer(reg_mosi_tb, reg_miso_tb); 
                @(posedge clk);
                @(posedge clk);
                ss = 1;  
                $display("reg_miso = %h ", reg_miso_tb);
        end
endtask

task write_with_driver(input [1:0] sel, input [2:0] addr, input [DATA_WIDTH-1:0] data, input [PDATA_WIDTH-1:0] y);
        begin
                en_driver = 1;
                pad_tb_i = y;

                reg_mosi_tb[15] = 1;  
                reg_mosi_tb[14:13] = sel;
                reg_mosi_tb[12:10] = addr;
                reg_mosi_tb[9:8] = 'h0;
                reg_mosi_tb[7:0] = data;
                @(posedge clk);
                ss = 0;
                spi_xfer(reg_mosi_tb, reg_miso_tb); 
                @(posedge clk);
                @(posedge clk);
                ss = 1; 
                $display("pad = %h ", pad_tb[3]);
        end
endtask

task read_with_driver(input [1:0] sel, input [2:0] addr, input [PDATA_WIDTH-1:0] y);
    begin
        @(posedge clk);
                en_driver = 1;
                pad_tb_i = y;

                ss = 0;
                reg_mosi_tb[15] = 0;  
                reg_mosi_tb[14:13] = sel;
                reg_mosi_tb[12:10] = addr;
                reg_mosi_tb[9:8] = 'h0;
                reg_mosi_tb[7:0] = 'h0;
                @(posedge clk);
                ss = 0;
                spi_xfer(reg_mosi_tb, reg_miso_tb); 
                @(posedge clk);
                @(posedge clk);
                ss = 1;
                $display("reg_miso = %h ", reg_miso_tb);  
    end
endtask


initial begin
        clk = 0;
        sclk = 0;
        resetn = 1;
        ss = 2'b11;
        reg_mosi_tb = 16'h0000;
        reg_miso_tb = 16'h0000;
        reg_mosi_tb = 16'h0000;
        reg_miso_tb = 16'h0000;
        pad_tb_i = 'h0;
        en_driver = 0;
end


initial begin
        $dumpfile("gpio_expander_tb.vcd");
        $dumpvars(0, gpio_expander_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
        
        $display("\nWrite no driver: \n");
        write_reg(2'b01, 3'b001, 8'hff);
        write_reg(2'b10, 3'b010, 8'hff);

        $display("\nRead no driver: \n");
        read_reg(2'b01, 3'b001);
        read_reg(2'b10, 3'b010);
        
        $display("\nWrite with driver: \n");
        write_with_driver(2'b01, 3'b000, 8'hff, 16'h00ff);
        write_with_driver(2'b10, 3'b000, 8'hff, 16'h00ff);
        
        $display("\nRead with driver: \n");
        read_with_driver(2'b01, 3'b100, 16'h00ff);
        read_with_driver(2'b10, 3'b100, 16'h00ff);
        
        #500 $finish;
end

always #10 clk = !clk;
endmodule