module apb_fsm #(
  parameter int DATA_W = 64
)(
  input  logic                  PCLK,
  input  logic                  PRESETn,
  input  logic                  PSELx,
  input  logic                  PENABLE,
  input  logic                  PWRITE,
  input  logic                  error,
  input  logic                  rdata_valid,
  input  logic [DATA_W-1:0]     prdata_intr,

  output reg                    req,
  output reg                    we,
  output reg                    PREADY,
  output reg                    PSLVERR,
  output reg [DATA_W-1:0]       PRDATA
);

  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10
  } state_e;

  state_e state, next_state;

  always @(posedge PCLK) begin
    if(~PRESETn)
      state <= IDLE;
    else
      state <= next_state;
  end

  always @(*) begin
    next_state = state;

    case(state)
      IDLE: begin
        if(PSELx && !PENABLE)
          next_state = SETUP;
      end

      SETUP: begin
        if(PSELx && PENABLE)
          next_state = ACCESS;
        else if(!PSELx)
          next_state = IDLE;
      end

      ACCESS: begin
        if(rdata_valid && PSELx)
          next_state = SETUP;
        else if(rdata_valid && !PSELx)
          next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  always @(*) begin
    req     = 1'b0;
    we      = 1'b0;
    PREADY  = 1'b0;
    PSLVERR = 1'b0;
    PRDATA  = 'z;

    case(state)
      IDLE, SETUP: begin
        req     = 1'b0;
        we      = 1'b0;
        PREADY  = 1'b0;
        PSLVERR = 1'b0;
        PRDATA  = 'z;
      end

      ACCESS: begin
        req     = 1'b1;
        we      = error ? 1'b0 : PWRITE;
        PREADY  = rdata_valid;
        PSLVERR = rdata_valid & error;
        PRDATA  = (rdata_valid & ~PWRITE) ? prdata_intr : 'z;
      end

      default: begin
        req     = 1'b0;
        we      = 1'b0;
        PREADY  = 1'b0;
        PSLVERR = 1'b0;
        PRDATA  = 'z;
      end
    endcase
  end

endmodule
