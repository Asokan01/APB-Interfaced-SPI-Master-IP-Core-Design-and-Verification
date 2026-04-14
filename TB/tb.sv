class tb extends uvm_env;
	`uvm_component_utils(tb) //Factory Registration

	//Declare low level TB Component handles such as agt tops
	apb_agent_top apb_agt_top;
	spi_agent_top spi_agt_top;

	//Declare handle for env_cfg
	env_config e_cfg;
	
	//Declare handle for virtual sequencer
	spi_virt_seqr vseqr;

	//Declare dynamic handle for scoreboard
	spi_scoreboard sb[];

	//Standard UVM Methods
	extern function new(string name = "tb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//-----------------------------Constructor "new"--------------------------------
function tb::new(string name = "tb", uvm_component parent);
	super.new(name,parent);
endfunction


//-----------------------------Build Phase--------------------------------
function void tb::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("TB","Could not get env_config from uvm_config_db... did u set it?")

	//Create objects for both source and destination agt tops
	begin
		apb_agt_top = apb_agent_top::type_id::create("apb_agt_top",this);
	end

	begin
		spi_agt_top = spi_agent_top::type_id::create("spi_agt_top",this);
	end

	//Create object for virtual sequencer
	if(e_cfg.has_virtual_sequencer)
		vseqr = spi_virt_seqr::type_id::create("vseqr",this);

	if(e_cfg.has_scoreboard) begin
		sb = new[e_cfg.no_of_duts];
	
		foreach(sb[i])
			sb[i] = spi_scoreboard::type_id::create($sformatf("sb[%0d]",i), this);
	end
endfunction


//--------------------------Connect Phase()-----------------------------
function void tb::connect_phase(uvm_phase phase);
	//Connect the sub sequencers in virtual sequencer to the physical src and dst sequencers
	if(e_cfg.has_virtual_sequencer) begin
		begin
			for(int i = 0; i< e_cfg.no_of_src_agt; i++)
				vseqr.apb_seqrh[i] = apb_agt_top.apb_agnth[i].apb_seqrh;
		end

		begin
			for(int i = 0; i< e_cfg.no_of_dest_agt; i++)
				vseqr.spi_seqrh[i] = spi_agt_top.spi_agnth[i].spi_seqrh;
		end
	end

	//Connect scoreboard to monitor here...
	if(e_cfg.has_scoreboard) begin
		//Source
		apb_agt_top.apb_agnth[0].apb_monh.ap.connect(sb[0].fifo_apb[0].analysis_export);

		//Destination
		spi_agt_top.spi_agnth[0].spi_monh.ap.connect(sb[0].fifo_spi[0].analysis_export);
	end	
endfunction
