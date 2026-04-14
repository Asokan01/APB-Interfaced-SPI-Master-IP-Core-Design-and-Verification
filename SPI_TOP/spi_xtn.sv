class spi_xtn extends uvm_sequence_item;
	
	`uvm_object_utils(spi_xtn) //Factory Registration

	//Class Properties
	bit ss;
	bit sclk;
	rand bit [7:0] miso;
	bit [7:0] mosi;
	bit spi_int_req;

	//Methods
	extern function new(string name = "spi_xtn");
	extern function void do_print(uvm_printer printer);
endclass

//---------------------Constructor new---------------------------
function spi_xtn::new(string name = "spi_xtn");
	super.new(name);
endfunction

//--------------------Do_Print()--------------------------------
function void spi_xtn::do_print(uvm_printer printer);
	super.do_print(printer);
	//Print the variables
			//  "string"		"bitstream_value"	"size"		"radix for printing"
	printer.print_field("SS", this.ss, 1, UVM_HEX);	
	printer.print_field("MISO", this.miso, 8, UVM_HEX);
	printer.print_field("MOSI", this.mosi, 8, UVM_HEX);
	printer.print_field("SPI_INT_REQ", this.spi_int_req, 1, UVM_DEC);
endfunction
	
