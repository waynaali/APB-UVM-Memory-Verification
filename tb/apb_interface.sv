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

endinterface
