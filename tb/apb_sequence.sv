// Base Sequence
class apb_base_sequence extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_base_sequence)

  function new(string name = "apb_base_sequence");
    super.new(name);
  endfunction
endclass


// Write Sequence
class apb_write_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_write_sequence)

  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0000;
      req.wdata == 64'h1122_3344_5566_7788;
      req.strb  == 8'hFF;
    })
  endtask
endclass


// Read Sequence
class apb_read_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_read_sequence)

  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0000;
    })
  endtask
endclass


// Write/Read Sequence
class apb_wr_rd_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_wr_rd_sequence)

  function new(string name = "apb_wr_rd_sequence");
    super.new(name);
  endfunction

  task body();
    // Full-word write/read
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0000;
      req.wdata == 64'h1122_3344_5566_7788;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0000;
    })

    // Partial write: lower 4 bytes only
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0000;
      req.wdata == 64'hAABB_CCDD_EEFF_0011;
      req.strb  == 8'h0F;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0000;
    })

    // Aligned address
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0010;
      req.wdata == 64'hDEAD_BEEF_CAFE_BABE;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0010;
    })

    // Misaligned access -> PSLVERR expected
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0004;
      req.wdata == 64'h1234_5678_9ABC_DEF0;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0004;
    })

    // Out-of-range access -> PSLVERR expected
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0001_0000;
      req.wdata == 64'hFACE_CAFE_DEAD_BEEF;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0001_0000;
    })
  endtask
endclass


// Stress Sequence
class apb_stress_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_stress_sequence)

  function new(string name = "apb_stress_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (100) begin
      `uvm_do_with(req, {
        req.write dist {1 := 50, 0 := 50};
        req.addr inside {[32'h0000_0000 : 32'h0000_FFF8]};
        req.addr[2:0] == 3'b000;
        req.strb == 8'hFF;
      })
    end
  endtask
endclass


// Boundary Sequence
class apb_boundary_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_boundary_sequence)

  function new(string name = "apb_boundary_sequence");
    super.new(name);
  endfunction

  task body();
    // First valid address
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0000;
      req.wdata == 64'h1111_2222_3333_4444;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0000;
    })

    // Last valid aligned address
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_FFF8;
      req.wdata == 64'hAAAA_BBBB_CCCC_DDDD;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_FFF8;
    })

    // First invalid address
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0001_0000;
      req.wdata == 64'hDEAD_BEEF_DEAD_BEEF;
      req.strb  == 8'hFF;
    })
  endtask
endclass


// Random Sequence
class apb_random_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_random_sequence)

  function new(string name = "apb_random_sequence");
    super.new(name);
  endfunction

  task body();
    bit [31:0] a;
    repeat (10) begin
      `uvm_do_with(req, {
        req.write == 1;
        req.addr inside {[32'h0000_0000 : 32'h0000_FFF8]};
        req.addr[2:0] == 3'b000;
        req.strb inside {8'hFF, 8'h0F, 8'hF0, 8'hAA, 8'h55, 8'h01, 8'h80};
      })
      a = req.addr;

      `uvm_do_with(req, {
        req.write == 0;
        req.addr == local::a;
      })
    end
  endtask
endclass
class apb_b2b_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_b2b_sequence)

  function new(string name = "apb_b2b_sequence");
    super.new(name);
  endfunction

  task body();

    // WRITE 1
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0000;
      req.wdata == 64'h1111_2222_3333_4444;
      req.strb  == 8'hFF;
    })

    // WRITE 2 - immediately next transaction
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0008;
      req.wdata == 64'hAAAA_BBBB_CCCC_DDDD;
      req.strb  == 8'hFF;
    })

    // READ 1
    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0000;
    })

    // READ 2
    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0008;
    })

    // WRITE -> READ same address
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0010;
      req.wdata == 64'hDEAD_BEEF_CAFE_BABE;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0010;
    })

  endtask

endclass
class apb_strobe_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_strobe_sequence)

  function new(string name = "apb_strobe_sequence");
    super.new(name);
  endfunction

  task body();

    // Full write
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0020;
      req.wdata == 64'h1122_3344_5566_7788;
      req.strb  == 8'hFF;
    })

    // Lower 4 bytes
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0020;
      req.wdata == 64'hAAAA_BBBB_CCCC_DDDD;
      req.strb  == 8'h0F;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0020;
    })

    // Upper 4 bytes
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0020;
      req.wdata == 64'hEEEE_FFFF_1111_2222;
      req.strb  == 8'hF0;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0020;
    })

    // Alternating bytes
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0020;
      req.wdata == 64'h1234_5678_9ABC_DEF0;
      req.strb  == 8'hAA;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0020;
    })

    // Other alternating pattern
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0020;
      req.wdata == 64'hFEDC_BA98_7654_3210;
      req.strb  == 8'h55;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0020;
    })

  endtask

endclass
class apb_error_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_error_sequence)

  function new(string name = "apb_error_sequence");
    super.new(name);
  endfunction

  task body();

    // Misaligned addresses
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0001;
      req.wdata == 64'h1111_1111_1111_1111;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0000_0002;
    })

    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0000_0004;
      req.wdata == 64'h2222_2222_2222_2222;
      req.strb  == 8'hFF;
    })

    // First address outside valid range
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0001_0000;
      req.wdata == 64'hAAAA_AAAA_AAAA_AAAA;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0001_0000;
    })

    // Another invalid address
    `uvm_do_with(req, {
      req.write == 1;
      req.addr  == 32'h0001_0008;
      req.wdata == 64'hBBBB_BBBB_BBBB_BBBB;
      req.strb  == 8'hFF;
    })

    `uvm_do_with(req, {
      req.write == 0;
      req.addr  == 32'h0001_0008;
    })

  endtask

endclass 
