class spi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(spi_scoreboard) //Factory Registration

	//Class Properties
	uvm_tlm_analysis_fifo #(apb_xtn) fifo_apb[];
	uvm_tlm_analysis_fifo #(spi_xtn) fifo_spi[];

	env_config e_cfg;
	
	uvm_status_e status;
	bit[7:0] data;

	spi_reg_block spi_reg_blk;

	//Handles of transaction class for APB host and SPI slave coverage
	apb_xtn apb_cov_data;
	spi_xtn spi_cov_data;

	apb_xtn a_xtn;
	spi_xtn s_xtn;

	int data_verified_cnt;
	
	bit reset_case;
	bit[1:0] low_pwr_case;
	bit[7:0] cntrl_reg1, cntrl_reg2, baud_reg, status_reg, data_reg;

	//Cover Groups for APB Host
	covergroup apb_cover_group;
		option.per_instance = 1;
		
		Reset	:	coverpoint apb_cov_data.Presetn{bins rst = {0,1};}
		Addr	:	coverpoint apb_cov_data.Paddr{bins addr[] = {0,1,2,3,5};}
		Selx	:	coverpoint apb_cov_data.Psel{bins sel = {0,1};}
		Enable	:	coverpoint apb_cov_data.Penable{bins enb = {0,1};}
		Write	:	coverpoint apb_cov_data.Pwrite{bins wrt[] = {0,1};}
		Ready	:	coverpoint apb_cov_data.Pready{bins rdy = {0,1};}
		SlvErr	:	coverpoint apb_cov_data.Pslverr{bins err = {0,1};}
		Wdata	:	coverpoint apb_cov_data.Pwdata{bins wdata_low = {[8'h00:8'h0f]};
								bins wdata_high = {[8'h1f:8'hff]};}
		Rdata	:	coverpoint apb_cov_data.Prdata{bins rdata_low = {[8'h00:8'h0f]};
								bins rdata_high = {[8'h1f:8'hff]};}

		//Crosses
		Selx_Enable : cross Selx, Enable;
		Selx_Enable_Ready : cross Selx, Enable, Ready;
	endgroup

	//Cover Group for SPI
	covergroup spi_cover_group;
		option.per_instance = 1;
		
		slave_select	:	coverpoint spi_cov_data.ss{bins ss = {0,1};}
		miso	:	coverpoint spi_cov_data.miso{bins miso_low = {[8'h00:8'h0f]};
								bins miso_high = {[8'h10:8'hff]};}
		mosi	:	coverpoint spi_cov_data.mosi{bins mosi_low = {[8'h00:8'h0f]};
								bins mosi_high = {[8'h10:8'hff]};}
		spi_intr_req	:	coverpoint spi_cov_data.spi_int_req{bins intr[] = {0,1};}
	endgroup

	//Methods
	extern function new(string name = "spi_scoreboard", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task compare_data(apb_xtn a_xtn);
	extern task compare_data1(apb_xtn a_xtn);
	//extern function void report_phase(uvm_phase phase);
endclass


//------------------------Constructor new--------------------------------
function spi_scoreboard::new(string name = "spi_scoreboard", uvm_component parent);
	super.new(name, parent);
	apb_cov_data = new();
	spi_cov_data = new();

	apb_cover_group = new();
	spi_cover_group = new();
endfunction

//--------------------------Build_Phase()-------------------------------
function void spi_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg))
		`uvm_fatal(get_type_name(), "Cannot get e_cfg from uvm_config_db. Did you set it right???")

	fifo_apb = new[e_cfg.no_of_src_agt];
	fifo_spi = new[e_cfg.no_of_dest_agt];
	
	foreach(fifo_apb[i])
		fifo_apb[i] = new($sformatf("fifo_apb[%0d]", i), this);

	foreach(fifo_spi[i])
		fifo_spi[i] = new($sformatf("fifo_spi[%0d]", i), this);
endfunction

//--------------------------Connect_Phase()---------------------------------
function void spi_scoreboard::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	spi_reg_blk = e_cfg.spi_reg_blk;
endfunction

//-------------------------Run_Phase()------------------------------------
task spi_scoreboard::run_phase(uvm_phase phase);
	fork begin
		forever begin
			fifo_apb[0].get(a_xtn);
			apb_cov_data = a_xtn;
			apb_cover_group.sample();
			compare_data1(a_xtn);
		end
	end
	begin
		forever begin
			fifo_spi[0].get(s_xtn);
			spi_cov_data = s_xtn;
			spi_cover_group.sample();
			`uvm_info(get_type_name(), $sformatf("Scoreboard : \n SPI_XTN = \n%s", s_xtn.sprint()), UVM_LOW)
			compare_data(a_xtn);
		end
	end
	join
endtask

