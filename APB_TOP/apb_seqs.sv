class apb_seqs extends uvm_sequence#(apb_xtn);
	
	`uvm_object_utils(apb_seqs) //Factory Registration

	env_config e_cfg;
	spi_reg_block spi_reg_blk;
	
	uvm_status_e status;
	logic [7:0] data1, data2, data3, data4, data5;

	//Methods
	extern function new(string name = "apb_seqs");
	extern task body();
endclass

//--------------------Constructor new---------------------------
function apb_seqs::new(string name = "apb_seqs");
	super.new(name);
endfunction

//--------------------Body()------------------------------------
task apb_seqs::body();
	if(!uvm_config_db #(env_config)::get(null, get_full_name(), "env_config", e_cfg))
		`uvm_fatal(get_type_name(), "Cannot get ENV_CONFIG from config_db... Did you set it right???")

	this.spi_reg_blk = e_cfg.spi_reg_blk;
endtask


//---------------------------------Reset Seqs----------------------------------------
class reset_seqs extends apb_seqs;
	`uvm_object_utils(reset_seqs)

	bit [7:0] cntrl;
	
	//Methods
	extern function new(string name = "reset_seqs");
	extern task body();
endclass

//--------------------COnstructor new-------------------------------
function reset_seqs::new(string name = "reset_seqs");
	super.new(name);
endfunction

//-------------------Body()---------------------------------
task reset_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Could not get cntrl from config_db... Did you set it right in test class???")
	repeat(1) begin
		req = apb_xtn::type_id::create("req");

		start_item(req);
		assert (req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr == 3'b000;}) //CR1
		finish_item(req);

		start_item(req);
		assert (req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr == 3'b001;}) //CR2
		finish_item(req);

		start_item(req);
		assert (req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr == 3'b010;}) //BR
		finish_item(req);

		start_item(req);
		assert (req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr == 3'b011;}) //SR
		finish_item(req);

		start_item(req);
		assert (req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr == 3'b101;}) //DR
		finish_item(req);
	end
endtask
	
//--------------------------------------apb_cpol1_cpha1_seqs---------------------------
class apb_cpol1_cpha1_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol1_cpha1_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol1_cpha1_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol1_cpha1_seqs::new(string name = "apb_cpol1_cpha1_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol1_cpha1_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 1, CPHA = 1, lsbfe = 1(MSB first)
		data2 = 8'b0001_1000;//CR2 - modefault and bidirectional is enabled
		data3 = 8'b0001_0001;//BR - SPPR and SPR values 11 each with 12.5MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//-----------------------------------APB_CPOL0_CPHA1_SEQS---------------------------------------------------------
class apb_cpol0_cpha1_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol0_cpha1_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol0_cpha1_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol0_cpha1_seqs::new(string name = "apb_cpol0_cpha1_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol0_cpha1_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 0, CPHA = 1, lsbfe = 1(MSB first)
		data2 = 8'b0001_1001;//CR2 - modefault and bidirectional is enabled
		data3 = 8'b0000_0001;//BR - SPPR and SPR values 01 each with 6.25MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//--------------------------------------apb_cpol1_cpha0_seqs---------------------------
class apb_cpol1_cpha0_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol1_cpha0_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol1_cpha0_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol1_cpha0_seqs::new(string name = "apb_cpol1_cpha0_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol1_cpha0_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 1, CPHA = 0, lsbfe = 1(MSB first)
		data2 = 8'b0000_1001;//CR2 - modefault disabled and bidirectional is enabled
		data3 = 8'b0010_0000;//BR - SPPR and SPR values 20 each with 4.16667MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//--------------------------------------apb_cpol0_cpha0_seqs---------------------------
class apb_cpol0_cpha0_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol0_cpha0_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol0_cpha0_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol0_cpha0_seqs::new(string name = "apb_cpol0_cpha0_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol0_cpha0_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 0, CPHA = 0, lsbfe = 1(MSB first)
		data2 = 8'b0000_0001;//CR2 - modefault and bidirectional is disabled
		data3 = 8'b0110_0000;//BR - SPPR and SPR values 60 each with 1.78571MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//--------------------------------------apb_cpol1_cpha1_lsbfe0_seqs---------------------------
class apb_cpol1_cpha1_lsbfe0_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol1_cpha1_lsbfe0_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol1_cpha1_lsbfe0_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol1_cpha1_lsbfe0_seqs::new(string name = "apb_cpol1_cpha1_lsbfe0_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol1_cpha1_lsbfe0_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 1, CPHA = 1, lsbfe = 0(LSB first)
		data2 = 8'b0001_1011;//CR2 - modefault and bidirectional is enabled
		data3 = 8'b0001_0010;//BR - SPPR and SPR values 12 each with 1.5625MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//--------------------------------------apb_cpol0_cpha1_lsbfe0_seqs---------------------------
class apb_cpol0_cpha1_lsbfe0_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol0_cpha1_lsbfe0_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol0_cpha1_lsbfe0_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol0_cpha1_lsbfe0_seqs::new(string name = "apb_cpol0_cpha1_lsbfe0_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol0_cpha1_lsbfe0_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 0, CPHA = 1, lsbfe = 0(LSB first)
		data2 = 8'b0001_1001;//CR2 - modefault and bidirectional is enabled
		data3 = 8'b0100_0000;//BR - SPPR and SPR values 40 each with 2.5MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//--------------------------------------apb_cpol1_cpha0_lsbfe0_seqs---------------------------
class apb_cpol1_cpha0_lsbfe0_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol1_cpha0_lsbfe0_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol1_cpha0_lsbfe0_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol1_cpha0_lsbfe0_seqs::new(string name = "apb_cpol1_cpha0_lsbfe0_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol1_cpha0_lsbfe0_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 1, CPHA = 0, lsbfe = 0(LSB first)
		data2 = 8'b0001_1001;//CR2 - modefault and bidirectional is enabled
		data3 = 8'b0100_0001;//BR - SPPR and SPR values 41 each with 1.25MHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101; Pwdata == 8'h1B;})
		finish_item(req);
	end
endtask

//--------------------------------------apb_cpol0_cpha0_lsbfe0_seqs---------------------------
class apb_cpol0_cpha0_lsbfe0_seqs extends apb_seqs;
	`uvm_object_utils(apb_cpol0_cpha0_lsbfe0_seqs)

	bit [7:0] cntrl;

	//Methods
	extern function new(string name = "apb_cpol0_cpha0_lsbfe0_seqs");
	extern task body();
