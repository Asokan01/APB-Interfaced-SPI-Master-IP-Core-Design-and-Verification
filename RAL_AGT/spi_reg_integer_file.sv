//-------------------------------------SPI_REG_INTEGER_FILE-----------------------------------------------
//--------------------Control_Register_1-------------------------------------------
class spi_reg_file_cr1 extends uvm_reg;

	`uvm_object_utils(spi_reg_file_cr1) //Factory Registration

	//Each bit field of register needs to be defined
	rand uvm_reg_field lsbfe;
	rand uvm_reg_field ssoe;
	rand uvm_reg_field cpha;
	rand uvm_reg_field cpol;
	rand uvm_reg_field mstr;
	rand uvm_reg_field sptie;
	rand uvm_reg_field spe;
	rand uvm_reg_field spie;

	function new(string name = "spi_reg_file_cr1");
		super.new(name, 8, UVM_CVR_ALL);
	endfunction

	function void build();
		lsbfe = uvm_reg_field::type_id::create("lsbfe");
		ssoe = uvm_reg_field::type_id::create("ssoe");
		cpha = uvm_reg_field::type_id::create("cpha");
		cpol = uvm_reg_field::type_id::create("cpol");
		mstr = uvm_reg_field::type_id::create("mstr");
		sptie = uvm_reg_field::type_id::create("sptie");
		spe = uvm_reg_field::type_id::create("spe");
		spie = uvm_reg_field::type_id::create("spie");
		//Configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, cover_on)
		// volatile 0 means only changes through software access
		lsbfe.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 1);
		ssoe.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 1);
		cpha.configure(this, 1, 2, "RW", 0, 1'b1, 1, 1, 1);
		cpol.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 1);
		mstr.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 1);
		sptie.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 1);
		spe.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 1);
		spie.configure(this, 1, 7, "RW", 0, 1'b0, 1, 1, 1);
	endfunction
endclass

//--------------------Control_Register_2------------------------------------
class spi_reg_file_cr2 extends uvm_reg;

	`uvm_object_utils(spi_reg_file_cr2) //Factory Registration

	//Each bit field of register needs to be defined
	rand uvm_reg_field spc0;
	rand uvm_reg_field spiswai;
	rand uvm_reg_field reserved1;
	rand uvm_reg_field bidiroe;
	rand uvm_reg_field modfen;
	rand uvm_reg_field reserved2;

	function new(string name = "spi_reg_file_cr2");
		super.new(name, 8, UVM_CVR_ALL);
	endfunction

	function void build();
		spc0 = uvm_reg_field::type_id::create("spc0");
		spiswai = uvm_reg_field::type_id::create("spiswai");
		reserved1 = uvm_reg_field::type_id::create("reserved1");
		bidiroe = uvm_reg_field::type_id::create("bidiroe");
		modfen = uvm_reg_field::type_id::create("modfen");
		reserved2 = uvm_reg_field::type_id::create("reserved2");
		//Configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, cover_on)
		// volatile 0 means only changes through software access
		spc0.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 1);
		spiswai.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 1);
		reserved1.configure(this, 1, 2, "RO", 0, 1'b0, 0, 0, 0);
		bidiroe.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 1);
		modfen.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 1);
		reserved2.configure(this, 3, 5, "RO", 0, 1'b0, 0, 0, 0);
	endfunction
endclass

//----------------------Baud_Register--------------------------------
class spi_reg_file_br extends uvm_reg;

	`uvm_object_utils(spi_reg_file_br) //Factory Registration

	//Each bit field of register needs to be defined
	rand uvm_reg_field spr;
	rand uvm_reg_field sppr;
	rand uvm_reg_field reserved1;
	rand uvm_reg_field reserved2;

	function new(string name = "spi_reg_file_br");
		super.new(name, 8, UVM_CVR_ALL);
	endfunction

	function void build();
                spr = uvm_reg_field::type_id::create("spr");
                sppr = uvm_reg_field::type_id::create("sppr");
                reserved1 = uvm_reg_field::type_id::create("reserved1");
                reserved2 = uvm_reg_field::type_id::create("reserved2");
                //Configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, cover_on)
                // volatile 0 means only changes through software access
                spr.configure(this, 3, 0, "RW", 0, 1'b0, 1, 1, 1);
                sppr.configure(this, 3, 4, "RW", 0, 1'b0, 1, 1, 1);
                reserved1.configure(this, 1, 3, "RO", 0, 1'b0, 0, 0, 0);
                reserved2.configure(this, 1, 7, "RO", 0, 1'b0, 0, 0, 0);
        endfunction
endclass

//-------------------------------Status_Register-------------------------------
class spi_reg_file_sr extends uvm_reg;

	`uvm_object_utils(spi_reg_file_sr) //Factory Registration

	//Each bit field of register needs to be defined
        rand uvm_reg_field modf;
        rand uvm_reg_field sptef;
	rand uvm_reg_field spif;
        rand uvm_reg_field reserved1;
        rand uvm_reg_field reserved2;

        function new(string name = "spi_reg_file_sr");
                super.new(name, 8, UVM_CVR_ALL);
        endfunction

        function void build();
                modf = uvm_reg_field::type_id::create("modf");
                sptef = uvm_reg_field::type_id::create("sptef");
                spif = uvm_reg_field::type_id::create("spif");
                reserved1 = uvm_reg_field::type_id::create("reserved1");
                reserved2 = uvm_reg_field::type_id::create("reserved2");
                //Configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, cover_on)
                // volatile 0 means only changes through software access
                modf.configure(this, 1, 4, "RO", 0, 1'b0, 0, 0, 0);
                sptef.configure(this, 1, 5, "RO", 0, 1'b1, 0, 0, 0);
                spif.configure(this, 1, 7, "RO", 0, 1'b0, 0, 0, 0);
                reserved1.configure(this, 4, 0, "RO", 0, 1'b0, 0, 0, 0);
                reserved2.configure(this, 1, 6, "RO", 0, 1'b0, 0, 0, 0);
        endfunction
endclass

//----------------------------Data Register-------------------------------
class spi_reg_file_dr extends uvm_reg;

	`uvm_object_utils(spi_reg_file_dr) //Factory Registration

	//Each bit field of register needs to be defined
	rand uvm_reg_field data;

	function new(string name = "spi_reg_file_dr");
		super.new(name, 8, UVM_CVR_ALL);
	endfunction

	function void build();
		data = uvm_reg_field::type_id::create("data");
		//Configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, cover_on)
		// volatile 0 means only changes through software access
		data.configure(this, 8, 0, "RW", 0, 1'b0, 1, 1, 1);
	endfunction
endclass
