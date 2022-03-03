`timescale 1ns/1ps
`include "spi2apb_bridge.v"

module spi2apb_bridge_tb#(
			        parameter BANK_NUM      = 	2,
				parameter DATA_WIDTH 	= 	8,
				parameter ADDR_WIDTH	=	3
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
wire b_presetn;
wire b_pwrite;
wire b_penable;
wire [BANK_NUM-1   : 0] b_psel;
wire [DATA_WIDTH-1 : 0] b_pwdata;
wire [ADDR_WIDTH-1 : 0] b_paddr;
reg  [DATA_WIDTH-1 : 0] b_prdata;

reg [15:0] reg_mosi_tb;
reg [15:0] reg_miso_tb;

spi2apb_bridge i0(      .sclk(sclk),            .resetn(resetn),        .mosi(mosi),            .miso(miso),            .ss(ss),
                        .b_pready(b_pready),    .b_pclk(b_pclk),        .b_presetn(b_presetn),  .b_pwrite(b_write),     .b_penable(b_penable),
                        .b_psel(b_psel),        .b_pwdata(b_pwdata),    .b_paddr(b_paddr),      .b_prdata(b_prdata));


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
                        b_pready = (i == 15)? 1'b1 : 1'b0;
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
        clk = 0;
        sclk = 0;
        resetn = 1;
        ss = 1;
        reg_mosi_tb = 16'h0000;
        reg_miso_tb = 16'h0000;
        b_pready    = 1'b0;
        b_prdata    = 'h0;
end

initial begin
        $dumpfile("spi2apb_bridge_tb.vcd");
        $dumpvars(0, spi2apb_bridge_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
        en_trans(16'hd5f9);
       /* #100
        en_trans(16'h1234);
        #100
        en_trans(16'h7645);
        #100
        $display("Test complet");
        */
        #500 $finish;
end

//assign miso = (!ss)? reg_miso_tb[15] : 1'b0;

always #10 clk = !clk; 

endmodule