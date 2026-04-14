class spi_virt_seqs extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(spi_virt_seqs)

	//Properties
	env_config e_cfg;
	spi_reg_block spi_reg_blk;
	spi_virt_seqr v_seqrh;

	apb_sequencer apb_seqrh[];
	spi_sequencer spi_seqrh[];

	rand uvm_reg_data_t data;
	uvm_status_e status;

	//Methods
	function new(string name = "spi_virt_seqs");
		super.new(name);
	endfunction

	task body();
		if(!uvm_config_db#(env_config)::get(null, get_full_name(), "env_config", e_cfg))
			`uvm_fatal(get_type_name(), "Cannot get e_cfg rom confi_db... Did you set it right??")

		apb_seqrh = new[e_cfg.no_of_src_agt];
		spi_seqrh = new[e_cfg.no_of_dest_agt];

		spi_reg_blk = e_cfg.spi_reg_blk;

		assert($cast(v_seqrh, m_sequencer))
		else
			`uvm_error(get_type_name(), "Error in cast of Virtual Sequencer")

		foreach(apb_seqrh[i])
			apb_seqrh[i] = v_seqrh.apb_seqrh[i];
		foreach(spi_seqrh[i])
			spi_seqrh[i] = v_seqrh.spi_seqrh[i];
	endtask
endclass


//--------------------------------SPI_RESET_VSEQS--------------------------------
class spi_reset_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_reset_vseqs)

	reset_seqs apb_seqh;
	
	function new(string name = "spi_reset_vseqs");
		super.new(name);
	endfunction

	task body();
		apb_seqh = reset_seqs::type_id::create("apb_seqh");
		super.body();
		apb_seqh.start(apb_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL1_CPHA1_VSEQS------------------------------
class spi_cpol1_cpha1_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol1_cpha1_vseqs)

	apb_cpol1_cpha1_seqs apb_seqh;
	spi_cpol1_cpha1_seqs spi_seqh;

	function new(string name = "spi_cpol1_cpha1_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol1_cpha1_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol1_cpha1_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass
	
//-----------------------------SPI_CPOL0_CPHA1_VSEQS------------------------------
class spi_cpol0_cpha1_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol0_cpha1_vseqs)

	apb_cpol0_cpha1_seqs apb_seqh;
	spi_cpol0_cpha1_seqs spi_seqh;

	function new(string name = "spi_cpol0_cpha1_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol0_cpha1_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol0_cpha1_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL1_CPHA0_VSEQS------------------------------
class spi_cpol1_cpha0_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol1_cpha0_vseqs)

	apb_cpol1_cpha0_seqs apb_seqh;
	spi_cpol1_cpha0_seqs spi_seqh;

	function new(string name = "spi_cpol1_cpha0_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol1_cpha0_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol1_cpha0_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL0_CPHA0_VSEQS------------------------------
class spi_cpol0_cpha0_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol0_cpha0_vseqs)

	apb_cpol0_cpha0_seqs apb_seqh;
	spi_cpol0_cpha0_seqs spi_seqh;

	function new(string name = "spi_cpol0_cpha0_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol0_cpha0_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol0_cpha0_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL1_CPHA1_LSBFE0_SEQS------------------------------
class spi_cpol1_cpha1_lsbfe0_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol1_cpha1_lsbfe0_vseqs)

	apb_cpol1_cpha1_lsbfe0_seqs apb_seqh;
	spi_cpol1_cpha1_lsbfe0_seqs spi_seqh;

	function new(string name = "spi_cpol1_cpha1_lsbfe0_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol1_cpha1_lsbfe0_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol1_cpha1_lsbfe0_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL0_CPHA1_LSBFE0_SEQS------------------------------
class spi_cpol0_cpha1_lsbfe0_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol0_cpha1_lsbfe0_vseqs)

	apb_cpol0_cpha1_lsbfe0_seqs apb_seqh;
	spi_cpol0_cpha1_lsbfe0_seqs spi_seqh;

	function new(string name = "spi_cpol0_cpha1_lsbfe0_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol0_cpha1_lsbfe0_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol0_cpha1_lsbfe0_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL1_CPHA0_LSBFE0_SEQS------------------------------
class spi_cpol1_cpha0_lsbfe0_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol1_cpha0_lsbfe0_vseqs)

	apb_cpol1_cpha0_lsbfe0_seqs apb_seqh;
	spi_cpol1_cpha0_lsbfe0_seqs spi_seqh;

	function new(string name = "spi_cpol1_cpha0_lsbfe0_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol1_cpha0_lsbfe0_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol1_cpha0_lsbfe0_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_CPOL0_CPHA0_LSBFE0_SEQS------------------------------
class spi_cpol0_cpha0_lsbfe0_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_cpol0_cpha0_lsbfe0_vseqs)

	apb_cpol0_cpha0_lsbfe0_seqs apb_seqh;
	spi_cpol0_cpha0_lsbfe0_seqs spi_seqh;

	function new(string name = "spi_cpol0_cpha0_lsbfe0_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_cpol0_cpha0_lsbfe0_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_cpol0_cpha0_lsbfe0_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_LOW_POWER_MODE_SEQS------------------------------
class spi_low_power_mode_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_low_power_mode_vseqs)

	apb_low_power_mode_seqs apb_seqh;

	function new(string name = "spi_low_power_mode_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_low_power_mode_seqs::type_id::create("apb_seqh");
		apb_seqh.start(apb_seqrh[0]);
	endtask
endclass

//-----------------------------SPI_RANDOM_MODE_SEQS------------------------------
class spi_random_mode_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_random_mode_vseqs)

	apb_random_mode_seqs apb_seqh;
	spi_random_mode_seqs spi_seqh;

	function new(string name = "spi_low_power_mode_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		apb_seqh = apb_random_mode_seqs::type_id::create("apb_seqh");
		spi_seqh = spi_random_mode_seqs::type_id::create("spi_seqh");
		
		apb_seqh.start(apb_seqrh[0]);
		spi_seqh.start(spi_seqrh[0]);
	endtask
endclass

//------------------------------SPI_Data_read_vseqs-------------------------------
class spi_data_reg_read_vseqs extends spi_virt_seqs;
	`uvm_object_utils(spi_data_reg_read_vseqs)

	apb_data_read_seqs read_seqh;
	
	function new(string name = "spi_data_reg_read_vseqs");
		super.new(name);
	endfunction

	task body();
		super.body();
		read_seqh = apb_data_read_seqs::type_id::create("read_seqh");
		read_seqh.start(apb_seqrh[0]);
	endtask
endclass
