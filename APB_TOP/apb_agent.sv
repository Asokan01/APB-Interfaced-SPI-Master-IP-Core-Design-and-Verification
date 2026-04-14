class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent) //Factory Registration

	//Declare the handles for driver, monitor and sequencer
	apb_driver apb_drvh;
	apb_monitor apb_monh;
	apb_sequencer apb_seqrh;

	//Declare the handle for apb_agent_config
	apb_agent_config apb_agt_cfg;

	//Standard Methods
	extern function new(string name = "apb_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//------------------------------Constructor "new"---------------------------------
function apb_agent::new(string name = "apb_agent", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------------Build Phase---------------------------------
function void apb_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config from uvm_config_db
	if(!uvm_config_db #(apb_agent_config)::get(this,"","apb_agent_config",apb_agt_cfg))
		`uvm_fatal("APB AGENT","Could not get AGENT_CONFIG.... Did u set it???")

	//Create object for monitor
	apb_monh = apb_monitor::type_id::create("apb_monh",this);

	//Create objects for driver and sequencer if is_active is UVM_ACTIVE
	if(apb_agt_cfg.is_active == UVM_ACTIVE) begin
		apb_drvh = apb_driver::type_id::create("apb_drvh",this);
		apb_seqrh = apb_sequencer::type_id::create("apb_seqrh",this);
	end

endfunction


//------------------------------Connect Phase---------------------------------
function void apb_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	apb_drvh.seq_item_port.connect(apb_seqrh.seq_item_export);
endfunction
