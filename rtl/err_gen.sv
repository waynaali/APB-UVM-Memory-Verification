module err_gen #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 64,
  parameter int MEM_SIZE_K = 64,
  parameter int unsigned BASE_ADDR = 0
)(
  input  logic [ADDR_W-1:0] addr,
  output logic [2:0]        error
);

  localparam int MEM_SIZE_B = MEM_SIZE_K * 1024;
  localparam int ADDR_ALIGN = DATA_W / 8;

  assign error[0] = (addr < BASE_ADDR) ||
                    (addr >= (BASE_ADDR + MEM_SIZE_B));

  assign error[1] = (addr % ADDR_ALIGN) != 0;

  assign error[2] = 1'b0;

endmodule
