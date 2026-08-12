//==============================================================================
// Project      : Asynchronous FIFO
// File Name    : tb_monitor.sv
// Module Name  : tb_monitor
// Author       : Ramasubbu Bala Murugan
// Description  :
//   Monitors write-side and read-side FIFO activity and reports accepted
//   transactions to the verification environment.
//
//   The monitor observes DUT signals only. It does not maintain the golden
//   model and does not perform expected-vs-actual comparisons.
//
// Language     : SystemVerilog
// Simulator    : Icarus Verilog 12.0
//==============================================================================

//==============================================================================
// FIFO Monitor
//==============================================================================

module tb_monitor
#(
    parameter DATA_WIDTH = 8
)
(
    //==========================================================================
    // Write Clock Domain
    //==========================================================================

    input logic                  wr_clk,
    input logic                  wr_rst,
    input logic                  wr_en,
    input logic [DATA_WIDTH-1:0] wr_data,
    input logic                  full,

    //==========================================================================
    // Read Clock Domain
    //==========================================================================

    input logic                  rd_clk,
    input logic                  rd_rst,
    input logic                  rd_en,
    input logic [DATA_WIDTH-1:0] rd_data,
    input logic                  empty,


    //==========================================================================
    // Monitor Events
    //==========================================================================

    // Pulses once after each monitored write-clock cycle.
    output logic wr_obs_event,

    // Pulses once after each monitored read-clock cycle.
    output logic rd_obs_event,


    //==========================================================================
    // Observed Write Transaction
    //==========================================================================

    // Indicates that the current write request was accepted by the FIFO.
    output logic wr_accepted,

    // Data associated with the accepted write transaction.
    output logic [DATA_WIDTH-1:0] wr_observed_data,


    //==========================================================================
    // Observed Read Transaction
    //==========================================================================

    // Indicates that the current read request was accepted by the FIFO.
    output logic rd_accepted,

    // Data currently observed at the FIFO read output.
    output logic [DATA_WIDTH-1:0] rd_observed_data,


    //==========================================================================
    // Monitor Statistics
    //==========================================================================

    output integer wr_req_count,
    output integer rd_req_count,

    output integer wr_accept_count,
    output integer rd_accept_count,

    output integer overflow_count,
    output integer underflow_count
);


    //==========================================================================
    // Initialization
    //==========================================================================

    initial
    begin
        wr_obs_event     = 1'b0;
        rd_obs_event     = 1'b0;

        wr_accepted      = 1'b0;
        rd_accepted      = 1'b0;

        wr_observed_data = '0;
        rd_observed_data = '0;

        wr_req_count     = 0;
        rd_req_count     = 0;

        wr_accept_count  = 0;
        rd_accept_count  = 0;

        overflow_count   = 0;
        underflow_count  = 0;
    end


    //==========================================================================
    // Write-Side Monitor
    //==========================================================================
    //
    // A write request is observed when wr_en is asserted.
    //
    // The request is considered accepted when the FIFO is not Full.
    //
    // wr_accepted therefore represents:
    //
    //     wr_en && !full
    //
    // The monitor does not update the golden model. It only reports the
    // observed write transaction to the scoreboard.
    //
    //==========================================================================

    always @(posedge wr_clk)
    begin
        #1;

        // Default value for this monitoring cycle.
        wr_accepted = 1'b0;

        // Generate one observation event.
        wr_obs_event = 1'b1;

        if (wr_en)
        begin
            wr_req_count++;

            if (!full)
            begin
                wr_accept_count++;

                wr_accepted      = 1'b1;
                wr_observed_data = wr_data;

                $display("[%0t] MONITOR: WRITE %0h",
                         $time,
                         wr_data);
            end
            else
            begin
                overflow_count++;

                $display("[%0t] MONITOR: WRITE BLOCKED - FIFO FULL",
                         $time);
            end
        end

        // Remove event pulse.
        wr_obs_event = 1'b0;

    end


    //==========================================================================
    // Read-Side Monitor
    //==========================================================================
    //
    // A read request is observed when rd_en is asserted.
    //
    // The request is considered accepted when the FIFO is not Empty.
    //
    // rd_accepted therefore represents:
    //
    //     rd_en && !empty
    //
    // The read data is captured for the scoreboard.
    //
    //==========================================================================

    always @(posedge rd_clk)
    begin
        #1;

        // Default value for this monitoring cycle.
        rd_accepted = 1'b0;

        // Capture the current DUT read data.
        rd_observed_data = rd_data;

        // Generate one observation event.
        rd_obs_event = 1'b1;

        if (rd_en)
        begin
            rd_req_count++;

            if (!empty)
            begin
                rd_accept_count++;

                rd_accepted = 1'b1;

                $display("[%0t] MONITOR: READ DATA = %0h",
                         $time,
                         rd_data);
            end
            else
            begin
                underflow_count++;

                $display("[%0t] MONITOR: READ BLOCKED - FIFO EMPTY",
                         $time);
            end
        end

        // Remove event pulse.
        rd_obs_event = 1'b0;

    end


endmodule
