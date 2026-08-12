//==============================================================================
// Project      : Asynchronous FIFO
// File Name    : async_fifo_rptr.v
// Module Name  : async_fifo_rptr
// Author       : Ramasubbu Bala Murugan
// Description  :
//   Generates the binary and Gray-code read pointers, controls read pointer
//   advancement, and generates the FIFO Empty flag.
//
//   The read pointer operates in the read clock domain. The synchronized
//   write pointer is used to determine whether all available FIFO data
//   has been consumed.
//
// Language     : Verilog-2001
// Simulator    : Icarus Verilog 12.0
//==============================================================================

//==============================================================================
// Read Pointer Controller
//==============================================================================
//
// This module performs the following functions:
//
//   1. Maintains the binary read pointer.
//   2. Generates the Gray-code read pointer.
//   3. Advances the read pointer after a successful read.
//   4. Generates the FIFO Empty flag.
//
// The read pointer operates entirely in the read clock domain.
//
//==============================================================================

module async_fifo_rptr
#(
    // Number of address bits required to address the FIFO memory.
    // An additional bit is used by the pointer for Full/Empty detection.
    parameter ADDR_WIDTH = 4
)
(
    //==========================================================================
    // Read Clock Domain
    //==========================================================================

    input wire rd_clk,       // Read clock
    input wire rd_rst,       // Active-high asynchronous reset
    input wire rd_en,        // Read enable

    //==========================================================================
    // Clock Domain Crossing Signal
    //==========================================================================

    // Gray-coded write pointer synchronized into the read clock domain.
    input wire [ADDR_WIDTH:0] wr_gray_sync,

    //==========================================================================
    // Read Pointer Outputs
    //==========================================================================

    // Binary read pointer used for addressing FIFO memory.
    output reg [ADDR_WIDTH:0] rd_bin,

    // Gray-coded read pointer transferred to the write clock domain.
    output reg [ADDR_WIDTH:0] rd_gray,

    // FIFO Empty status flag.
    output reg empty,

    // Indicates that a valid read operation will occur.
    output wire rd_fire
);


    //==========================================================================
    // Internal Signals
    //==========================================================================

    // Next binary read pointer.
    wire [ADDR_WIDTH:0] rd_bin_next;

    // Next Gray-coded read pointer.
    wire [ADDR_WIDTH:0] rd_gray_next;

    // Next value of the Empty flag.
    wire empty_next;


    //==========================================================================
    // Binary-to-Gray Code Conversion
    //==========================================================================
    //
    // Gray code changes only one bit between consecutive pointer values.
    // This property makes Gray-coded pointers suitable for crossing
    // asynchronous clock domains.
    //
    // Binary-to-Gray conversion:
    //
    //     Gray = Binary ^ (Binary >> 1)
    //
    //==========================================================================

    function [ADDR_WIDTH:0] bin2gray;
        input [ADDR_WIDTH:0] bin;

        begin
            bin2gray = (bin >> 1) ^ bin;
        end
    endfunction


    //==========================================================================
    // Read Transaction Detection
    //==========================================================================
    //
    // A read operation is considered valid only when:
    //
    //     rd_en = 1
    //     FIFO is not Empty
    //
    // Therefore, the read pointer advances only when rd_fire is asserted.
    //
    //==========================================================================

    assign rd_fire = rd_en && !empty;


    //==========================================================================
    // Next Read Pointer Calculation
    //==========================================================================

    // Advance the binary read pointer after a successful read.
    assign rd_bin_next = rd_bin + rd_fire;

    // Convert the next binary read pointer to Gray code.
    assign rd_gray_next = bin2gray(rd_bin_next);


    //==========================================================================
    // Empty Flag Generation
    //==========================================================================
    //
    // The FIFO is Empty when the next read pointer becomes equal to the
    // synchronized write pointer.
    //
    // This comparison is performed using Gray-coded pointers because the
    // write pointer has crossed into the read clock domain through the
    // pointer synchronizer.
    //
    //==========================================================================

    assign empty_next = (rd_gray_next == wr_gray_sync);


    //==========================================================================
    // Read Pointer and Empty Flag Registers
    //==========================================================================
    //
    // The read pointer and Empty flag are updated on every rising edge
    // of the read clock.
    //
    // Asynchronous reset initializes:
    //
    //     rd_bin  = 0
    //     rd_gray = 0
    //     empty   = 1
    //
    // Since both pointers start at zero, the FIFO initially contains
    // no valid data and is therefore Empty.
    //
    //==========================================================================

    always @(posedge rd_clk or posedge rd_rst)
    begin
        if (rd_rst)
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
