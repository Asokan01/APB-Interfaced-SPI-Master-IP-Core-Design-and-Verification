class apb_agent_config extends uvm_object;

	`uvm_object_utils(apb_agent_config) //Factory registration

	//Virtual interface declaration
	virtual apb_if aif;

	uvm_active_passive_enum is_active;

	int apb_drv_sent_xtn_cnt;
	int apb_mon_rcvd_xtn_cnt;
	//Methods
	extern function new(string name = "apb_agent_config");
endclass

//-------------------Constructor new--------------------------
function apb_agent_config::new(string name = "apb_agent_config");
	super.new(name);
endfunction
