class spi_monitor extends uvm_monitor;
	
	`uvm_component_utils(spi_monitor) // Factory Registration

	uvm_analysis_port#(spi_xtn) ap;
	virtual spi_if.SPI_MON_MP vsif; //Virtual interface for connecting
	spi_config spi_cfg;
	
	bit[7:0] cntrl;
	bit cphase;
	bit cpol;
	bit lsb;

	//Methods
	extern function new(string name = "spi_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern function void report_phase(uvm_phase phase);
endclass


//----------------------Constructor new--------------------------
function spi_monitor::new(string name = "spi_monitor", uvm_component parent);
	super.new(name, parent);
	ap = new("ap", this);
endfunction

//---------------------Build Phase-------------------------------
function void spi_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config class so that we can connect the monitor to dut via virtual interface
	if(!uvm_config_db #(spi_config)::get(get_parent(),"","spi_config",spi_cfg))
		`uvm_fatal("SPI_MONITOR","Couldn't get agent config from uvm_config_db... Did you set it right???")
endfunction

//---------------------Connect Phase-------------------------------
function void spi_monitor::connect_phase(uvm_phase phase);
	vsif = spi_cfg.sif;
endfunction

//--------------------Run Phase-------------------------------------------
task spi_monitor::run_phase(uvm_phase phase);
	forever
		collect_data();
endtask

//--------------------Collect_Data------------------------------------
task spi_monitor::collect_data();
	spi_xtn xtn;
	xtn = spi_xtn::type_id::create("xtn");

	//Getting cntrl_reg1 values for cphase, cpol, lsbfe
	if(!uvm_config_db#(bit[7:0])::get(this, "", "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get CNTRL_REG1 value from config_db.... Did you set it right in test class???")

	`uvm_info(get_type_name(), $sformatf("SPI_MONITOR : Value of CNTRL_REG1 = %0b", cntrl), UVM_LOW)

	cphase = cntrl[2];
	cpol = cntrl[3];
	lsb = cntrl[0];

	//@(vsif.spi_mon_cb)
	wait(!vsif.spi_mon_cb.ss) begin
	@(vsif.spi_mon_cb)
		if(lsb) begin
			for(int i = 0; i<=7; i++) begin
				if(((!cphase) &&(!cpol)) || (cphase && cpol)) begin
					@(posedge vsif.spi_mon_cb.sclk) begin
						xtn.miso[i] = vsif.spi_mon_cb.miso;
						xtn.mosi[i] = vsif.spi_mon_cb.mosi;
						xtn.ss = vsif.spi_mon_cb.ss;
						xtn.spi_int_req = vsif.spi_mon_cb.spi_int_req;
					end
				end
				else begin
					@(negedge vsif.spi_mon_cb.sclk) begin
                                                xtn.miso[i] = vsif.spi_mon_cb.miso;
                                                xtn.mosi[i] = vsif.spi_mon_cb.mosi;
                                                xtn.ss = vsif.spi_mon_cb.ss;
                                                xtn.spi_int_req = vsif.spi_mon_cb.spi_int_req;
					end
				end
			end
		end
		else begin
			for(int i = 7; i>=0; i--) begin
                                if(((!cphase) &&(!cpol)) || (cphase && cpol)) begin
                                        @(posedge vsif.spi_mon_cb.sclk) begin
                                                xtn.miso[i] = vsif.spi_mon_cb.miso;
                                                xtn.mosi[i] = vsif.spi_mon_cb.mosi;
                                                xtn.ss = vsif.spi_mon_cb.ss;
                                                xtn.spi_int_req = vsif.spi_mon_cb.spi_int_req;
                                        end
                                end
                                else begin
                                        @(negedge vsif.spi_mon_cb.sclk) begin
                                                xtn.miso[i] = vsif.spi_mon_cb.miso;
                                                xtn.mosi[i] = vsif.spi_mon_cb.mosi;
                                                xtn.ss = vsif.spi_mon_cb.ss;
                                                xtn.spi_int_req = vsif.spi_mon_cb.spi_int_req;
                                        end
                                end
                        end
                end
	end
	`uvm_info(get_type_name(), $sformatf("The transactions received from SPI SLAVE : \n %s", xtn.sprint()), UVM_LOW)
	ap.write(xtn);
	spi_cfg.spi_mon_rcvd_xtn_cnt++;
	@(vsif.spi_mon_cb);
endtask

//------------------------------Report Phase------------------------------------------
function void spi_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("SPI_MONITOR : The Transactions received from SPI MONITOR is : %0d", spi_cfg.spi_mon_rcvd_xtn_cnt), UVM_LOW)
endfunction
