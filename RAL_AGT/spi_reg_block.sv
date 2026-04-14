class spi_reg_block extends uvm_reg_block;

	`uvm_object_utils(spi_reg_block) //Factory Registration

	uvm_reg_map spi_reg_map;


	rand spi_reg_file_cr1 cntrl_reg1;
	rand spi_reg_file_cr2 cntrl_reg2;
	rand spi_reg_file_br baud_reg;
	rand spi_reg_file_sr status_reg;
	rand spi_reg_file_dr data_reg;


	function new(string name = "spi_reg_block");
		super.new(name, build_coverage(UVM_CVR_ALL));
	endfunction

	function void build();
		//Create instance of each reg class
		cntrl_reg1 = spi_reg_file_cr1 :: type_id :: create("cntrl_reg1");
		cntrl_reg2 = spi_reg_file_cr2 :: type_id :: create("cntrl_reg2");
		baud_reg = spi_reg_file_br :: type_id :: create("baud_reg");
		status_reg = spi_reg_file_sr :: type_id :: create("status_reg");
		data_reg = spi_reg_file_dr :: type_id :: create("data_reg1");

		//Configures each registers with its parent clock
		cntrl_reg1.configure(this, null, ""); //this - parent register block (here it is spi_reg_block)
		cntrl_reg2.configure(this, null, ""); //null - skips setting a static hdl path (used in backdoor access)
		baud_reg.configure(this, null, ""); // "" - sets the default name of the register instance (useful in backdoor path building or printing)
		status_reg.configure(this, null, "");
		data_reg.configure(this, null, "");

		//Call the build() method of each reg class to create and configure reg field items
		cntrl_reg1.build();
		cntrl_reg2.build();
		baud_reg.build();
		status_reg.build();
		data_reg.build();

		//Bind register fields to RTL paths for backdoor access
		add_hdl_path("tb_top.DUT", "RTL"); //It tells the register block (via uvm_reg_block) where in the hierarchy the DUT's registers are located.
		//"tb_top.DUT" is the base path under which all the registers live. "rtl" is just used to indicate that the path corresponds to the RTL view
		cntrl_reg1.add_hdl_path_slice("apb_if.SPI_CR_1", 0, 8); //maps a register field to a specific slice of an HDL path... Syntax: add_hdl_path_slice(<SIGNAL_PATH>, <LSB_POS>, <NUM_BITS>);
		cntrl_reg2.add_hdl_path_slice("apb_if.SPI_CR_2", 0, 8);
		baud_reg.add_hdl_path_slice("apb_if.SPI_BR", 0, 8);
		status_reg.add_hdl_path_slice("apb_if.SPI_SR", 0, 8);
		data_reg.add_hdl_path_slice("apb_if.SPI_DR", 0, 8);

		spi_reg_map = create_map("spi_reg_map", 'h0, 1, UVM_LITTLE_ENDIAN, 0); // "spi_reg_map" - Name of the register map, //'h0 - Base address of the map is 0x0 //1 - Addressing is byte_wise (each address steps by 1 byte) //0 - normal/default behaviour

		spi_reg_map.add_reg(cntrl_reg1, 8'h0, "RW");
		spi_reg_map.add_reg(cntrl_reg2, 8'h1, "RW");
		spi_reg_map.add_reg(baud_reg, 8'h2, "RW");
		spi_reg_map.add_reg(status_reg, 8'h3, "RO");
		spi_reg_map.add_reg(data_reg, 8'h5, "RW");
	
		lock_model();
	endfunction
endclass
		
