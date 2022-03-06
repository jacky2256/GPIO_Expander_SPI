module apb_monitor#(
                        parameter BANK_ADDR		= 	2,
						parameter DATA_WIDTH 	= 	8,
						parameter ADDR_WIDTH	=	3
                        )(
                        output		[DATA_WIDTH-1 : 0]		m_prdata,
                        output		reg						m_pready,
                        input								m_pclk,
                        input								m_presetn,
                        input		[DATA_WIDTH-1 : 0]		m_pwdata,
                        input								m_pwrite,
                        input		[BANK_ADDR-1	:	0]	m_psel,
                        input								m_penable,
                        input		[ADDR_WIDTH-1 : 0]		m_paddr

                        );

wire en_pready;
initial begin
    m_pready = 1'b0;
        $display("Module %m");
        $monitor($time, "\n pwrite=%h psel=%h paddr=%h pwdata=%h prdata=%h penable=%h pready=%h \n", m_pwrite, m_psel, m_paddr, m_pwdata, m_prdata, m_penable, m_pready);
end

always @(*) begin
    if(m_penable) begin
        m_pready = 1'b1;
        #40
        m_pready = 1'b0;  
    end 
end 

assign m_prdata = (m_penable & !m_pwrite)? 8'hf9 : 'h0;

//assign en_pready = m_psel & m_penable;

endmodule
