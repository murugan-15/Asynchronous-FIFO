//============================================================
// Project     : Asynchronous FIFO
// Module      : sync_ptr
// Language    : Verilog/SystemVerilog
// Description : Extracted from original design.sv
//============================================================

module sync_ptr
  #(
  parameter ADDR_WIDTH = 4
   ) 
   (
   input wire                        clk,
   input wire                        rst,
     
   input wire [ADDR_WIDTH:0]     ptr_gray,
   output reg [ADDR_WIDTH:0] ptr_gray_sync
   );
  
  reg [ADDR_WIDTH:0] sync_ff1;
  
  always@(posedge clk or posedge rst)
  begin
    if(rst)
    begin
      
      sync_ff1      <= 0;
      ptr_gray_sync <= 0;
      
    end
    else
    begin
      
      sync_ff1      <= ptr_gray;
      ptr_gray_sync <= sync_ff1;
      
    end
  end
endmodule
