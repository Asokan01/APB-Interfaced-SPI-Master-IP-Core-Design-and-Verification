class apb_monitor extends uvm_monitor;
	
	`uvm_component_utils(apb_monitor) // Factory Registration

	virtual apb_if.APB_MON_MP vaif; //Virtual interface for connecting
	apb_agent_config apb_agt_cfg;
	uvm_analysis_port #(apb_xtn) ap;

	//Methods
	extern function new(string name = "apb_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern function void report_phase(uvm_phase phase);
endclass


//----------------------Constructor new--------------------------
function apb_monitor::new(string name = "apb_monitor", uvm_component parent);
	super.new(name, parent);
	ap = new("ap", this);
endfunction

//---------------------Build Phase-------------------------------
function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config class so that we can connect the monitor to dut via virtual interface
	if(!uvm_config_db #(apb_agent_config)::get(get_parent(),"","apb_agent_config",apb_agt_cfg))
		`uvm_fatal("APB_MONITOR","Couldn't get agent config from uvm_config_db... Did you set it right???")
endfunction

//---------------------Connect Phase-------------------------------
function void apb_monitor::connect_phase(uvm_phase phase);
	vaif = apb_agt_cfg.aif;
endfunction

//--------------------Run_Phase()----------------------------------------------
task apb_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
	end
endtask

//-----------------------Collect_Data()----------------------------------------
task apb_monitor::collect_data();
	apb_xtn xtn;
	xtn = apb_xtn::type_id::create("xtn");

	//Wait for both Pready and Penable to be high
	wait(vaif.apb_mon_cb.Penable && vaif.apb_mon_cb.Pready)
	`uvm_info(get_type_name(), "PENABLE And PREADY is high...", UVM_LOW)
	xtn.Presetn = vaif.apb_mon_cb.Presetn;
	xtn.Paddr = vaif.apb_mon_cb.Paddr;
	xtn.Pwrite = vaif.apb_mon_cb.Pwrite;
	xtn.Psel = vaif.apb_mon_cb.Psel;
	xtn.Penable = vaif.apb_mon_cb.Penable;

	if(vaif.apb_mon_cb.Pwrite)
		xtn.Pwdata = vaif.apb_mon_cb.Pwdata;
	else
		xtn.Prdata = vaif.apb_mon_cb.Prdata;
	
	xtn.Pready = vaif.apb_mon_cb.Pready;
	xtn.Pslverr = vaif.apb_mon_cb.Pslverr;

	ap.write(xtn);
	apb_agt_cfg.apb_mon_rcvd_xtn_cnt++;
	@(vaif.apb_mon_cb);
	`uvm_info(get_type_name(), "Sampling is done...", UVM_LOW)
endtask

//------------------------------Report_Phase()------------------------------------
function void apb_monitor::report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("APB_MONITOR : The Transactions recieved from DUT to APB MONITOR is : %0d", apb_agt_cfg.apb_mon_rcvd_xtn_cnt), UVM_LOW)
endfunction

