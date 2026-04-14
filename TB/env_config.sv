class env_config extends uvm_object;

	`uvm_object_utils(env_config) //Factory Registration

	apb_agent_config apb_agt_cfg[];
	spi_config spi_cfg[];
	spi_reg_block spi_reg_blk;

	int no_of_src_agt, no_of_dest_agt, no_of_duts;
	bit has_virtual_sequencer = 1;
	bit has_scoreboard  = 1;

	//Methods
	extern function new(string name = "env_config");
endclass

//-------------------Constructor new-------------------------
function env_config::new(string name = "env_config");
	super.new(name);
endfunction
