class spi_driver extends uvm_driver#(spi_xtn);
	`uvm_component_utils(spi_driver) // Factory Registration

	//Properties
	bit [7:0] cntrl;
	bit cphase;
	bit cpol;
	bit lsb;

	virtual spi_if.SPI_DRV_MP vsif;
	spi_config spi_cfg;
	//Methods
	extern function new(string name = "spi_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(spi_xtn xtn);
	extern function void report_phase(uvm_phase phase);
endclass

//------------------------Constructor "new"---------------------------
function spi_driver::new(string name = "spi_driver", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------Build Phase()---------------------------
function void spi_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config for retrieving virtual interface
	if(!uvm_config_db#(spi_config)::get(get_parent(),"","spi_config",spi_cfg))
		`uvm_fatal("SPI_DRIVER","Couldn't get AGENT CONFIG from UVM_CONFIG_DB... Did u set it right???")
endfunction


//------------------------Connect Phase()---------------------------
function void spi_driver::connect_phase(uvm_phase phase);
	vsif = spi_cfg.sif; //Assign the agent config's virtual interface handle to driver's virtual interface handle
endfunction


//------------------------Run Phase()---------------------------
task spi_driver::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask


//------------------------send_to_dut()---------------------------
task spi_driver::send_to_dut(spi_xtn xtn);
	//get the value of control_reg1 to know the values of cphase, cpol, lsbfe
	if(!uvm_config_db#(bit[7:0])::get(this, "", "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get CNTRL_REG1 value from config_db... Did you set it right in test class???")

	`uvm_info(get_type_name(), $sformatf("SPI_DRIVER : Value of CNTRL_REG1 = %0b", cntrl), UVM_LOW)	

	cphase = cntrl[2];
	cpol = cntrl[3];
	lsb = cntrl[0];

	wait(!vsif.spi_drv_cb.ss) begin
		if(lsb) begin
			if((!cphase) && (!cpol)) begin
				vsif.spi_drv_cb.miso <= xtn.miso[0];
				for(int i = 1; i <= 7; i++) begin
					@(negedge vsif.spi_drv_cb.sclk)
					vsif.spi_drv_cb.miso <= xtn.miso[i];
				end
			end
			else if((!cphase) && (cpol)) begin
				vsif.spi_drv_cb.miso <= xtn.miso[0];
                                for(int i = 1; i <= 7; i++) begin
                                        @(posedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
                        end
			else if((cphase) && (!cpol)) begin
				for(int i = 0; i <= 7; i++) begin
                                        @(posedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
			end
			else begin
				for(int i = 0; i <= 7; i++) begin
                                        @(negedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
			end
		end
		else begin
			if((!cphase) && (!cpol)) begin
                                vsif.spi_drv_cb.miso <= xtn.miso[7];
                                for(int i = 6; i >= 0; i--) begin
                                        @(negedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
                        end
                        else if((!cphase) && (cpol)) begin
                                vsif.spi_drv_cb.miso <= xtn.miso[7];
                                for(int i = 6; i >= 0; i--) begin
                                        @(posedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
                        end
                        else if((cphase) && (!cpol)) begin
                                for(int i = 7; i >= 0; i--) begin
                                        @(posedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
                        end
                        else begin
                                for(int i = 7; i >= 0; i--) begin
                                        @(negedge vsif.spi_drv_cb.sclk)
                                        vsif.spi_drv_cb.miso <= xtn.miso[i];
                                end
                        end
		end
	end
	
	`uvm_info(get_type_name(), $sformatf("The transactions sent to dut from SPI SLAVE : \n %s", xtn.sprint()), UVM_LOW)
	spi_cfg.spi_drv_sent_xtn_cnt++;
	`uvm_info(get_type_name(), "Driving to DUT is done...", UVM_LOW)
endtask

//----------------------------------Report_Phase()-----------------------------------------
function void spi_driver::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("SPI_DRIVER : The Transactions sent from SPI Driver is : %0d", spi_cfg.spi_drv_sent_xtn_cnt), UVM_LOW)
endfunction
