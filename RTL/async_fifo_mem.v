//============================================================
// Project     : Asynchronous FIFO
// Module      : async_fifo_mem
// Language    : Verilog/SystemVerilog
// Description : Extracted from original design.sv
//============================================================

module async_fifo_mem 
  #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH      = 16,
  parameter ADDR_WIDTH = $clog2(DEPTH)
  ) 
  (
    //Write Port
    input wire                     wr_clk,
    input wire                     wr_en,
    input wire  [ADDR_WIDTH:0]     wr_bin,
    input wire  [DATA_WIDTH-1:0]   wr_data,
    
    //Read Port
    input wire                     rd_clk,
    input wire                     rd_en,
    input wire  [ADDR_WIDTH:0]     rd_bin,
    output reg  [DATA_WIDTH-1:0]   rd_data
  );
  
  //Memory Array
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  
  //----------------------------------------------------------
  // Write Port
  //----------------------------------------------------------
  
  always@(posedge wr_clk)
  begin
    if(wr_en)
      mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
  end
  
  //----------------------------------------------------------
  // Read Port
  //----------------------------------------------------------
  
  always@(posedge rd_clk)
  begin
    if(rd_en)
      rd_data <= mem[rd_bin[ADDR_WIDTH-1:0]];
  end
  
endmodule
  
  //==================================================
  // Write module
  //===================================================
