class test extends uvm_test;

	`uvm_component_utils(test) //Factory Registration

	//Declare Agent and Env config handles
	apb_agent_config apb_agt_cfg[];
	spi_config spi_cfg[];
	env_config e_cfg;
	spi_reg_block spi_reg_blk;

	bit[7:0] cntrl; 

	//Declare router_env handle
	tb env;

	int no_of_wagts = 1; //Source agent
	int no_of_ragts = 1; //Destination agents

	int has_sagt = 1;
	int has_dagt = 1;
	int no_of_duts = 1;

	//Methods
	extern function new(string name = "test",uvm_component parent);
	extern function void config_apb_spi();
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass


//-------------------------------Constructor "new"--------------------------------------
function test::new(string name = "test",uvm_component parent);
	super.new(name,parent);
endfunction


//-------------------------------config_apb_spi() method--------------------------------------
function void test::config_apb_spi();
	if(has_sagt) begin
		apb_agt_cfg = new[no_of_wagts];
		foreach(apb_agt_cfg[i]) begin
			apb_agt_cfg[i] = apb_agent_config::type_id::create($sformatf("apb_agt_cfg[%d]",i));
			if(!uvm_config_db#(virtual apb_if)::get(this, "", "vaif", apb_agt_cfg[i].aif))
				`uvm_fatal("VIF_CONG AT APB","cannot get() interface from uvm_config_db, did you set it right?");
		$display("-----------------------%p",apb_agt_cfg[i]);
			apb_agt_cfg[i].is_active = UVM_ACTIVE;
				e_cfg.apb_agt_cfg[i] = apb_agt_cfg[i];
		end
	end

	
	if(has_dagt) begin
                spi_cfg = new[no_of_ragts];
                foreach(spi_cfg[i]) begin
                        spi_cfg[i] = spi_config::type_id::create($sformatf("spi_cfg[%d]",i));
                        if(!uvm_config_db#(virtual spi_if)::get(this,"", "vsif",spi_cfg[i].sif))
                                `uvm_fatal("VIF_CONG AT SPI","cannot get() interface from uvm_config_db, did you set it right?");
                $display("-----------------------%p",spi_cfg[i]);
                        spi_cfg[i].is_active = UVM_ACTIVE;
                                e_cfg.spi_cfg[i] = spi_cfg[i];
                end
        end

	e_cfg.no_of_src_agt = no_of_wagts;
	e_cfg.no_of_dest_agt = no_of_ragts;
	e_cfg.no_of_duts = no_of_duts;
endfunction


//-------------------------------build_phase() method--------------------------------------
function void test::build_phase(uvm_phase phase);
	//Create object for env config class
	e_cfg = env_config::type_id::create("e_cfg");

	spi_reg_blk = spi_reg_block :: type_id :: create("spi_reg_blk");
	spi_reg_blk.build();
	e_cfg.spi_reg_blk = this.spi_reg_blk;	

	//Check whether env_cfg contains src &dst_agt_cfgs and create objects for those classes
	if(has_sagt)
		e_cfg.apb_agt_cfg = new[no_of_wagts];

	if(has_dagt)
		e_cfg.spi_cfg = new[no_of_ragts];

	config_apb_spi(); // Call config_apb_spi() method to get the virtual interfaces for respective agent cfgs

	uvm_config_db#(env_config)::set(this,"*","env_config",e_cfg); //Setting env_cfg into uvm_config_db

	super.build_phase(phase);

	env = tb::type_id::create("env",this);

	cntrl = 8'b1111_1111;
	uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);

endfunction

//-------------------------------end_of_elaboration_phase()--------------------------------------
function void test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
endfunction


//-------------------------------RESET_TEST-------------------------------------------

class reset_test extends test;
	`uvm_component_utils(reset_test)
	
	spi_reset_vseqs rst_seqh;

	bit[7:0] cntrl;
	bit reset_tests;

	extern function new(string name = "reset_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor new------------------------------------
function reset_test::new(string name = "reset_test", uvm_component parent);
	super.new(name, parent);
endfunction

//--------------------------------Build_Phase()---------------------------------------
function void reset_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()--------------------------------------------
task reset_test::run_phase(uvm_phase phase);
	rst_seqh = spi_reset_vseqs::type_id::create("rst_seqh");
	phase.raise_objection(this);
		cntrl = 8'b1110_1111; //for slave mode SPICR1 MSTR is made as 0//spi slave
		reset_tests = 1'b1;

		uvm_config_db #(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
		uvm_config_db #(bit)::set(this, "*", "bit", reset_tests);

		rst_seqh.start(env.vseqr);
	phase.drop_objection(this);
endtask



//--------------------------------SPI_CPHA1_CPOL1_TEST------------------------------------
class spi_cpol1_cpha1_test extends test;
	`uvm_component_utils(spi_cpol1_cpha1_test)

	spi_cpol1_cpha1_vseqs cpol1_cpha1_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol1_cpha1_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol1_cpha1_test::new(string name = "spi_cpol1_cpha1_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol1_cpha1_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol1_cpha1_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b1111_1111;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol1_cpha1_seqh = spi_cpol1_cpha1_vseqs::type_id::create("cpol1_cpha1_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol1_cpha1_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_CPHA1_CPOL0_TEST------------------------------------
class spi_cpol0_cpha1_test extends test;
	`uvm_component_utils(spi_cpol0_cpha1_test)

	spi_cpol0_cpha1_vseqs cpol0_cpha1_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol0_cpha1_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol0_cpha1_test::new(string name = "spi_cpol0_cpha1_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol0_cpha1_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol0_cpha1_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b1111_0111;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol0_cpha1_seqh = spi_cpol0_cpha1_vseqs::type_id::create("cpol0_cpha1_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol0_cpha1_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_CPHA0_CPOL1_TEST------------------------------------
class spi_cpol1_cpha0_test extends test;
	`uvm_component_utils(spi_cpol1_cpha0_test)

	spi_cpol1_cpha0_vseqs cpol1_cpha0_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol1_cpha0_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol1_cpha0_test::new(string name = "spi_cpol1_cpha0_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol1_cpha0_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol1_cpha0_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b1011_1011;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol1_cpha0_seqh = spi_cpol1_cpha0_vseqs::type_id::create("cpol1_cpha0_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol1_cpha0_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask
//--------------------------------SPI_CPHA0_CPOL0_TEST------------------------------------
class spi_cpol0_cpha0_test extends test;
	`uvm_component_utils(spi_cpol0_cpha0_test)

	spi_cpol0_cpha0_vseqs cpol0_cpha0_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol0_cpha0_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol0_cpha0_test::new(string name = "spi_cpol0_cpha0_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol0_cpha0_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol0_cpha0_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b0001_0011;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol0_cpha0_seqh = spi_cpol0_cpha0_vseqs::type_id::create("cpol0_cpha0_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol0_cpha0_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_CPHA1_CPOL1_LSBFE0_TEST------------------------------------
class spi_cpol1_cpha1_lsbfe0_test extends test;
	`uvm_component_utils(spi_cpol1_cpha1_lsbfe0_test)

	spi_cpol1_cpha1_lsbfe0_vseqs cpol1_cpha1_lsbfe0_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol1_cpha1_lsbfe0_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol1_cpha1_lsbfe0_test::new(string name = "spi_cpol1_cpha1_lsbfe0_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol1_cpha1_lsbfe0_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol1_cpha1_lsbfe0_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b0101_1100;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol1_cpha1_lsbfe0_seqh = spi_cpol1_cpha1_lsbfe0_vseqs::type_id::create("cpol1_cpha1_lsbfe0_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol1_cpha1_lsbfe0_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_CPHA1_CPOL0_LSBFE0_TEST------------------------------------
class spi_cpol0_cpha1_lsbfe0_test extends test;
	`uvm_component_utils(spi_cpol0_cpha1_lsbfe0_test)

	spi_cpol0_cpha1_lsbfe0_vseqs cpol0_cpha1_lsbfe0_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol0_cpha1_lsbfe0_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol0_cpha1_lsbfe0_test::new(string name = "spi_cpol0_cpha1_lsbfe0_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol0_cpha1_lsbfe0_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol0_cpha1_lsbfe0_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b0011_0110;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol0_cpha1_lsbfe0_seqh = spi_cpol0_cpha1_lsbfe0_vseqs::type_id::create("cpol0_cpha1_lsbfe0_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol0_cpha1_lsbfe0_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask
//--------------------------------SPI_CPHA0_CPOL1_LSBFE0_TEST------------------------------------
class spi_cpol1_cpha0_lsbfe0_test extends test;
	`uvm_component_utils(spi_cpol1_cpha0_lsbfe0_test)

	spi_cpol1_cpha0_lsbfe0_vseqs cpol1_cpha0_lsbfe0_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol1_cpha0_lsbfe0_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol1_cpha0_lsbfe0_test::new(string name = "spi_cpol1_cpha0_lsbfe0_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol1_cpha0_lsbfe0_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol1_cpha0_lsbfe0_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b0101_1010;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol1_cpha0_lsbfe0_seqh = spi_cpol1_cpha0_lsbfe0_vseqs::type_id::create("cpol1_cpha0_lsbfe0_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol1_cpha0_lsbfe0_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_CPHA0_CPOL0_LSBFE0_TEST------------------------------------
class spi_cpol0_cpha0_lsbfe0_test extends test;
	`uvm_component_utils(spi_cpol0_cpha0_lsbfe0_test)

	spi_cpol0_cpha0_lsbfe0_vseqs cpol0_cpha0_lsbfe0_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_cpol0_cpha0_lsbfe0_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_cpol0_cpha0_lsbfe0_test::new(string name = "spi_cpol0_cpha0_lsbfe0_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_cpol0_cpha0_lsbfe0_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_cpol0_cpha0_lsbfe0_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b1111_0000;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				cpol0_cpha0_lsbfe0_seqh = spi_cpol0_cpha0_lsbfe0_vseqs::type_id::create("cpol0_cpha0_lsbfe0_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				cpol0_cpha0_lsbfe0_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_LOW_POWER_MODE_TEST------------------------------------
class spi_low_power_mode_test extends test;
	`uvm_component_utils(spi_low_power_mode_test)

	spi_low_power_mode_vseqs low_power_mode_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	bit [1:0] low_pwr_mode;
	
	extern function new(string name = "spi_low_power_mode_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_low_power_mode_test::new(string name = "spi_low_power_mode_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_low_power_mode_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_low_power_mode_test::run_phase(uvm_phase phase);
	repeat(15) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b0001_1101;
				low_pwr_mode = 2'b01;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				uvm_config_db#(bit[1:0])::set(this, "*", "bit[1:0]", low_pwr_mode);
				low_power_mode_seqh = spi_low_power_mode_vseqs::type_id::create("low_power_mode_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				low_power_mode_seqh.start(env.vseqr);
				#600;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask

//--------------------------------SPI_RANDOM_MODE_TEST------------------------------------
class spi_random_mode_test extends test;
	`uvm_component_utils(spi_random_mode_test)

	spi_random_mode_vseqs random_mode_seqh;
	spi_data_reg_read_vseqs read_seqh;

	bit [7:0] cntrl;
	
	extern function new(string name = "spi_random_mode_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

//--------------------------------Constructor new---------------------------------------
function spi_random_mode_test::new(string name = "spi_random_mode_test", uvm_component parent);
	super.new(name, parent);
endfunction

//-------------------------------Build_Phase()------------------------------------------
function void spi_random_mode_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

//-------------------------------Run_Phase()---------------------------------------------
task spi_random_mode_test::run_phase(uvm_phase phase);
	repeat(5) begin
		phase.raise_objection(this);
			begin
				cntrl = 8'b1111_1111;
				uvm_config_db#(bit[7:0])::set(this, "*", "bit[7:0]", cntrl);
				random_mode_seqh = spi_random_mode_vseqs::type_id::create("random_mode_seqh");
				read_seqh = spi_data_reg_read_vseqs::type_id::create("read_seqh");

				random_mode_seqh.start(env.vseqr);
				#400;
				read_seqh.start(env.vseqr);
				#100;
			end
		phase.drop_objection(this);
	end
endtask
