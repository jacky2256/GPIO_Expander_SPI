`timescale 1ns/1ps
`include "spi2apb_bridge.v"
`include "apb_monitor.v"

module bridge_tb#(
			        parameter BANK_NUM      = 	2,
					parameter DATA_WIDTH 	= 	16,
                 	parameter PDATA_WIDTH 	=  	8,
					parameter ADDR_WIDTH	=	7,
                  	parameter PADDR_WIDTH   = 	3
				    )(
				    );
reg     clk;
reg     sclk;
reg     resetn;

wire    mosi;
reg     ss;
wire	miso;

wire tb_pclk_a;
wire tb_pclk_b;
wire tb_presetn;
wire tb_pwrite;
wire tb_penable;
wire [BANK_NUM-1   : 0]  tb_psel;
wire [PDATA_WIDTH-1 : 0] tb_pwdata;
wire [PADDR_WIDTH-1 : 0] tb_paddr;
wire [PDATA_WIDTH-1 : 0] tb_prdata;
wire tb_pready;

reg [15:0] reg_mosi_tb;
reg [15:0] reg_miso_tb;

spi2apb_bridge i0(  .sclk(sclk),	        .resetn(resetn),        .mosi(mosi), 	         .miso(miso),		.ss(ss),
                    .b_pready(tb_pready),    .b_pclk(tb_pclk_a),        .b_presetn(tb_presetn),  
                    .b_pwrite(tb_pwrite),    .b_psel(tb_psel),        .b_penable(tb_penable),       
                    .b_pwdata(tb_pwdata),    .b_paddr(tb_paddr),      .b_prdata(tb_prdata));

apb_monitor i1(     .m_pready(tb_pready),    .m_pclk(tb_pclk_a),        .m_presetn(tb_presetn),  
                    .m_pwrite(tb_pwrite),    .m_psel(tb_psel),        .m_penable(tb_penable),       
                    .m_pwdata(tb_pwdata),    .m_paddr(tb_paddr),      .m_prdata(tb_prdata));


function automatic reg [15:0] spi_xfer;
input [DATA_WIDTH-1:0] data_in;
reg [15:0] rd_mosi;
        begin
                reg_mosi_tb = data_in << 1;
                rd_mosi[15:1] = 'h0;
                rd_mosi[0] = miso;
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
        $dumpfile("bridge_tb.vcd");
        $dumpvars(0, bridge_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
        $display("Write: ") ;
        write_reg(7'h6c, 8'hf3);
        #100
        $display("Read: ") ;
        read_reg(7'h55);
        #500 $finish;
end


always #10 clk = !clk; 

endmodule

