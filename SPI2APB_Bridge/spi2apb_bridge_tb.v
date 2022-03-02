`timescale 1ns/1ps
`include "spi2apb_bridge.v"

module spi2apb_bridge_tb();
reg     clk;
reg     sclk;
reg     resetn;
reg     mosi;
reg     ss;
wire	miso;

reg [15:0] reg_mosi_tb;
reg [15:0] reg_miso_tb;

spi2apb_bridge i0(.sclk(sclk), .resetn(resetn), .mosi(mosi), .miso(miso), .ss(ss));

initial begin
        clk = 0;
        sclk = 0;
        resetn = 1;
        ss = 1;
        reg_mosi_tb = 16'hffff;
        reg_miso_tb = 16'h0000;
end

task en_transmit(); 
integer i;
        begin
                @(posedge clk);
                ss = 0;
                reg_mosi_tb = 16'hffff;

                mosi = reg_mosi_tb[0];
                reg_miso_tb [15] = miso;

                for(i = 0; i < 32; i = i + 1) begin
                        @(posedge clk);
                        sclk = !sclk;
                        if(!sclk) begin 
                            reg_mosi_tb = reg_mosi_tb >> 1'b1;
                            mosi = reg_mosi_tb[0];
                            reg_miso_tb [15] = (i < 30)? miso : reg_miso_tb [15];
                        end
                        @(posedge clk);
                        if(i < 30)
                                reg_miso_tb = (sclk)? (reg_miso_tb >> 1'b1) : reg_miso_tb;
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
        en_transmit();
        $display("Test complet");
        #100 $finish;
end

always #10 clk = !clk; 

endmodule