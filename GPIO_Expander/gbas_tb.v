`timescale 1ns/1ps
`include "gbas.v"

module gbas_tb#(
                    parameter DATA_WIDTH = 8,
                    parameter ADDR_WIDTH = 3
                )();

reg					            pclk;
reg 				            presetn;
reg		[ADDR_WIDTH - 1 : 0]	paddr;
reg 				            pwrite;
reg 				            pselx;
reg 				            penable;
reg 	[DATA_WIDTH - 1 : 0]	pwdata;
wire	[DATA_WIDTH - 1 : 0]	prdata;
wire				            pready;

reg		    [7 : 0]          y;
wire        [7 : 0]          oe;
wire        [7 : 0]          pu;
wire        [7 : 0]          pd;
wire        [7 : 0]          a;

gbas i0(   .pclk(pclk),        .presetn(presetn),  .paddr(paddr),
           .pwrite(pwrite),    .pselx(pselx),      .penable(penable),
           .pwdata(pwdata),    .prdata(prdata),    .pready(pready), 
           .y(y),              .oe(oe),            .pu(pu), 
           .pd(pd),            .a(a));

task test_wr(input [ADDR_WIDTH - 1 : 0] adrr,
            input onn_off);
    integer i;
    begin

        pwdata = (onn_off)? 8'b0000_0000 : 8'hff;
        @(posedge pclk);
        paddr = adrr;
        pwrite  = 1;
        pselx   = 1;
        @(posedge pclk);
        penable = 1;
        @(posedge pclk);
        pselx   = 0;
        penable = 0;

        $display($time, " ns ");
        $display("oe = %b ", oe);
        $display("pu = %b ", pu);
        $display("pd = %b ", pd);
        $display("a  = %b ", a);

        pwdata = (onn_off)? 8'b0000_0001 : 8'h7f;
        for(i = 0; i < 8; i = i + 1) begin
            @(posedge pclk);
            paddr = adrr;
            pwrite  = 1;
            pselx   = 1;
            @(posedge pclk);
            penable = 1;
            @(posedge pclk);
            pselx   = 0;
            penable = 0;
            if(onn_off) begin
                pwdata = pwdata << 1'b1;
                pwdata = pwdata + 1'b1;
            end else
                pwdata = pwdata >> 1'b1;
        
            $display($time, " ns ");
            $display("oe = %b ", oe);
            $display("pu = %b ", pu);
            $display("pd = %b ", pd);
            $display("a  = %b ", a);
        end
    end
endtask

task test_rd_y	(
				input [ADDR_WIDTH-1:0] addr
				);
    integer i;
	begin  
        y = 8'h00;
        for(i = 0; i < 256; i = i + 1) begin
	        @(posedge pclk);
            paddr = addr;
	        pwrite = 0;
	        pselx = 1;
	        @(posedge pclk);
	        penable = 1;
	        @(posedge pready);
	        @(posedge pclk);
	        pselx = 0;
	        penable = 0;
            $display($time, " ns y = %b prdata = %b", y, prdata);
            y = y + 1'b1;
        end
	end
endtask

task test_rw_rd(input [ADDR_WIDTH - 1 : 0] adrr);
    begin
        @(posedge pclk);
        paddr = adrr;
        pwrite  = 1;
        pselx   = 1;
        @(posedge pclk);
        penable = 1;
        @(posedge pclk);
        pselx   = 0;
        penable = 0;
        @(posedge pclk);
	    pwrite = 0;
	    pselx = 1;
	    @(posedge pclk);
	    penable = 1;
	    @(posedge pready);
	    @(posedge pclk);
	    pselx = 0;
	    penable = 0;
    end
endtask

initial begin
    $dumpfile("gbas_tb.vcd");
    $dumpvars(0, gbas_tb);
    pclk = 0;
    presetn = 1;
    paddr = 8'hff;
    pwrite = 0;
    pselx = 0;
    penable = 0;
    pwdata = 8'h00;
    y = 1'b0;
end

initial begin
    $display("Module %m");
    #5 presetn = 0;
    #5 presetn = 1;
    
    $display("writen oe, pu, pd, a:");
    test_wr(3'b000, 1);
    test_wr(3'b001, 1);
    test_wr(3'b010, 1);
    test_wr(3'b011, 1);
    
    test_wr(3'b000, 0);
    test_wr(3'b001, 0);
    test_wr(3'b010, 0);
    test_wr(3'b011, 0);

    $display("reading y:");
    
    test_rd_y(3'b100);
    
    $display("reading oe:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(3'b000);
        $display($time, " ns oe = %b prdata = %b", oe, prdata);
        pwdata = pwdata + 1'b1;
    end
    
    $display("reading pu:");
    pwdata = 'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(3'b001);
        $display($time, " ns pu = %b prdata = %b", pu, prdata);
        pwdata = pwdata + 1'b1;
    end
    
    $display("reading pd:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(3'b010);
        $display($time, " ns pd = %b prdata = %b", pd, prdata);
        pwdata = pwdata + 1'b1;
    end

    $display("reading a:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(3'b011);
        $display($time, " ns a = %b prdata = %b", a, prdata);
        pwdata = pwdata + 1'b1;
    end 
    
    $display("Test completed") ;

    #1000 $finish;
end

always #10 pclk = !pclk;

endmodule