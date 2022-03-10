`timescale 1ns/1ps
`include "spi2apb_bridge.v"
`include "apb_monitor.v"

module spi2apb_bridge_tb#(
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

wire    mosi_tb;
reg     ss;
wire	miso_tb;

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

integer i;

spi2apb_bridge i0(  .sclk(sclk),	        .resetn(resetn),        .mosi(mosi_tb), 	         .miso(miso_tb),		.ss(ss),
                    .b_pready(tb_pready),    .b_pclk(tb_pclk_a),        .b_presetn(tb_presetn),  
                    .b_pwrite(tb_pwrite),    .b_psel(tb_psel),        .b_penable(tb_penable),       
                    .b_pwdata(tb_pwdata),    .b_paddr(tb_paddr),      .b_prdata(tb_prdata));

apb_monitor i1(     .m_pready(tb_pready),    .m_pclk(tb_pclk_a),        .m_presetn(tb_presetn),  
                    .m_pwrite(tb_pwrite),    .m_psel(tb_psel),        .m_penable(tb_penable),       
                    .m_pwdata(tb_pwdata),    .m_paddr(tb_paddr),      .m_prdata(tb_prdata));


task spi_xfer(input [DATA_WIDTH-1:0] data_in, output reg [DATA_WIDTH-1:0] data_out);
        begin
                data_out = 'h0;
                reg_mosi_tb = data_in;

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
                reg_mosi_tb [15] = 1;  
                reg_mosi_tb [14:13] = sel;
                reg_mosi_tb [12:10] = addr;
                reg_mosi_tb [9:8] = 'h0;
                reg_mosi_tb [7:0] = data;
                @(posedge clk);
                ss = 0;
                spi_xfer(reg_mosi_tb, reg_miso_tb); 
                @(posedge clk);
                @(posedge clk);
                ss = 1; 
        end
endtask

task read_reg(input [1:0] sel, input [2:0] addr);
        begin
                reg_mosi_tb [15] = 0;  
                reg_mosi_tb [14:13] = sel;
                reg_mosi_tb [12:10] = addr;
                reg_mosi_tb [9:8] = 'h0;
                reg_mosi_tb [7:0] = 'h0;
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
        ss = 1;
        reg_mosi_tb = 16'h0000;
        reg_miso_tb = 16'h0000;
end

initial begin
        $dumpfile("spi2apb_bridge_tb.vcd");
        $dumpvars(0, spi2apb_bridge_tb);
        $display("Module %m") ;
        #3 resetn = 0;
        #3 resetn = 1;
        #100
        $display("Write: ") ;
        write_reg(2'b01, 3'b000, 8'hff);
        #100
        $display("Read: ") ;
        read_reg(2'b01, 3'b000);
        #500 $finish;
end

always #10 clk = !clk; 

endmodule

