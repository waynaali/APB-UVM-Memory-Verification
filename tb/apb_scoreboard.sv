class apb_scoreboard extends uvm_scoreboard;

  uvm_analysis_imp #(apb_seq_item, apb_scoreboard) item_collected_export;

  // DUT memory is 64 KB and data width is 64 bits.
  bit [63:0] model_mem [0:8191];
  bit        model_valid [0:8191];

  int unsigned pass_count;
  int unsigned fail_count;

  `uvm_component_utils(apb_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_export = new("item_collected_export", this);

    for(int i = 0; i < 8192; i++) begin
      model_mem[i]   = '0;
      model_valid[i] = 1'b0;
    end
  endfunction

  function void write(apb_seq_item item);
    int unsigned word_idx;
    bit expected_error;
    bit [63:0] expected_data;
    bit [63:0] old_data;

    // 64-bit data requires 8-byte alignment.
    expected_error = (item.addr >= 32'h0001_0000) ||
                     (item.addr[2:0] != 3'b000);

    if(!item.ready) begin
      fail_count++;
      `uvm_error("APB_SCB", "APB transfer completed without PREADY")
      return;
    end

    if(item.slverr !== expected_error) begin
      fail_count++;
      `uvm_error("APB_SCB",
        $sformatf("PSLVERR mismatch: addr=0x%08h expected=%0b actual=%0b",
                  item.addr, expected_error, item.slverr))
    end

    if(expected_error) begin
      if(item.write)
        `uvm_info("APB_SCB",
          $sformatf("Expected error WRITE: addr=0x%08h", item.addr), UVM_MEDIUM)
      else
        `uvm_info("APB_SCB",
          $sformatf("Expected error READ: addr=0x%08h", item.addr), UVM_MEDIUM)

      // Error accesses must not modify the model.
      if(item.write) begin
        // Nothing to update.
      end

      if(item.write || !item.write) begin
        pass_count++;
      end
      return;
    end

    word_idx = item.addr >> 3;

    if(item.write) begin
      old_data = model_valid[word_idx] ? model_mem[word_idx] : 64'h0;
      expected_data = old_data;

      for(int b = 0; b < 8; b++) begin
        if(item.strb[b])
          expected_data[b*8 +: 8] = item.wdata[b*8 +: 8];
      end

      model_mem[word_idx]   = expected_data;
      model_valid[word_idx] = 1'b1;

      pass_count++;
      `uvm_info("APB_SCB",
        $sformatf("WRITE accepted: addr=0x%08h data=0x%016h strb=0x%02h",
                  item.addr, expected_data, item.strb),
        UVM_MEDIUM)
    end
    else begin
      expected_data = model_valid[word_idx] ? model_mem[word_idx] : 64'h0;

      if(item.rdata === expected_data) begin
        pass_count++;
        `uvm_info("APB_SCB",
          $sformatf("READ PASS: addr=0x%08h expected=0x%016h actual=0x%016h",
                    item.addr, expected_data, item.rdata),
          UVM_MEDIUM)
      end
      else begin
        fail_count++;
        `uvm_error("APB_SCB",
          $sformatf("READ FAIL: addr=0x%08h expected=0x%016h actual=0x%016h",
                    item.addr, expected_data, item.rdata))
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("APB_SCB",
      $sformatf("Scoreboard summary: PASS=%0d FAIL=%0d",
                pass_count, fail_count),
      UVM_NONE)
  endfunction

endclass
