module apb_wrapper #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 64,
  parameter int MEM_SIZE_K = 64,
  parameter int unsigned BASE_ADDR = 0
)(
  input  logic                  PCLK,
  input  logic                  PRESETn,
  input  logic                  PSELx,
  input  logic                  PENABLE,
  input  logic                  PWRITE,
  input  logic [DATA_W-1:0]     PWDATA,
  input  logic [DATA_W/8-1:0]   PSTRB,
  input  logic [ADDR_W-1:0]     PADDR,

  output logic [DATA_W-1:0]     PRDATA,
  output logic                  PREADY,
  output logic                  PSLVERR
);

  localparam int ADDR_W_T = $clog2(MEM_SIZE_K) + 10;

  logic [ADDR_W_T-1:0] PADDR_T;
  logic [2:0]          slv_err;

  logic                rdata_valid;
  logic                req_fsm_to_mem;
  logic                we_fsm_to_mem;
  logic [DATA_W-1:0]   prdata_intr;

  assign PADDR_T = PADDR - BASE_ADDR;

  apb_fsm #(
    .DATA_W(DATA_W)
  ) apb_fsm_i (
    .PCLK        (PCLK),
    .PRESETn     (PRESETn),
    .PSELx       (PSELx),
    .PENABLE     (PENABLE),
    .PWRITE      (PWRITE),
    .error       (|slv_err),
    .rdata_valid (rdata_valid),
    .prdata_intr (prdata_intr),
    .req         (req_fsm_to_mem),
    .we          (we_fsm_to_mem),
    .PREADY      (PREADY),
    .PSLVERR     (PSLVERR),
    .PRDATA      (PRDATA)
  );

  generic_mem #(
    .AW(ADDR_W_T),
    .DW(DATA_W)
  ) generic_mem_i (
    .clk        (PCLK),
    .rst_n      (PRESETn),
    .req        (req_fsm_to_mem),
    .addr       (PADDR_T),
    .we         (we_fsm_to_mem),
    .wdata      (PWDATA),
    .wstrb      (PSTRB),
    .rdata      (prdata_intr),
    .rdata_valid(rdata_valid)
  );

  err_gen #(
    .ADDR_W     (ADDR_W),
    .DATA_W     (DATA_W),
    .MEM_SIZE_K (MEM_SIZE_K),
    .BASE_ADDR  (BASE_ADDR)
  ) err_gen_i (
    .addr  (PADDR),
    .error (slv_err)
  );

endmodule
