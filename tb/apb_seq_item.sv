class apb_seq_item extends uvm_sequence_item;

  rand bit [31:0] addr;
  rand bit [63:0] wdata;
  rand bit [7:0]  strb;
  rand bit        write;

       bit [63:0] rdata;
       bit        ready;
       bit        slverr;

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(addr,   UVM_ALL_ON)
    `uvm_field_int(wdata,  UVM_ALL_ON)
    `uvm_field_int(strb,   UVM_ALL_ON)
    `uvm_field_int(write,  UVM_ALL_ON)
    `uvm_field_int(rdata,  UVM_ALL_ON)
    `uvm_field_int(ready,  UVM_ALL_ON)
    `uvm_field_int(slverr, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

endclass
class apb_coverage extends uvm_subscriber #(apb_seq_item);

  `uvm_component_utils(apb_coverage)

  apb_seq_item item;

  covergroup apb_cg;

    cp_write: coverpoint item.write {
      bins READ  = {0};
      bins WRITE = {1};
    }

    cp_addr: coverpoint item.addr {
      bins FIRST = {32'h0000_0000};

      bins LOW = {
        [32'h0000_0008 : 32'h0000_00F8]
      };

      bins MIDDLE = {
        [32'h0000_0100 : 32'h0000_0FF8]
      };

      bins HIGH = {
        [32'h0000_1000 : 32'h0000_FFF0]
      };

      bins LAST = {32'h0000_FFF8};

      bins MISALIGNED = {
        32'h0000_0002,
        32'h0000_0004,
        32'h0000_0006
      };

      bins OUT_OF_RANGE = {
        32'h0001_0000
      };
    }

    cp_strb: coverpoint item.strb {
      bins FULL      = {8'hFF};
      bins LOWER     = {8'h0F};
      bins UPPER     = {8'hF0};
  
      bins BYTE7     = {8'h80};
      bins ALTERNATE = {8'hAA, 8'h55};
    }

    cp_error: coverpoint item.slverr {
      bins NO_ERROR = {0};
      bins ERROR    = {1};
    }

    cp_ready: coverpoint item.ready {
      bins NOT_READY = {0};
      bins READY     = {1};
    }

    rw_error: cross cp_write, cp_error;

  endgroup


  function new(string name = "apb_coverage",
               uvm_component parent = null);
    super.new(name, parent);
    apb_cg = new();
  endfunction


  virtual function void write(apb_seq_item t);
    item = t;
    apb_cg.sample();
  endfunction

endclass
