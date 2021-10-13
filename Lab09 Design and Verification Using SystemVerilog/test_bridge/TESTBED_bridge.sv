`timescale 1ns/100ps

`include "Usertype_PKG.sv"
`include "INF.sv"
`include "PATTERN_bridge.sv"
`include "../00_TESTBED/pseudo_DRAM.sv"

`ifdef RTL
  `include "bridge.sv"
`endif

module TESTBED;

  parameter simulation_cycle = 7;
  reg  SystemClock;

  INF  inf(SystemClock);
  PATTERN_bridge test_p(.clk(SystemClock), .inf(inf.PATTERN_bridge));


  `ifdef RTL
	bridge dut(.clk(SystemClock), .inf(inf.bridge_inf) );
  `endif

 //------ Generate Clock ------------
  initial begin
    SystemClock = 0;
	#30
    forever begin
      #(simulation_cycle/2.0)
        SystemClock = ~SystemClock;
    end
  end

//------ Dump VCD File ------------
initial begin
  `ifdef RTL
    $fsdbDumpfile("bridge.fsdb");
    $fsdbDumpvars(0,"+all");
    $fsdbDumpSVA;
  `elsif GATE
    $fsdbDumpfile("bridge_SYN.fsdb");
    $sdf_annotate("bridge_SYN.sdf",dut.BRF);
    $fsdbDumpvars(0,"+all");
  `endif
end

endmodule
