class apb_monitor extends uvm_monitor;

  virtual apb_if vif;

  uvm_analysis_port #(apb_seq_item) item_collected_port;

  `uvm_component_utils(apb_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever collect_transfer();
  endtask
task collect_transfer();

  apb_seq_item item;

  // -----------------------------
  // 1. Wait for APB SETUP phase
  // -----------------------------
  do begin
    @(vif.monitor_cb);
  end
  while (!(vif.monitor_cb.PSELx   === 1'b1 &&
           vif.monitor_cb.PENABLE === 1'b0));

  item = apb_seq_item::type_id::create("item", this);

  // Capture request during SETUP
  item.addr  = vif.monitor_cb.PADDR;
  item.write = vif.monitor_cb.PWRITE;
  item.wdata = vif.monitor_cb.PWDATA;
  item.strb  = vif.monitor_cb.PSTRB;

  `uvm_info("APB_MON",
    $sformatf(
      "SETUP CAPTURE: %s addr=0x%08h wdata=0x%016h strb=0x%02h",
      item.write ? "WRITE" : "READ",
      item.addr,
      item.wdata,
      item.strb
    ),
    UVM_NONE
  )

  // -----------------------------
  // 2. Wait for ACCESS phase
  // -----------------------------
  do begin
    @(vif.monitor_cb);
  end
  while (!(vif.monitor_cb.PSELx   === 1'b1 &&
           vif.monitor_cb.PENABLE === 1'b1));

  // -----------------------------
  // 3. Wait for PREADY
  // -----------------------------
  do begin
    @(vif.monitor_cb);
  end
  while (vif.monitor_cb.PREADY !== 1'b1);

  // Capture response
  item.ready  = vif.monitor_cb.PREADY;
  item.slverr = vif.monitor_cb.PSLVERR;
  item.rdata  = vif.monitor_cb.PRDATA;

  `uvm_info("APB_MON",
    $sformatf(
      "CAPTURED: %s addr=0x%08h wdata=0x%016h strb=0x%02h rdata=0x%016h ready=%0b slverr=%0b",
      item.write ? "WRITE" : "READ",
      item.addr,
      item.wdata,
      item.strb,
      item.rdata,
      item.ready,
      item.slverr
    ),
    UVM_NONE
  )

  item_collected_port.write(item);

endtask

endclass