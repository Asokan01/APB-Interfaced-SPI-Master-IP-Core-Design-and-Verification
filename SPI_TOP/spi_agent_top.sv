class spi_agent_top extends uvm_env;
	
	`uvm_component_utils(spi_agent_top) //Factory Registration

	//Declare Write Agent handle
	spi_agent spi_agnth[];

	//Declare a handle for env_config
	env_config e_cfg;

	//Standard Methods
	extern function new(string name = "spi_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass


//---------------------------------Constructor "new"-------------------------------------
function spi_agent_top::new(string name = "spi_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction


//---------------------------------Build Phase-------------------------------------
function void spi_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Get the env_config from uvm_config_db
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("SPI_AGENT","Could not get ENV_CONFIG.... Did u set it???")

	spi_agnth = new[e_cfg.no_of_dest_agt];

	foreach(spi_agnth[i]) begin
		spi_agnth[i] = spi_agent::type_id::create($sformatf("spi_agnth[%0d]",i),this);
		uvm_config_db #(spi_config)::set(this,$sformatf("spi_agnth[%0d]",i),"spi_config",e_cfg.spi_cfg[i]);
	end
endfunction