endclass

//-------------------------------------Constructor new-----------------------------------
function apb_cpol0_cpha0_lsbfe0_seqs::new(string name = "apb_cpol0_cpha0_lsbfe0_seqs");
	super.new(name);
endfunction

//---------------------------------------Body()---------------------------------------------
task apb_cpol0_cpha0_lsbfe0_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")

	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		data1 = cntrl; //Master mode with CPOL = 0, CPHA = 0, lsbfe = 0(LSB first)
		data2 = 8'b0001_1000;//CR2 - modefault and bidirectional is enabled
		data3 = 8'b0011_0010;//BR - SPPR and SPR values 32 each with 781.25kHz clock frequency

		start_item(req);
		assert(req.randomize with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;}) // Performs dummy read for any register except data register
		finish_item(req);

		//SPI Configurations via RAL - All writes use: Backdoor access (bypass APB), Register map reference, Parent context for transaction linking
		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));

		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);
		//APB Write to Data Register
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101; Pwdata inside {[8'h1F:8'hFF]};})
		finish_item(req);
	end
endtask

//----------------------------------------Low Power Mode Sequence--------------------------
class apb_low_power_mode_seqs extends apb_seqs;
	`uvm_object_utils(apb_low_power_mode_seqs)

	bit[7:0] cntrl;
	rand bit [2:0] spr;
	rand bit [2:0] sppr;

	extern function new(string name = "apb_low_power_mode_seqs");
	extern task body();
endclass

//-----------------------------------------------Constructor new----------------------------
function apb_low_power_mode_seqs::new(string name = "apb_low_power_mode_seqs");
	super.new(name);
endfunction

//------------------------------------------Body()-----------------------------------
task apb_low_power_mode_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")
	
	repeat(1) begin
		if(!this.randomize() with {spr inside {[0:7]}; sppr inside {[0:7]};})
			`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Have you set it right???")

		req = apb_xtn::type_id::create("req");
		data1 = cntrl;
		data2 = 8'b0001_1011;
		data3 = {1'b0, sppr, 1'b0, spr};

		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;})
		finish_item(req);

		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		
		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);

		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//----------------------------------------Random Mode Sequence--------------------------
class apb_random_mode_seqs extends apb_seqs;
	`uvm_object_utils(apb_random_mode_seqs)

	bit[7:0] cntrl;
	rand bit [2:0] spr;
	rand bit [2:0] sppr;
	rand bit [1:0] swai_spco;
	rand bit [1:0] modfen_bidiroe;

	extern function new(string name = "apb_random_mode_seqs");
	extern task body();
endclass

//-----------------------------------------------Constructor new----------------------------
function apb_random_mode_seqs::new(string name = "apb_random_mode_seqs");
	super.new(name);
endfunction

//------------------------------------------Body()-----------------------------------
task apb_random_mode_seqs::body();
	super.body();

	if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "bit[7:0]", cntrl))
		`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Did you set it right in test class???")
	
	repeat(1) begin
		if(!this.randomize() with {spr inside {[0:7]}; sppr inside {[0:7]}; modfen_bidiroe inside {[0:3]}; swai_spco inside {0,1};})
			`uvm_fatal(get_type_name(), "Cannot get cntrl from config_db... Have you set it right???")

		req = apb_xtn::type_id::create("req");
		data1 = cntrl;
		data2 = {3'b000, modfen_bidiroe, 1'b0, swai_spco};;
		data3 = {1'b0, sppr, 1'b0, spr};

		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b0; Paddr != 3'b101;})
		finish_item(req);

		this.spi_reg_blk.cntrl_reg1.write(status, data1, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.cntrl_reg2.write(status, data2, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		this.spi_reg_blk.baud_reg.write(status, data3, .path(UVM_BACKDOOR), .map(spi_reg_blk.spi_reg_map), .parent(this));
		
		//spi_reg_blk.spi_reg_cg.sample(data1, data2, data3);

		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b1; Paddr == 3'b101;})
		finish_item(req);
	end
endtask

//---------------------------------------Data Register Read Sequence---------------------------------
class apb_data_read_seqs extends apb_seqs;
	`uvm_object_utils(apb_data_read_seqs)

	extern function new(string name = "apb_data_read_seqs");
	extern task body();
endclass

//----------------------------------------Constructor new------------------------------------------
function apb_data_read_seqs::new(string name = "apb_data_read_seqs");
	super.new(name);
endfunction

//----------------------------------------BODY()--------------------------------------------------
task apb_data_read_seqs::body();
	super.body();
	repeat(1) begin
		req = apb_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {Presetn == 1'b1; Pwrite == 1'b0; Paddr == 3'b101;})
		finish_item(req);
	end
endtask
