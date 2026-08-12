//==============================================================================
// Project      : Asynchronous FIFO
// File Name    : tb_top.sv
// Module Name  : Asynchronous FIFO_Testbench
// Author       : Ramasubbu Bala Murugan
// Description  :
//   Top-level SystemVerilog testbench for the Asynchronous FIFO.
//
//   This module contains the DUT instance, clock and reset generation,
//   simulation control, waveform generation, and execution of the
//   verification test sequence.
//
// Language     : SystemVerilog
// Simulator    : Icarus Verilog 12.0
//==============================================================================

//==============================================================================
// Testbench Top Module
//==============================================================================

module tb;

  //==========================================================================
  // Testbench Parameters
  //==========================================================================

  parameter DATA_WIDTH = 8;
  parameter DEPTH      = 16;
  parameter ADDR_WIDTH = $clog2(DEPTH);


  //==========================================================================
  // Write Clock Domain Signals
  //==========================================================================

  logic                   wr_clk;
  logic                   wr_rst;
  logic                   wr_en;
  logic [DATA_WIDTH-1:0]  wr_data;


  //==========================================================================
  // Read Clock Domain Signals
  //==========================================================================

  logic                   rd_clk;
  logic                   rd_rst;
  logic                   rd_en;
  logic [DATA_WIDTH-1:0]  rd_data;


  //==========================================================================
  // FIFO Status Signals
  //==========================================================================

  logic full;
  logic empty;


  //==========================================================================
  // DUT Instantiation
  //==========================================================================

  async_fifo_top
  #(
    .DATA_WIDTH (DATA_WIDTH),
    .DEPTH      (DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  )
  DUT
  (
    .wr_clk  (wr_clk),
    .wr_rst  (wr_rst),
    .wr_en   (wr_en),
    .wr_data (wr_data),

    .rd_clk  (rd_clk),
    .rd_rst  (rd_rst),
    .rd_en   (rd_en),
    .rd_data (rd_data),

    .full    (full),
    .empty   (empty)
  );


  //==========================================================================
  // Write Clock Generation
  //==========================================================================
  //
  // Write clock period = 10 ns
  // Write clock frequency = 100 MHz
  //
  //==========================================================================

  initial
  begin
    wr_clk = 1'b0;

    forever
      #5 wr_clk = ~wr_clk;
  end


  //==========================================================================
  // Read Clock Generation
  //==========================================================================
  //
  // Read clock period = 14 ns
  // Read clock frequency ≈ 71.43 MHz
  //
  // The different clock period intentionally creates asynchronous clock
  // domains for FIFO CDC verification.
  //
  //==========================================================================

  initial
  begin
    rd_clk = 1'b0;

    forever
      #7 rd_clk = ~rd_clk;
  end


  //==========================================================================
  // Reset Generation
  //==========================================================================
  //
  // Both FIFO clock domains are initially held in reset.
  //
  // After 30 ns, the write and read resets are deasserted.
  //
  // Initial control signals are also driven to inactive values.
  //
  //==========================================================================

  initial
  begin

    wr_rst = 1'b1;
    rd_rst = 1'b1;

    wr_en  = 1'b0;
    rd_en  = 1'b0;

    wr_data = '0;

    #30;

    wr_rst = 1'b0;
    rd_rst = 1'b0;

  end


  //==========================================================================
  // Waveform Dump
  //==========================================================================
  //
  // Generates a VCD waveform file for post-simulation debugging and analysis.
  //
  // The generated waveform can be viewed using GTKWave.
  //
  //==========================================================================

  initial
  begin

    $dumpfile("Async_FIFO.vcd");
    $dumpvars(0, tb);

  end


  //==========================================================================
  // Test Execution
  //==========================================================================
  //
  // The individual test tasks will be moved to separate verification files
  // during the remaining testbench refactoring stages.
  //
  //==========================================================================

  initial
  begin

    // Test sequence will be added after the verification components
    // are separated into their respective files.

  end


  //==========================================================================
  // Final Verification Summary
  //==========================================================================
  //
  // PASS/FAIL counters and the final verification summary will be connected
  // to the scoreboard module during the next refactoring stage.
  //
  //==========================================================================

  final
  begin

    $display("\n======================================");
    $display("      Asynchronous FIFO Verification   ");
    $display("======================================");

    $display("Simulation completed");
    $display("======================================\n");

  end


endmodule
