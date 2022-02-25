`timescale 1ns/1ps
`include "GPIO_PAD.v"

module GPIO_PAD_tb();
wire	[1:0] pad;
reg    	padi;   	

reg		[1:0] a;
reg		[1:0] oe;			
reg		[1:0] pu;				
reg		[1:0] pd;				
wire	[1:0] y;

assign (strong0, strong1) pad[1] = (padi)? 1'b1: 1'b0;

GPIO_PAD n_driver(  .pad(pad[0]), .a(a[0]), .oe(oe[0]),
                .pu(pu[0]), .pd(pd[0]), .y(y[0]));

GPIO_PAD with_driver(  .pad(pad[1]), .a(a[1]), .oe(oe[1]),
                .pu(pu[1]), .pd(pd[1]), .y(y[1]));

task no_drive();
    reg [3:0] tb_reg;
    integer i;
	begin 

        tb_reg = 4'b0000;

        for(i = 0; i < 16; i = i + 1) begin
            #30
            tb_reg = tb_reg + 1'b1;

            a[0] = tb_reg[3];
            oe[0] = tb_reg[2];
            pu[0] = tb_reg[1];
            pd[0] = tb_reg[0];
            
            $display($time, " ns pad = %v y = %v a = %v oe = %v pu = %v pd = %v ", pad[0], a[0], oe[0], pu[0], pd[0], y[0]);
        end
	end
endtask

task drive();
    reg [4:0] tb_reg;
    integer i;
	begin 

        tb_reg = 5'b00000;

        for(i = 0; i < 32; i = i + 1) begin
            #30
            tb_reg = tb_reg + 1'b1;
            
            a[1] = tb_reg[4];
            oe[1] = tb_reg[3];
            pu[1] = tb_reg[2];
            pd[1] = tb_reg[1];
            padi = tb_reg[0];
            
             $display($time, " ns pad = %v y = %v a = %v oe = %v pu = %v pd = %v", pad[1], a[1], oe[1], pu[1], pd[1], y[1]);

        end
	end
endtask

initial begin
    $dumpfile("hello_tb.vcd");
    $dumpvars(0, GPIO_PAD_tb);
    $display("Module %m") ;
        a = 0;
        oe = 0;
        pu = 0;
        pd = 0;
        padi = 0;
     $display("no drive:") ;
        no_drive();
    #100;
    $display("with drive:") ;
        drive();

    $display("Test complet");
end

endmodule