`timescale 1ns/1ps
`include "gbas.v"

module gbas_tb#(
                    parameter DATA_WIDTH = 8,
                    parameter ADDR_WIDTH = 8
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
reg     [DATA_WIDTH - 1 : 0]    reg_reading;
reg     [DATA_WIDTH - 1 : 0]    reg_writing;

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
            reg_reading = prdata;
            if(y != reg_reading) begin
                $display($time, " ns y = %b prdata = %b Error", y, reg_reading);
            end
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
        @(posedge pready);
        @(posedge pclk);
        @(posedge pclk);
        reg_writing = pwdata;

        @(posedge pclk);
	    pwrite = 0;
	    pselx = 1;
	    @(posedge pclk);
	    penable = 1;
	    @(posedge pready);
	    @(posedge pclk);
	    pselx = 0;
	    penable = 0;
        reg_reading = prdata;
    end
endtask

initial begin
    $dumpfile("hello_tb.vcd");
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

    $display("Test reading y:");
    test_rd_y(8'h04);

    $display("Test writing and reading oe:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(8'h00);
        if(oe != pwdata)
            $display($time, " ns oe = %b pwdata = %b Error", oe, pwdata);
        if(oe != prdata)
            $display($time, " ns oe = %b prdata = %b Error", oe, prdata);
        pwdata = pwdata + 1'b1;
    end

    $display("Test writing and reading pu:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(8'h01);
        if(pu != pwdata)
            $display($time, " ns pu = %b pwdata = %b Error", pu, pwdata);
        if(pu != prdata)
            $display($time, " ns pu = %b prdata = %b Error", pu, prdata);
        pwdata = pwdata + 1'b1;
    end
    
    $display("Test writing and reading pd:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(8'h02);
        if(pd != pwdata)
            $display($time, " ns pd = %b pwdata = %b Error", pd, pwdata);
        if(pd != prdata)
            $display($time, " ns pd = %b prdata = %b Error", pd, prdata);
        pwdata = pwdata + 1'b1;
    end

    $display("Test writing and reading a:");
    pwdata = 8'h00;
    for(integer i = 0; i < 256; i = i + 1) begin
        test_rw_rd(8'h03);
        if(a != pwdata)
            $display($time, " ns a = %b pwdata = %b Error", a, pwdata);
        if(a != prdata)
            $display($time, " ns a = %b prdata = %b Error", a, prdata);
        pwdata = pwdata + 1'b1;
    end

    $display("Test completed") ;

    #1000 $stop;
end

always #10 pclk = !pclk;

endmodule