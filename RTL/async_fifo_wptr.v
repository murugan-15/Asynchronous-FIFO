//==============================================================================
// Project      : Asynchronous FIFO
// File Name    : async_fifo_wptr.v
// Module Name  : async_fifo_wptr
// Author       : Ramasubbu Bala Murugan
// Description  :
//   Generates the binary and Gray-code write pointers, controls write pointer
//   advancement, and generates the FIFO Full flag.
//
//   The write pointer operates in the write clock domain. The synchronized
//   read pointer is used to determine whether the FIFO has reached its
//   maximum capacity.
//
// Language     : Verilog-2001
// Simulator    : Icarus Verilog 12.0
//==============================================================================

//==============================================================================
// Write Pointer Controller
//==============================================================================
//
// This module performs the following functions:
//
//   1. Maintains the binary write pointer.
//   2. Generates the Gray-code write pointer.
//   3. Advances the write pointer after a successful write.
//   4. Generates the FIFO Full flag.
//
// The write pointer operates entirely in the write clock domain.
//
//==============================================================================

module async_fifo_wptr
#(
    // Number of address bits required to address the FIFO memory.
    // An additional bit is used by the pointer for Full/Empty detection.
    parameter ADDR_WIDTH = 4
)
(
    //==========================================================================
    // Write Clock Domain
    //==========================================================================

    input wire wr_clk,       // Write clock
    input wire wr_rst,       // Active-high asynchronous reset
    input wire wr_en,        // Write enable

    //==========================================================================
    // Clock Domain Crossing Signal
    //==========================================================================

    // Gray-coded read pointer synchronized into the write clock domain.
    input wire [ADDR_WIDTH:0] rd_gray_sync,

    //==========================================================================
    // Write Pointer Outputs
    //==========================================================================

    // Binary write pointer used for addressing FIFO memory.
    output reg [ADDR_WIDTH:0] wr_bin,

    // Gray-coded write pointer transferred to the read clock domain.
    output reg [ADDR_WIDTH:0] wr_gray,

    // FIFO Full status flag.
    output reg full,

    // Indicates that a valid write operation will occur.
    output wire wr_fire
);


    //==========================================================================
    // Internal Signals
    //==========================================================================

    // Next binary write pointer.
    wire [ADDR_WIDTH:0] wr_bin_next;

    // Next Gray-coded write pointer.
    wire [ADDR_WIDTH:0] wr_gray_next;

    // Next value of the Full flag.
    wire full_next;


    //==========================================================================
    // Binary-to-Gray Code Conversion
    //==========================================================================
    //
    // Gray code changes only one bit between consecutive pointer values.
    // This property reduces the possibility of multiple bits changing
    // simultaneously while the pointer crosses an asynchronous clock domain.
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
    // Write Transaction Detection
    //==========================================================================
    //
    // A write operation is considered valid only when:
    //
    //     wr_en = 1
    //     FIFO is not Full
    //
    // Therefore, the write pointer advances only when wr_fire is asserted.
    //
    //==========================================================================

    assign wr_fire = wr_en && !full;


    //==========================================================================
    // Next Write Pointer Calculation
    //==========================================================================

    // Advance the binary write pointer after a successful write.
    assign wr_bin_next = wr_bin + wr_fire;

    // Convert the next binary write pointer to Gray code.
    assign wr_gray_next = bin2gray(wr_bin_next);


    //==========================================================================
    // Full Flag Generation
    //==========================================================================
    //
    // The FIFO becomes Full when the next write pointer reaches the position
    // corresponding to the synchronized read pointer after one complete
    // buffer traversal.
    //
    // In Gray-code representation, the Full condition is detected by
    // comparing the next write pointer against the synchronized read pointer
    // with the two most significant bits inverted.
    //
    // The two MSBs are inverted to distinguish the Full condition from the
    // Empty condition, since both conditions involve pointer equality.
    //
    //==========================================================================

    assign full_next =
        (wr_gray_next ==
        {~rd_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
          rd_gray_sync[ADDR_WIDTH-2:0]});


    //==========================================================================
    // Write Pointer and Full Flag Registers
    //==========================================================================
    //
    // The write pointer and Full flag are updated on every rising edge
    // of the write clock.
    //
    // Asynchronous reset initializes:
    //
    //     wr_bin  = 0
    //     wr_gray = 0
    //     full    = 0
    //
    // After reset, the FIFO contains no data and therefore cannot be Full.
    //
    //==========================================================================

    always @(posedge wr_clk or posedge wr_rst)
    begin
        if (wr_rst)
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
