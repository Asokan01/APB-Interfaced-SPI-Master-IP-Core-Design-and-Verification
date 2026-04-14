class apb_xtn extends uvm_sequence_item;
	
	`uvm_object_utils(apb_xtn) //Factory Registration

	//Class properties
	bit Pclk;
	rand bit Presetn;
	bit Psel;
	bit Penable;
	rand bit Pwrite;
	rand bit [2:0] Paddr;
	rand bit [7:0] Pwdata;
	bit [7:0] Prdata;
	bit Pready;
	bit Pslverr;

	//Constraints
	constraint valid_addr{if(!Pwrite)
				Paddr inside {[0:3],5};
			      else
				Paddr inside {[0:2],5};
			     }

	constraint reset{Presetn dist {0 := 1, 1 := 99};}

	//Methods
	extern function new(string name = "apb_xtn");
	extern function void do_print(uvm_printer printer);
	extern function void post_randomize();
endclass

//---------------------Constructor new-------------------------
function apb_xtn::new(string name = "apb_xtn");
	super.new(name);
endfunction

//---------------------Do_Print---------------------------------
function void apb_xtn::do_print(uvm_printer printer);
	super.do_print(printer);
		//Print the variables
			//  "string"		"bitstream_value"	"size"		"radix for printing"
	printer.print_field("PRESETn", this.Presetn, 1, UVM_HEX);	
	printer.print_field("PENABLE", this.Penable, 1, UVM_DEC);
	printer.print_field("PADDR", this.Paddr, 3, UVM_HEX);
	printer.print_field("PWRITE", this.Pwrite, 1, UVM_DEC);
	printer.print_field("PWDATA", this.Pwdata, 8, UVM_HEX);
	printer.print_field("PRDATA", this.Prdata, 8, UVM_HEX);
	printer.print_field("PSEL", this.Psel, 1, UVM_HEX);
	printer.print_field("PREADY", this.Pready, 1, UVM_HEX);
	printer.print_field("PSLVERR", this.Pslverr, 1, UVM_HEX);
endfunction

//--------------------Post_Randomize()---------------------------
function void apb_xtn::post_randomize();
	//Masks to define which bits can be updated
	bit [7:0] cr1_mask = 8'b1111_1111;
	bit [7:0] cr2_mask = 8'b0001_1011;
	bit [7:0] br_mask = 8'b0111_0111;
	bit [7:0] sr_mask = 8'b0000_0000;
	bit [7:0] dr_mask = 8'b1111_1111;

	/* For a Write Transaction =>>> Depending on PADDR, the randomized data will be anded with masks to produce a meaningful data */
	if(Pwrite) begin
		case(Paddr)
			000 : Pwdata = cr1_mask & Pwdata;
			001 : Pwdata = cr2_mask & Pwdata;
			010 : Pwdata = br_mask & Pwdata;
			011 : Pwdata = sr_mask & Pwdata;
			101 : Pwdata = dr_mask & Pwdata;
			default : Pwdata = dr_mask & Pwdata;
		endcase
	end
endfunction
