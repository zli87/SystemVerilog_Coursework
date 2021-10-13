`timescale 1ns/100ps

`include "Usertype_PKG.sv"
`include "INF.sv"
`include "PATTERN.sv"
`include "../00_TESTBED/pseudo_DRAM.sv"

`ifdef RTL
  `include "bridge.sv"
  `include "payment.sv"
`endif

`ifdef GATE
  `include "bridge_SYN.v"
  `include "bridge_Wrapper.sv"
  `include "payment_SYN.v"
  `include "payment_Wrapper.sv"
`endif

module TESTBED;

  parameter simulation_cycle = 2.7;
  reg  SystemClock;

  INF  inf(SystemClock);
  PATTERN test_p(.clk(SystemClock), .inf(inf.PATTERN));
  pseudo_DRAM dram_r(.clk(SystemClock), .inf(inf.DRAM));


  `ifdef RTL
	bridge    dut_b(.clk(SystemClock), .inf(inf.bridge_inf) );
	payment   dut_p(.clk(SystemClock), .inf(inf.payment_inf) );
  `endif

  `ifdef GATE
	bridge_svsim dut_b(.clk(SystemClock), .inf(inf.bridge_inf) );
	payment_svsim dut_p(.clk(SystemClock), .inf(inf.payment_inf) );
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
    $fsdbDumpfile("CTS.fsdb");
    $fsdbDumpvars(0,"+all");
    $fsdbDumpSVA;
  `elsif GATE
    $fsdbDumpfile("CTS_SYN.fsdb");
    $sdf_annotate("bridge_SYN.sdf",dut_b.bridge);
    $sdf_annotate("payment_SYN.sdf",dut_p.payment);
    $fsdbDumpvars(0,"+all");
  `endif
end

endmodule
