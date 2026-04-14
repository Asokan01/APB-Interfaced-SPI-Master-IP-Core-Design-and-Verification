//-------------------------------SPI_BASE_SEQS-------------------------------
class spi_seqs extends uvm_sequence #(spi_xtn);
	`uvm_object_utils(spi_seqs)

	env_config e_cfg;
	spi_reg_block spi_reg_blk;

	function new(string name = "spi_seqs");
		super.new(name);
	endfunction

	task body();
		if(!uvm_config_db#(env_config)::get(null, get_full_name(), "env_config", e_cfg))
			`uvm_fatal(get_type_name(), "Cannot get e_cfg from config_db... Did you set it right???")

		this.spi_reg_blk = e_cfg.spi_reg_blk;
	endtask
endclass


//-------------------------SPI_CPOL1_CPHA1_SEQS-------------------------
class spi_cpol1_cpha1_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol1_cpha1_seqs)

	function new(string name = "spi_cpol1_cpha1_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass


//-------------------------SPI_CPOL0_CPHA1_SEQS-------------------------
class spi_cpol0_cpha1_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol0_cpha1_seqs)

	function new(string name = "spi_cpol0_cpha1_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass
//-------------------------SPI_CPOL1_CPHA0_SEQS-------------------------
class spi_cpol1_cpha0_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol1_cpha0_seqs)

	function new(string name = "spi_cpol1_cpha0_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass
//-------------------------SPI_CPOL0_CPHA0_SEQS-------------------------
class spi_cpol0_cpha0_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol0_cpha0_seqs)

	function new(string name = "spi_cpol0_cpha0_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass
//-------------------------SPI_CPOL1_CPHA1_LSBFE0_SEQS-------------------------
class spi_cpol1_cpha1_lsbfe0_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol1_cpha1_lsbfe0_seqs)

	function new(string name = "spi_cpol1_cpha1_lsbfe0_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass
//-------------------------SPI_CPOL0_CPHA1_LSBFE0_SEQS-------------------------
class spi_cpol0_cpha1_lsbfe0_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol0_cpha1_lsbfe0_seqs)

	function new(string name = "spi_cpol0_cpha1_lsbfe0_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass
//-------------------------SPI_CPOL1_CPHA0_LSBFE0_SEQS-------------------------
class spi_cpol1_cpha0_lsbfe0_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol1_cpha0_lsbfe0_seqs)

	function new(string name = "spi_cpol1_cpha0_lsbfe0_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass

//-------------------------SPI_CPOL0_CPHA0_LSBFE0_SEQS-------------------------
class spi_cpol0_cpha0_lsbfe0_seqs extends spi_seqs;
	`uvm_object_utils(spi_cpol0_cpha0_lsbfe0_seqs)

	function new(string name = "spi_cpol0_cpha0_lsbfe0_seqs");
		super.new(name);
	endfunction

	task body();
		super.body();

		repeat(1) begin
			req = spi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask
endclass

//-------------------------SPI_RANDOM_MODE_SEQS-------------------------
class spi_random_mode_seqs extends spi_seqs;
        `uvm_object_utils(spi_random_mode_seqs)

        function new(string name = "spi_random_mode_seqs");
                super.new(name);
        endfunction

        task body();
                super.body();

                repeat(1) begin
                        req = spi_xtn::type_id::create("req");
                        start_item(req);
                        assert(req.randomize());
                        finish_item(req);
                end
        endtask
endclass
