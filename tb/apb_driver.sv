 `define APB_DRIV_IF vif.DRIVER.driver_cb

class apb_driver extends uvm_driver #(apb_seq_item);

  virtual apb_if vif;

  `uvm_component_utils(apb_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",
        {"virtual interface must be set for: ", get_full_name(), ".vif"})
  endfunction

  task run_phase(uvm_phase phase);
    drive_idle();

    forever begin
      seq_item_port.get_next_item(req);
      drive_transfer();
      seq_item_port.item_done();
    end
  endtask

  task drive_idle();
    `APB_DRIV_IF.PSELx   <= 1'b0;
    `APB_DRIV_IF.PENABLE <= 1'b0;
    `APB_DRIV_IF.PWRITE  <= 1'b0;
    `APB_DRIV_IF.PADDR   <= '0;
    `APB_DRIV_IF.PWDATA  <= '0;
    `APB_DRIV_IF.PSTRB   <= '0;
  endtask

  task drive_transfer();

    // Do not start an APB transfer while the DUT is in reset.
    while (vif.PRESETn !== 1'b1)
      @(vif.DRIVER.driver_cb);

    // APB SETUP phase
    @(vif.DRIVER.driver_cb);
    `APB_DRIV_IF.PSELx   <= 1'b1;
    `APB_DRIV_IF.PENABLE <= 1'b0;
    `APB_DRIV_IF.PWRITE  <= req.write;
    `APB_DRIV_IF.PADDR   <= req.addr;
    `APB_DRIV_IF.PWDATA  <= req.wdata;
    `APB_DRIV_IF.PSTRB   <= req.strb;

    // APB ACCESS phase
    @(vif.DRIVER.driver_cb);
    `APB_DRIV_IF.PENABLE <= 1'b1;

    // Wait for DUT to finish the APB transfer.
    do begin
      @(vif.DRIVER.driver_cb);
    end while (`APB_DRIV_IF.PREADY !== 1'b1);

    req.ready  = `APB_DRIV_IF.PREADY;
    req.slverr = `APB_DRIV_IF.PSLVERR;
    req.rdata  = `APB_DRIV_IF.PRDATA;

    // Return to IDLE.
    @(vif.DRIVER.driver_cb);
    `APB_DRIV_IF.PSELx   <= 1'b0;
    `APB_DRIV_IF.PENABLE <= 1'b0;
    `APB_DRIV_IF.PWRITE  <= 1'b0;
    `APB_DRIV_IF.PADDR   <= '0;
    `APB_DRIV_IF.PWDATA  <= '0;
    `APB_DRIV_IF.PSTRB   <= '0;
  endtask

endclass
