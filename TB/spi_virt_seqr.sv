class spi_virt_seqr extends uvm_sequencer#(uvm_sequence_item);
	`uvm_component_utils(spi_virt_seqr)

	apb_sequencer apb_seqrh[];
	spi_sequencer spi_seqrh[];

	env_config e_cfg;

	function new(string name = "spi_virt_seqr", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(env_config)::get(this, "*", "env_config", e_cfg))
			`uvm_fatal(get_type_name(), "Cannot get the env_cfg from config_db... Did you set it right???")

		super.build_phase(phase);

		apb_seqrh = new[e_cfg.no_of_src_agt];
		spi_seqrh = new[e_cfg.no_of_dest_agt];
	endfunction
endclass
