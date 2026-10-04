//==============================================================
// APB Base Test
//==============================================================

class apb_base_test extends uvm_test;

  `uvm_component_utils(apb_base_test)

  apb_env env;

  function new(string name = "apb_base_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Global UVM timeout


    env = apb_env::type_id::create("env", this);

  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);

    super.end_of_elaboration_phase(phase);
  uvm_top.set_timeout(100000ns, 1);

    uvm_top.print_topology();
  

  endfunction


  function void report_phase(uvm_phase phase);

    uvm_report_server svr;

    super.report_phase(phase);

    svr = uvm_report_server::get_server();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) > 0) begin

      `uvm_info(get_type_name(),
        "---------------------------------------",
        UVM_NONE)

      `uvm_info(get_type_name(),
        "----           TEST FAIL           ----",
        UVM_NONE)

      `uvm_info(get_type_name(),
        "---------------------------------------",
        UVM_NONE)

    end
    else begin

      `uvm_info(get_type_name(),
        "---------------------------------------",
        UVM_NONE)

      `uvm_info(get_type_name(),
        "----           TEST PASS           ----",
        UVM_NONE)

      `uvm_info(get_type_name(),
        "---------------------------------------",
        UVM_NONE)

    end

  endfunction

endclass



//==============================================================
// Write / Read Test
//==============================================================

class apb_wr_rd_test extends apb_base_test;

  `uvm_component_utils(apb_wr_rd_test)

  apb_wr_rd_sequence seq;

  function new(string name = "apb_wr_rd_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_wr_rd_sequence::type_id::create("seq");

  endfunction


  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass



//==============================================================
// Boundary Test
//==============================================================

class apb_boundary_test extends apb_base_test;

  `uvm_component_utils(apb_boundary_test)

  apb_boundary_sequence seq;

  function new(string name = "apb_boundary_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_boundary_sequence::type_id::create("seq");

  endfunction


  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass



//==============================================================
// Stress Test
//==============================================================

class apb_stress_test extends apb_base_test;

  `uvm_component_utils(apb_stress_test)

  apb_stress_sequence seq;

  function new(string name = "apb_stress_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_stress_sequence::type_id::create("seq");

  endfunction


  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass



//==============================================================
// Random Test
//==============================================================

class apb_random_test extends apb_base_test;

  `uvm_component_utils(apb_random_test)

  apb_random_sequence seq;

  function new(string name = "apb_random_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_random_sequence::type_id::create("seq");

  endfunction


  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass
class apb_b2b_test extends apb_base_test;

  `uvm_component_utils(apb_b2b_test)

  apb_b2b_sequence seq;

  function new(string name = "apb_b2b_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_b2b_sequence::type_id::create("seq");

  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass 
class apb_strobe_test extends apb_base_test;

  `uvm_component_utils(apb_strobe_test)

  apb_strobe_sequence seq;

  function new(string name = "apb_strobe_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_strobe_sequence::type_id::create("seq");

  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass
class apb_error_test extends apb_base_test;

  `uvm_component_utils(apb_error_test)

  apb_error_sequence seq;

  function new(string name = "apb_error_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    seq = apb_error_sequence::type_id::create("seq");

  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.apb_agnt.sequencer);

    phase.drop_objection(this);

  endtask

endclass
class apb_all_test extends apb_base_test;

  `uvm_component_utils(apb_all_test)

  apb_wr_rd_sequence      wr_rd_seq;
  apb_boundary_sequence   boundary_seq;
  apb_b2b_sequence        b2b_seq;
  apb_strobe_sequence     strobe_seq;
  apb_error_sequence      error_seq;
  apb_random_sequence     random_seq;
  apb_stress_sequence     stress_seq;

  function new(string name = "apb_all_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    wr_rd_seq    = apb_wr_rd_sequence::type_id::create("wr_rd_seq");
    boundary_seq = apb_boundary_sequence::type_id::create("boundary_seq");
    b2b_seq      = apb_b2b_sequence::type_id::create("b2b_seq");
    strobe_seq   = apb_strobe_sequence::type_id::create("strobe_seq");
    error_seq    = apb_error_sequence::type_id::create("error_seq");
    random_seq   = apb_random_sequence::type_id::create("random_seq");
    stress_seq   = apb_stress_sequence::type_id::create("stress_seq");
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    `uvm_info("ALL_TESTS", "===== WR/RD TEST START =====", UVM_NONE)
    wr_rd_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== BOUNDARY TEST START =====", UVM_NONE)
    boundary_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== B2B TEST START =====", UVM_NONE)
    b2b_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== STROBE TEST START =====", UVM_NONE)
    strobe_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== ERROR TEST START =====", UVM_NONE)
    error_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== RANDOM TEST START =====", UVM_NONE)
    random_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== STRESS TEST START =====", UVM_NONE)
    stress_seq.start(env.apb_agnt.sequencer);

    `uvm_info("ALL_TESTS", "===== ALL TESTS COMPLETE =====", UVM_NONE)

    phase.drop_objection(this);

  endtask

endclass