//---------------------------Compare_Data-----------------------------
task spi_scoreboard::compare_data(apb_xtn a_xtn);
	//Logic to compare the MOSI data and PWData (Data written into SPI Data Register
	wait(s_xtn!=null);
	wait(a_xtn!=null);

	if(a_xtn.Pwrite && (a_xtn.Paddr == 3'b101)) begin
		$display("*********************SCOREBOARD REPORT************************");

		if(a_xtn.Pwdata == s_xtn.mosi)
			`uvm_info(get_type_name(), "MOSI DATA COMPARISION SUCCESSFUL", UVM_LOW)
		else
			`uvm_error(get_type_name(), "MOSI DATA COMPARISION UNSUCCESSFUL")

		`uvm_info(get_type_name(), $sformatf("Scoreboard : \n APB_XTN = \n%s, \n SPI_XTN = \n%s", a_xtn.sprint(), s_xtn.sprint()), UVM_LOW)
		$display("**************************************************************");
	end
endtask

//----------------------------Compare_Data1-------------------------------------
task spi_scoreboard::compare_data1(apb_xtn a_xtn);
	/* Comparison logic to verify
		1. MISO DATA AND PRDATA
		2. REGISTERS IN RESET CONDITION
		3. LOW POWER MODE */
	uvm_config_db#(bit)::get(this, "", "bit", reset_case); //Set in test
	uvm_config_db#(bit[1:0])::get(this, "", "bit[1:0]", low_pwr_case);

	/* When reset was applied we will read the all register with backdoor method and compare with their default values */
	if(reset_case) begin
		this.spi_reg_blk.cntrl_reg1.read(status, cntrl_reg1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));
		this.spi_reg_blk.cntrl_reg2.read(status, cntrl_reg2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));
		this.spi_reg_blk.baud_reg.read(status, baud_reg, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));
		this.spi_reg_blk.status_reg.read(status, status_reg, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));
		this.spi_reg_blk.data_reg.read(status, data_reg, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));

	$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@SCOREBOARD REPORT@@@@@@@@@@@@@@@@@@@@@@@@@@@");
	if((cntrl_reg1==8'b0000_0100) && (cntrl_reg2 == 8'b0000_0000) && (baud_reg == 8'b0000_0000) && (status_reg == 8'b0010_0000) && (data_reg == 8'b0000_0000))
		`uvm_info(get_type_name(), "RESET COMPARISON IS SUCCESSFUL", UVM_LOW)
	else
		`uvm_error(get_type_name(), "RESET COMPARISION UNSUCCESSFUL")

	`uvm_info(get_type_name(), $sformatf("The Reset Values of Registers are -- Control Reg1 = %0b, Control Reg2 = %0b, Baud Reg = %0b, Status Reg = %0b, Data Reg = %0b", cntrl_reg1, cntrl_reg2, baud_reg, status_reg, data_reg), UVM_LOW)

	data_verified_cnt++;
	$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
	end

	//Comparision logic for low power mode transactions
	if(low_pwr_case == 2'b01) begin
		if((!a_xtn.Pwrite) && (a_xtn.Paddr == 3'b101)) begin
			this.spi_reg_blk.data_reg.read(status, data_reg, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));
			$display("######################################SCOREBOARD REPORT#####################################################");
			
			if(a_xtn.Prdata == data_reg)
				`uvm_info(get_type_name(), "LOW POWER DATA COMPARISON IS SUCCESSFUL", UVM_LOW)
			else
				`uvm_error(get_type_name(), "LOW POWER DATA COMPARISON IS UNSUCCESSFUL")
	
			$display("###########################################################################################");
		end
	end
	else begin
		wait(s_xtn!=null);
		if((!a_xtn.Pwrite) && (a_xtn.Paddr == 3'b101)) begin
			$display("#######################################SCOREBOARD REPORT##################################################");
			if(a_xtn.Prdata == s_xtn.miso)
				`uvm_info(get_type_name(), $sformatf("MISO DATA COMPARISON SUCCESSFUL :: Expected = %0h, Actual(MISO) = %0h",
                a_xtn.Prdata, s_xtn.miso), UVM_LOW)
			else
				`uvm_error(get_type_name(), $sformatf("MISO DATA COMPARISON FAILED :: Expected = %0h, Actual(MISO) = %0h",
                a_xtn.Prdata, s_xtn.miso))

			if(s_xtn.spi_int_req) begin
				this.spi_reg_blk.status_reg.read(status, status_reg, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map));
					`uvm_info(get_type_name(), $sformatf("The Value if Status Register is %0h, The reason for Interrupt Request is SPIF = %0b, SPTEF = %0b, and MODF = %0b", status_reg, status_reg[7], status_reg[5], status_reg[4]), UVM_LOW)
			end
			`uvm_info(get_type_name(), $sformatf("Scoreboard : \n APB_XTN = \n%s, \n SPI_XTN = \n%s", a_xtn.sprint(), s_xtn.sprint()), UVM_LOW)
		end
	end
endtask
