class spi_agent extends uvm_agent;
	`uvm_component_utils(spi_agent) //Factory Registration

	//Declare the handles for driver, monitor and sequencer
	spi_driver spi_drvh;
	spi_monitor spi_monh;
	spi_sequencer spi_seqrh;

	//Declare the handle for apb_agent_config
	spi_config spi_cfg;

	//Standard Methods
	extern function new(string name = "spi_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//------------------------------Constructor "new"---------------------------------
function spi_agent::new(string name = "spi_agent", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------------Build Phase---------------------------------
function void spi_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config from uvm_config_db
	if(!uvm_config_db #(spi_config)::get(this,"","spi_config",spi_cfg))
		`uvm_fatal("SPI AGENT","Could not get AGENT_CONFIG.... Did u set it???")

	//Create object for monitor
	spi_monh = spi_monitor::type_id::create("spi_monh",this);

	//Create objects for driver and sequencer if is_active is UVM_ACTIVE
	if(spi_cfg.is_active == UVM_ACTIVE) begin
		spi_drvh = spi_driver::type_id::create("spi_drvh",this);
		spi_seqrh = spi_sequencer::type_id::create("spi_seqrh",this);
	end

endfunction


//------------------------------Connect Phase---------------------------------
function void spi_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	spi_drvh.seq_item_port.connect(spi_seqrh.seq_item_export);
endfunction
