//============================================================
// Project     : Asynchronous FIFO
// Module      : async_fifo_wptr
// Language    : Verilog/SystemVerilog
// Description : Extracted from original design.sv
//============================================================

module async_fifo_wptr
  #(
  parameter ADDR_WIDTH = 4
  ) 
  (
  input wire wr_clk,
  input wire wr_rst,
  input wire wr_en,
  input wire [ADDR_WIDTH:0] rd_gray_sync,
  
  output reg [ADDR_WIDTH:0] wr_bin,
  output reg [ADDR_WIDTH:0] wr_gray,
  output reg                   full,
  output wire                wr_fire
  );
  
  
  wire [ADDR_WIDTH:0]  wr_bin_next;
  wire [ADDR_WIDTH:0] wr_gray_next;
  wire                   full_next;
  
  function [ADDR_WIDTH:0] bin2gray;
   input [ADDR_WIDTH:0] bin;
    
  begin
      bin2gray = (bin>>1) ^ bin;
  end
  endfunction
  
  assign wr_fire = wr_en && !full;
  
  assign wr_bin_next = wr_bin + wr_fire;
  
  assign wr_gray_next = bin2gray(wr_bin_next);
  
  assign full_next = 
    (wr_gray_next == 
    {
      ~rd_gray_sync [ADDR_WIDTH:ADDR_WIDTH-1],
       rd_gray_sync[ADDR_WIDTH-2:0]
    });
  
  always@(posedge wr_clk or posedge wr_rst)
  begin
    if(wr_rst)
    begin
      
      wr_bin  <= 0;
      wr_gray <= 0;
      full    <= 0;
      
    end
    else
    begin
      
      wr_bin  <= wr_bin_next;
      wr_gray <= wr_gray_next;
      full    <= full_next;
      
    end
  end
  
endmodule

  //================================================
  // Read Module
  //=================================================
