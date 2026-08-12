//==============================================================================
// Project      : Asynchronous FIFO
// File Name    : sync_ptr.v
// Module Name  : sync_ptr
// Author       : Ramasubbu Bala Murugan
// Description  :
//   Two-stage synchronizer used to transfer a Gray-coded FIFO pointer
//   safely between asynchronous clock domains.
//
//   The first flip-flop samples the incoming pointer and may temporarily
//   enter a metastable state. The second flip-flop provides an additional
//   clock cycle for metastability to resolve before the synchronized pointer
//   is used by the destination clock domain.
//
// Language     : Verilog-2001
// Simulator    : Icarus Verilog 12.0
//==============================================================================

//==============================================================================
// Pointer Synchronizer
//==============================================================================
//
// This module synchronizes a Gray-coded FIFO pointer from one asynchronous
// clock domain into another clock domain.
//
// Synchronization is performed using two cascaded flip-flops:
//
//
//        Source Clock Domain             Destination Clock Domain
//
//        ptr_gray
//           |
//           v
//      +-----------+
//      | sync_ff1  |  <-- First synchronization stage
//      +-----------+
//           |
//           v
//      +-----------+
//      |ptr_gray_sync| <-- Second synchronization stage
//      +-----------+
//
// The two-stage structure reduces the probability of metastability
// propagating into the destination logic.
//
//==============================================================================

module sync_ptr
#(
    // Number of address bits used by the FIFO.
    // One additional bit is included for the FIFO pointer MSB.
    parameter ADDR_WIDTH = 4
)
(
    //==========================================================================
    // Destination Clock Domain
    //==========================================================================

    input wire clk,      // Destination clock
    input wire rst,      // Active-high asynchronous reset

    //==========================================================================
    // Pointer Input
    //==========================================================================

    // Gray-coded pointer generated in the source clock domain.
    input wire [ADDR_WIDTH:0] ptr_gray,

    //==========================================================================
    // Synchronized Pointer Output
    //==========================================================================

    // Gray-coded pointer safely synchronized into the destination
    // clock domain.
    output reg [ADDR_WIDTH:0] ptr_gray_sync
);


    //==========================================================================
    // Synchronizer Register
    //==========================================================================

    // First stage of the two-flop synchronizer.
    //
    // This register directly samples the asynchronous Gray-coded pointer.
    // If metastability occurs, the following synchronization stage provides
    // additional time for the signal to settle.
    //
    reg [ADDR_WIDTH:0] sync_ff1;


    //==========================================================================
    // Two-Stage Synchronizer
    //==========================================================================
    //
    // Both registers are clocked by the destination clock.
    //
    // On reset:
    //   sync_ff1      = 0
    //   ptr_gray_sync = 0
    //
    // During normal operation:
    //   sync_ff1      captures the asynchronous pointer.
    //   ptr_gray_sync captures the previous value of sync_ff1.
    //
    // Non-blocking assignments ensure that both registers update
    // simultaneously while preserving the intended two-stage pipeline.
    //
    //==========================================================================

    always @(posedge clk or posedge rst)
    begin
        if (rst)
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
