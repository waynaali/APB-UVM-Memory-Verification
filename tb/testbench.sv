`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_tb_uvm_pkg::*;

module tbench_top;

  logic PCLK;
  logic PRESETn;

  always #5 PCLK = ~PCLK;

  initial begin
    PCLK   = 1'b0;
    PRESETn = 1'b0;

    repeat(2) @(posedge PCLK);
    PRESETn = 1'b1;
  end

  apb_if intf(PCLK, PRESETn);

  // The APB wrapper is the DUT being verified.
  apb_wrapper #(
    .ADDR_W     (32),
    .DATA_W     (64),
    .MEM_SIZE_K (64),
    .BASE_ADDR  (0)
  ) DUT (
    .PCLK    (intf.PCLK),
    .PRESETn (intf.PRESETn),
    .PSELx   (intf.PSELx),
    .PENABLE (intf.PENABLE),
    .PWRITE  (intf.PWRITE),
    .PWDATA  (intf.PWDATA),
    .PSTRB   (intf.PSTRB),
    .PADDR   (intf.PADDR),
    .PRDATA  (intf.PRDATA),
    .PREADY  (intf.PREADY),
    .PSLVERR (intf.PSLVERR)
  );

  initial begin
    uvm_config_db#(virtual apb_if)::set(
      uvm_root::get(), "*", "vif", intf
    );
  end

  initial begin
    run_test();
  end
initial begin
    $vcdplusfile("waveform.vpd");
    $vcdpluson();
end

always @(posedge PCLK) begin
  #1;
  if (intf.PSELx && intf.PENABLE && intf.PREADY) begin

    $display("==============================================");
    $display("APB DEBUG @ %0t", $time);

    $display("PADDR       = %h", intf.PADDR);
    $display("PWRITE      = %b", intf.PWRITE);
    $display("PREADY      = %b", intf.PREADY);
    $display("PSLVERR     = %b", intf.PSLVERR);
    $display("PRDATA      = %h", intf.PRDATA);

    $display("INTERNAL:");
    $display("rdata_valid = %b", DUT.generic_mem_i.rdata_valid);
    $display("rdata       = %h", DUT.generic_mem_i.rdata);

    $display("==============================================");

  end

end
endmodule
