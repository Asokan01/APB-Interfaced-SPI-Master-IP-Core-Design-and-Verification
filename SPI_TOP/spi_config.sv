class spi_config extends uvm_object;

        `uvm_object_utils(spi_config) //Factory registration

        //Virtual interface declaration
        virtual spi_if sif;

        uvm_active_passive_enum is_active;
	
	int spi_drv_sent_xtn_cnt;
	int spi_mon_rcvd_xtn_cnt;

        //Methods
        extern function new(string name = "spi_config");
endclass

//-------------------Constructor new--------------------------
function spi_config::new(string name = "spi_config");
        super.new(name);
endfunction

