class apb_driver extends uvm_driver#(apb_xtn);
	`uvm_component_utils(apb_driver) // Factory Registration

	virtual apb_if.APB_DRV_MP vaif;
	apb_agent_config apb_agt_cfg;
	//Methods
	extern function new(string name = "apb_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(apb_xtn xtn);
	extern task reset_dut();
	extern function void report_phase(uvm_phase phase);
endclass

//------------------------Constructor "new"---------------------------
function apb_driver::new(string name = "apb_driver", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------Build Phase()---------------------------
function void apb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config for retrieving virtual interface
	if(!uvm_config_db#(apb_agent_config)::get(get_parent(),"","apb_agent_config",apb_agt_cfg))
		`uvm_fatal("APB_DRIVER","Couldn't get AGENT CONFIG from UVM_CONFIG_DB... Did u set it right???")
endfunction


//------------------------Connect Phase()---------------------------
function void apb_driver::connect_phase(uvm_phase phase);
	vaif = apb_agt_cfg.aif; //Assign the agent config's virtual interface handle to driver's virtual interface handle
endfunction


//------------------------Run Phase()---------------------------
task apb_driver::run_phase(uvm_phase phase);
	reset_dut();
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask


//------------------------send_to_dut()---------------------------
task apb_driver::send_to_dut(apb_xtn xtn);
	
	@(vaif.apb_drv_cb);

	vaif.apb_drv_cb.Presetn <= 1'b1;
	vaif.apb_drv_cb.Paddr <= xtn.Paddr;
	vaif.apb_drv_cb.Pwrite <= xtn.Pwrite;
	vaif.apb_drv_cb.Psel <= 1'b1;
	vaif.apb_drv_cb.Penable <= 1'b0;

	if(xtn.Pwrite)
		vaif.apb_drv_cb.Pwdata <= xtn.Pwdata;


	@(vaif.apb_drv_cb);
	vaif.apb_drv_cb.Penable <= 1'b1;
	`uvm_info(get_type_name(), "Waiting for PREADY...", UVM_LOW)
	wait(vaif.apb_drv_cb.Pready)
	`uvm_info(get_type_name(), "PREADY is high...", UVM_LOW)
	if(xtn.Pwrite == 1'b0)
		xtn.Prdata = vaif.apb_drv_cb.Prdata;
	`uvm_info(get_type_name(), $sformatf("The transaction sent to the DUT is \n %s", xtn.sprint()), UVM_LOW)
	apb_agt_cfg.apb_drv_sent_xtn_cnt++;

	vaif.apb_drv_cb.Psel <= 1'b0;
	vaif.apb_drv_cb.Penable <= 1'b0;
	
	`uvm_info(get_type_name(), "Driving to DUT is done...", UVM_LOW)
endtask

//-----------------------reset_dut()----------------------------------
task apb_driver::reset_dut();
	//Reset Logic
	@(vaif.apb_drv_cb);
	vaif.apb_drv_cb.Presetn <= 1'b0;

	repeat(3)
	@(vaif.apb_drv_cb);
	vaif.apb_drv_cb.Presetn <= 1'b1;
endtask

//-----------------------report_phase()-----------------------------------
function void apb_driver::report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("APB_DRIVER : The Transactions sent from APB Driver is : %0d", apb_agt_cfg.apb_drv_sent_xtn_cnt), UVM_LOW)
endfunction
	
