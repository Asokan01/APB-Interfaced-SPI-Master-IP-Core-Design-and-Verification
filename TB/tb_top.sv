module tb_top;
	import uvm_pkg::*;
	import apb_spi_pkg::*;

	//clk generation
	bit clk;
	always #10 clk = ~clk;
	
	//Interface declaration
	apb_if aif(clk);
	spi_if sif(clk);

	//DUT instantiation
	top DUT(.Pclk (aif.Pclk),
        .Presetn (aif.Presetn),
        .PADDR (aif.Paddr),
        .PWRITE (aif.Pwrite),
        .PSEL (aif.Psel),
        .PENABLE (aif.Penable),
        .PWDATA (aif.Pwdata),
        .PRDATA (aif.Prdata),
        .PREADY (aif.Pready),
        .PSLVERR (aif.Pslverr),
        .miso (sif.miso),
        .mosi (sif.mosi),
        .sclk (sif.sclk),
        .ss (sif.ss),
        .spi_interrupt_request (sif.spi_int_req));

	initial begin
		//Set the virtual interfaces as strings into uvm_config_db
		uvm_config_db#(virtual apb_if)::set(null,"*","vaif",aif);
		uvm_config_db#(virtual spi_if)::set(null,"*","vsif",sif);

		//Call run_test()
		run_test("");
	end
endmodule
