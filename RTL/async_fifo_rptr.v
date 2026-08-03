//============================================================
// Project     : Asynchronous FIFO
// Module      : async_fifo_rptr
// Language    : Verilog/SystemVerilog
// Description : Extracted from original design.sv
//============================================================

module async_fifo_rptr
  #(
    parameter ADDR_WIDTH  = 4
  )
  (
  input wire  rd_clk,
  input wire  rd_rst,
  input wire  rd_en,
    
  input wire  [ADDR_WIDTH:0] wr_gray_sync,
  
  output reg [ADDR_WIDTH:0] rd_bin,
  output reg [ADDR_WIDTH:0] rd_gray,
  output reg                  empty,
  output wire                rd_fire
  );
  
  wire [ADDR_WIDTH:0]  rd_bin_next;
  wire [ADDR_WIDTH:0] rd_gray_next;
  wire                  empty_next;
  
  function [ADDR_WIDTH:0] bin2gray;
    input [ADDR_WIDTH:0] bin;
    
    begin
      bin2gray = (bin>>1) ^ bin;
    end
  endfunction
  
  assign rd_fire      = rd_en && !empty;
  assign rd_bin_next  = rd_bin + rd_fire;
  assign rd_gray_next = bin2gray(rd_bin_next);;
  assign empty_next   = (rd_gray_next == wr_gray_sync);
  
  always@(posedge rd_clk or posedge rd_rst)
  begin
    if(rd_rst)
    begin
      rd_bin  <= 0;
      rd_gray <= 0;
      empty   <= 1;
    end
    else
    begin
      
      rd_bin  <= rd_bin_next;
      rd_gray <= rd_gray_next;
      empty   <= empty_next;
      
    end
  end
  
endmodule
        
     
  //=============================================
  // Synchronizer Module
  //=============================================
