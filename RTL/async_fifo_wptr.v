//==============================================================================
// Project      : Asynchronous FIFO
// File Name    : async_fifo_wptr.v
// Module Name  : async_fifo_wptr
// Author       : Ramasubbu Bala Murugan
// Description  :
//   Generates the binary and Gray-code write pointers, controls write pointer
//   advancement, and asserts the FIFO Full flag when the FIFO becomes full.
//
// Language     : Verilog-2001
// Simulator    : Icarus Verilog 12.0
//==============================================================================

  //==================================================
  // Write module
  //===================================================
  
  module async_fifo_wptr
  #(
  parameter ADDR_WIDTH = 4
  ) 
  (
  //-----------------------------------------------------------------------------
  // Inputs
  // wr_clk      : Write clock
  // wr_rst      : Active-High write domain reset
  // wr_en       : Write enable
  // rd_gray_sync: Read pointer synchronized into write clock domain
  //-----------------------------------------------------------------------------
  input wire wr_clk,
  input wire wr_rst,
  input wire wr_en,
  input wire [ADDR_WIDTH:0] rd_gray_sync,

  //-----------------------------------------------------------------------------
  // Outputs
  // wr_bin      : Binary write pointer
  // wr_gray     : Gray-code write pointer
  // full        : FIFO Full status flag
  //----------------------------------------------------------------------------- 
  
  output reg [ADDR_WIDTH:0] wr_bin,
  output reg [ADDR_WIDTH:0] wr_gray,
  output reg                   full,
  output wire                wr_fire
  );
  
  //-----------------------------------------------------------------------------
  // Internal Registers
  // wr_bin_next_  : Next binary write pointer
  // wr_gray_next  : Next Gray-code write pointer
  // full_next     : Next full flag
  //-----------------------------------------------------------------------------
  wire [ADDR_WIDTH:0]  wr_bin_next;
  wire [ADDR_WIDTH:0] wr_gray_next;
  wire                   full_next;

  //-----------------------------------------------------------------------------
  // Convert binary write pointer to Gray code.
  //
  // Gray code changes only one bit between consecutive values, reducing the
  // possibility of metastability when crossing clock domains.
  //-----------------------------------------------------------------------------
  
  function [ADDR_WIDTH:0] bin2gray;
   input [ADDR_WIDTH:0] bin;
    
  begin
      bin2gray = (bin>>1) ^ bin;
  end
  endfunction
  
  assign wr_fire = wr_en && !full;
    
  //-----------------------------------------------------------------------------
  // Compute the next binary write pointer.
  //
  // The pointer advances only when:
  //   1. Write enable is asserted
  //   2. FIFO is not full
  //-----------------------------------------------------------------------------
  
  assign wr_bin_next = wr_bin + wr_fire;
  
  assign wr_gray_next = bin2gray(wr_bin_next);

  //-----------------------------------------------------------------------------
  // FIFO Full Detection
  //
  // FIFO becomes full when:
  //
  //   wr_gray_next == {
  //        ~rd_gray_sync[MSB:MSB-1],
  //         rd_gray_sync[remaining_bits]
  //   }
  //
  // Inverting the two MSBs distinguishes the FULL condition from the EMPTY
  // condition, where Gray-code pointers would otherwise appear identical.
  //-----------------------------------------------------------------------------
  
  assign full_next = 
    (wr_gray_next == 
    {
      ~rd_gray_sync [ADDR_WIDTH:ADDR_WIDTH-1],
       rd_gray_sync[ADDR_WIDTH-2:0]
    });

  //--------------------------------------------------------------------------------------
  // Update binary, Gray-code write pointers and full flag on every rising edge of wr_clk.
  //
  // Reset initializes both pointers and full flag to zero.
  //---------------------------------------------------------------------------------------
  
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
