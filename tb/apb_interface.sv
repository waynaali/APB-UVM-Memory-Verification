interface apb_if(input logic PCLK, input logic PRESETn);

  logic        PSELx;
  logic        PENABLE;
  logic        PWRITE;
  logic [31:0] PADDR;
  logic [63:0] PWDATA;
  logic [7:0]  PSTRB;

  logic [63:0] PRDATA;
  logic        PREADY;
  logic        PSLVERR;

  clocking driver_cb @(posedge PCLK);
    default input #1step output #1;
    output PSELx;
    output PENABLE;
    output PWRITE;
    output PADDR;
    output PWDATA;
    output PSTRB;
    input  PRDATA;
    input  PREADY;
    input  PSLVERR;
  endclocking

  clocking monitor_cb @(posedge PCLK);
    default input #1step output #1;
    input PSELx;
    input PENABLE;
    input PWRITE;
    input PADDR;
    input PWDATA;
    input PSTRB;
    input PRDATA;
    input PREADY;
    input PSLVERR;
  endclocking

  modport DRIVER  (clocking driver_cb, input PCLK, PRESETn);
  modport MONITOR (clocking monitor_cb, input PCLK, PRESETn);

  // ------------------------------------------------------------------
  // Simple APB protocol assertions
  // ------------------------------------------------------------------
  // Everything is checked on posedge PCLK and disabled during reset.

  // 1. PENABLE must never be high without PSELx
  a_penable_needs_psel: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    PENABLE |-> PSELx
  ) else $error("APB ASSERT: PENABLE high while PSELx low");

  // 2. SETUP phase (PSELx=1, PENABLE=0) must be followed by ACCESS (PENABLE=1)
  a_setup_then_access: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    (PSELx && !PENABLE) |=> (PSELx && PENABLE)
  ) else $error("APB ASSERT: ACCESS phase did not follow SETUP phase");

  // 3. Address/control/data must be stable from SETUP until the transfer completes
  a_ctrl_stable_setup: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    (PSELx && !PENABLE) |=> $stable({PWRITE, PADDR, PWDATA, PSTRB})
  ) else $error("APB ASSERT: control signals changed between SETUP and ACCESS");

  a_ctrl_stable_access: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    (PSELx && PENABLE && !PREADY) |=> $stable({PWRITE, PADDR, PWDATA, PSTRB})
  ) else $error("APB ASSERT: control signals changed while waiting for PREADY");

  // 4. PSLVERR is only valid together with PREADY
  a_slverr_needs_pready: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    PSLVERR |-> PREADY
  ) else $error("APB ASSERT: PSLVERR asserted without PREADY");

  // 5. After the transfer completes (PREADY), PENABLE must drop on the next cycle
  a_penable_drops_after_ready: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    (PSELx && PENABLE && PREADY) |=> !PENABLE
  ) else $error("APB ASSERT: PENABLE still high after PREADY (transfer end)");

  // 6. No X/Z on master control signals or slave response after reset
  a_no_x_master: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    !$isunknown({PSELx, PENABLE, PWRITE, PADDR, PSTRB})
  ) else $error("APB ASSERT: X/Z on master control signals");

  a_no_x_slave: assert property (
    @(posedge PCLK) disable iff (!PRESETn)
    !$isunknown({PREADY, PSLVERR})
  ) else $error("APB ASSERT: X/Z on PREADY/PSLVERR");

  // Cover: make sure these scenarios were actually exercised
  c_write_ok:  cover property (@(posedge PCLK) disable iff (!PRESETn)
                 PSELx && PENABLE && PREADY && PWRITE  && !PSLVERR);
  c_read_ok:   cover property (@(posedge PCLK) disable iff (!PRESETn)
                 PSELx && PENABLE && PREADY && !PWRITE && !PSLVERR);
  c_slverr:    cover property (@(posedge PCLK) disable iff (!PRESETn)
                 PSELx && PENABLE && PREADY && PSLVERR);

endinterface