package apb_spi_pkg;
//import uvm_pkg.sv
	import uvm_pkg::*;
//include uvm_macros.sv
	`include "uvm_macros.svh"
//`include "tb_defs.sv"
`include "apb_xtn.sv"
`include "apb_agent_config.sv"
`include "spi_config.sv"
`include "spi_reg_integer_file.sv"
`include "spi_reg_block.sv"
`include "env_config.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_sequencer.sv"
`include "apb_agent.sv"
`include "apb_agent_top.sv"
`include "apb_seqs.sv"

`include "spi_xtn.sv"
`include "spi_monitor.sv"
`include "spi_sequencer.sv"
`include "spi_seqs.sv"
`include "spi_driver.sv"
`include "spi_agent.sv"
`include "spi_agent_top.sv"

`include "spi_virt_seqr.sv"
`include "spi_virt_seqs.sv"
`include "spi_scoreboard.sv"
`include "tb.sv"
`include "test.sv"
endpackage
