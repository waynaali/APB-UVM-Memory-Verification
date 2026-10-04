class apb_env extends uvm_env;

  apb_agent      apb_agnt;
  apb_scoreboard apb_scb;
  apb_coverage   cov;

  `uvm_component_utils(apb_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    apb_agnt = apb_agent::type_id::create("apb_agnt", this);
    apb_scb  = apb_scoreboard::type_id::create("apb_scb", this);
    cov      = apb_coverage::type_id::create("cov", this);

  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Monitor -> Scoreboard
    apb_agnt.monitor.item_collected_port.connect(
      apb_scb.item_collected_export
    );

    // Monitor -> Coverage
    apb_agnt.monitor.item_collected_port.connect(
      cov.analysis_export
    );

  endfunction

endclass