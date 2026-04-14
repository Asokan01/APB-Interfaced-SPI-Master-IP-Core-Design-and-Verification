class apb_agent_top extends uvm_env;
	`uvm_component_utils(apb_agent_top) //Factory Registration

	//Declare Write Agent handle
	apb_agent apb_agnth[];

	//Declare a handle for env_config
	env_config e_cfg;

	//Standard Methods
	extern function new(string name = "apb_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass


//---------------------------------Constructor "new"-------------------------------------
function apb_agent_top::new(string name = "apb_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction


//---------------------------------Build Phase-------------------------------------
function void apb_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Get the env_config from uvm_config_db
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("SOURCE_AGENT","Could not get ENV_CONFIG.... Did u set it???")

	apb_agnth = new[e_cfg.no_of_src_agt];

	foreach(apb_agnth[i]) begin
		apb_agnth[i] = apb_agent::type_id::create($sformatf("apb_agnth[%0d]",i),this);
		uvm_config_db #(apb_agent_config)::set(this,$sformatf("apb_agnth[%0d]",i),"apb_agent_config",e_cfg.apb_agt_cfg[i]);
	end
endfunction
