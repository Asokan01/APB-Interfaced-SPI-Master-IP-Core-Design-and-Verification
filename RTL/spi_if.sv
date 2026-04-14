interface spi_if(input bit clk);
	logic ss;
	logic mosi;
	logic miso;
	logic sclk;
	logic spi_int_req;

	clocking spi_drv_cb@(posedge clk);
		default input #1 output #1;
		input ss;
		input sclk;
		input mosi;
		input spi_int_req;
		output miso;
	endclocking

	clocking spi_mon_cb@(posedge clk);
		default input #1 output #1;
		input ss;
		input sclk;
		input mosi;
		input miso;
		input spi_int_req;
	endclocking

	modport SPI_DRV_MP(clocking spi_drv_cb);
	modport SPI_MON_MP(clocking spi_mon_cb);
endinterface
