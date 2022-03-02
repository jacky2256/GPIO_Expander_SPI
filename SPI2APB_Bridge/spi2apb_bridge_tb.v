`timescale 1ns/1ps
`include "spi2apb_bridge.v"

module spi2apb_bridge_tb#(
			        parameter BANK_NUM      = 	3,
				parameter DATA_WIDTH 	= 	8,
				parameter ADDR_WIDTH	=	7
				)
                                ();
reg     clk;
reg     sclk;
reg     resetn;
reg     mosi;
reg     ss;
wire	miso;

reg b_pready;
wire b_pclk;
wire b_resetn;
wire b_pwrite;
wire b_penable;
wire [BANK_NUM-1   : 0] b_psel;
wire [DATA_WIDTH-1 : 0] b_pwdata;
wire [ADDR_WIDTH-1 : 0] b_paddr;
reg  [DATA_WIDTH-1 : 0] b_prdata;

reg [15:0] reg_mosi_tb;
reg [15:0] reg_miso_tb;

spi2apb_bridge i0(.sclk(sclk), .resetn(resetn), .mosi(mosi), .miso(miso), .ss(ss));

initial begin
        clk = 0;
        sclk = 0;
        resetn = 1;
        ss = 1;
        reg_mosi_tb = 16'h0000;
        reg_miso_tb = 16'h0000;
end

task en_trans(input [15:0] data_mosi);
integer i;
        begin
                @(posedge clk);
                ss = 0;
                reg_mosi_tb = data_mosi;
                mosi = reg_mosi_tb[15];
                reg_miso_tb[0] = miso;

                for(i = 0; i < 16; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        reg_miso_tb = reg_miso_tb << 1'b1;
                        @(posedge clk);
                        reg_mosi_tb = reg_mosi_tb << 1'b1;
                        @(posedge clk);
                        sclk = !sclk;
                        mosi = reg_mosi_tb[15];
                        reg_miso_tb[0] = (i != 15)? miso : reg_miso_tb[0];
                        @(posedge clk);
                end
                @(posedge clk);
                ss = 1;
        end
endtask

initial begin
        $dumpfile("spi2apb_bridge_tb.vcd");
        $dumpvars(0, spi2apb_bridge_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
        en_trans(16'hffff);
        #100
        en_trans(16'h1234);
        #100
        en_trans(16'h7645);
        #100
        $display("Test complet");
        #100 $finish;
end

//assign miso = (!ss)? reg_miso_tb[15] : 1'b0;

always #10 clk = !clk; 

endmodule