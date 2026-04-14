interface apb_if(input bit clk);
	bit Pclk;
	logic Presetn;
	logic Psel;
	logic Penable;
	logic Pwrite;
	logic [2:0] Paddr;
	logic [7:0] Pwdata;
	logic [7:0] Prdata;
	logic Pready;
	logic Pslverr;

	assign Pclk = clk;

	clocking apb_drv_cb @(posedge clk);
		default input #1 output #1;
		output Pclk, Penable, Presetn, Psel, Paddr, Pwdata, Pwrite;
		input Pready, Prdata, Pslverr;
	endclocking

	clocking apb_mon_cb @(posedge clk);
		default input #1 output #1;
		input Pclk, Penable, Presetn, Psel, Paddr, Pwdata, Pwrite, Pready, Prdata, Pslverr;
	endclocking

	modport APB_DRV_MP (clocking apb_drv_cb);
	modport APB_MON_MP (clocking apb_mon_cb);

	//------------------------------------Assertions----------------------------------
	property signals_stable;
		@(posedge clk) $rose(Psel) |-> ($stable(Pwrite) && $stable(Paddr) && $stable(Pwdata)) until Pready[->1];
	endproperty

	property penable_stable;
		@(posedge clk) $rose(Penable) |-> ($stable(Psel) && $stable(Penable)) until Pready[->1];
	endproperty

	property psel_to_pready;
		@(posedge clk) (Psel && Penable) |-> ##[0:$] Pready;
	endproperty

	property address_reserved;
		@(posedge clk) Psel |-> ((Paddr != 3'b100) || (Paddr != 3'b110) || (Paddr != 3'b111));
	endproperty

	property penable_deassert;
		@(posedge clk) (!Psel) |-> (!Penable);
	endproperty

	property valid_write_data_transfer;
		@(posedge clk) (Psel && Penable && Pwrite) |-> (Pwdata !== 'hx);
	endproperty

	property valid_read_data_transfer;
		@(posedge clk) (Psel && Penable && (!Pwrite)) |-> (Pwdata !== 'hx);
	endproperty
	
	property pready_low_at_start;
		@(posedge clk) (Psel && (!Penable)) |-> (!Pready);
	endproperty

	property pready_deassert;
		@(posedge clk) (!Psel) |-> (!Pready);
	endproperty


	SIGNAL_STABLE	:	assert property(signals_stable)
					$info("SIGNAL STABILITY VERIFIED");
				else
					$error("SIGNAL STABILITY IS NOT VERIFIED");
	
	PENABLE_STABLE	:	assert property(penable_stable)
					$info("ENABLE STABILITY VERIFIED");
				else
					$error("ENABLE STABILITY IS NOT VERIFIED");
	
	PSEL_TO_PREADY	:	assert property(psel_to_pready)
					$info("PSEL & PENABLE TO PREADY VERIFIED");
				else
					$error("PSEL & PENABLE TO PREADY IS NOT VERIFIED");
	
	ADDRESS_RESERVED	:	assert property(address_reserved)
					$info("RESERVED ADDR IS VERIFIED");
				else
					$error("RESERVED ADDR IS NOT VERIFIED");
	
	PENABLE_DEASSERT	:	assert property(penable_deassert)
					$info("WHEN PSEL WENT LOW, PENABLE ALSO WENT LOW VERIFIED");
				
				else
					$error("WHEN PSEL WENT LOW, PENABLE ALSO SHOULD GO LOW IS NOT VERIFIED");
	
	VALID_WDATA_TRANSFER	:	assert property(valid_write_data_transfer)
					$info("VALID WDATA TRANSFER");
				else
					$error("INVALID WDATA TRANSFER");
	
	VALID_RDATA_TRANSFER	:	assert property(valid_read_data_transfer)
					$info("VALID RDATA TRANSFER");
				else
					$error("INVALID RDATA TRANSFER");
	
	PREADY_LOW_AT_START	:	assert property(pready_low_at_start)
					$info("PREADY IS LOW AT START");
				else
					$error("PREADY IS LOW AT START");
	
	PREADY_DEASSERT	:	assert property(pready_deassert)
					$info("PREADY DEASSERTED");
				else
					$error("PREADY IS NOT DEASSERTED");
endinterface
