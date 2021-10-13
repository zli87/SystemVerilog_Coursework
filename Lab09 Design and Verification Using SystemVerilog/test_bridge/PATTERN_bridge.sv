`include "Usertype_PKG.sv"

//---------------------------------------------------------------------
//   define macro
//---------------------------------------------------------------------
`define ADDR32(x,addr) {x.DRAM[(addr)],x.DRAM[(addr)+1],x.DRAM[(addr)+2],x.DRAM[(addr)+3]}
`define ACCT2NETLIST(x) {  x.bank, x.acct_no, x.ecrp_pw, x.blnc }

module  PATTERN_bridge(input clk, INF.PATTERN_bridge inf);
import usertype::*;
//---------------------------------------------------------------------
//   Pseudo DRAM
//---------------------------------------------------------------------
pseudo_DRAM u_DRAM( .clk(clk), .inf(inf.DRAM) );
//parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
//logic [7:0] golden_DRAM[((65536+256*4)-1):(65536+0)];
integer addr_start = 32'h00010000 ;     // 65536
integer addr_end   = 32'h00010400 ;     // 65536 + 256*4
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter CYCLE = 7.0;
integer i,t,x,lat,p,patnumber=256; // 0x10000~0x3ffff => (0x40000-0x10000)/0x400

//---------------------------------------------------------------------
//   logic
//---------------------------------------------------------------------
acct_status acct_golden, acct ;
logic [7:0] addr;
logic pattern_wb;

initial begin
  //$readmemb(DRAM_p_r, golden_DRAM);
  //f_in  = $fopen("../00_TESTBED/maze.txt", "r");
  //f_ans = $fopen("../00_TESTBED/ans.txt", "r");
  inf.rst_n=1'b1;
  inf.C_in_valid=1'b0;
  inf.C_r_wb = 1;
  inf.C_addr = 0;
  inf.C_data_w = 0;

  force clk = 0;
  reset_signal_task;
  for(p=0;p<patnumber;p=p+1) begin
      input_task;
      wait_done;
      check_ans;
  end
  YOU_PASS_task;
end

//================================================================
// task
//================================================================
task reset_signal_task; begin
    #CYCLE; inf.rst_n = 0;
    #CYCLE; inf.rst_n = 1;
    if(inf.C_out_valid!==1'b0) begin//out!==0
        $display("************************************************************");
        $display("*  Output signal should be 0 after initial RESET  at %8t   *",$time);
        $display("************************************************************");
        repeat(2) #CYCLE;
        $finish;
    end
	#CYCLE; release clk;
    for(i=addr_start;i<addr_end;i=i+4)
        `ADDR32(u_DRAM,i) = $random();             // address to 8 bit
end endtask

task input_task; begin
    addr = p;
    //addr = $random() & 32'h000000ff;                        // 8 bit address
    pattern_wb = $random() % 'd2;
    //$display("%h %1d",addr,pattern_wb);
    // 1 : read 0 :write
    if(!pattern_wb) begin
        // write
        acct_golden.bank = $random() & 32'h0000000f;            // 4 bit
        acct_golden.acct_no = $random() & 32'h0000000f;         // 4 bit
        acct_golden.ecrp_pw[7:4] = $random() & 32'h0000000f;    // 4 bit
        acct_golden.ecrp_pw[3:0] = acct_golden.bank;                // 4 bit
        acct_golden.blnc = $random() & 32'h0000ffff;            // 16 bit
                                                                // Total 32 bit = 4 BYTE
        `ADDR32(u_DRAM,(addr_start+(addr<<2)) ) = `ACCT2NETLIST(acct_golden);
    end else begin
        `ACCT2NETLIST(acct_golden) = `ADDR32(u_DRAM,(addr_start+(addr<<2)) );
    end
    //$display("gold pattern = %h",acct_golden);
    // delay
	t= $random() %3'd3+1;
	repeat(t) @(negedge clk);
    // set input signal
	inf.C_in_valid=1'b1;
    inf.C_r_wb = pattern_wb;
    inf.C_addr = addr;
    inf.C_data_w = `ACCT2NETLIST(acct_golden);
    @(negedge clk);
    inf.C_in_valid=1'b0;
    inf.C_r_wb = 1;
    inf.C_addr = 0;
    inf.C_data_w = 0;
end endtask

task wait_done; begin
    lat=-1;
    while(inf.C_out_valid!==1) begin
	lat=lat+1;
    if(lat==30)begin//lat==max+1
    //if(lat==2000000)begin//lat==max+1
          $display("********************************************************");
          $display ("                           FAIL!                       ");
          $display("*  The execution latency are over 2000000 cycles  at %8t   *",$time);//over max
          $display("********************************************************");
	    repeat(2)@(negedge clk);
	    $finish;
      end
     @(negedge clk);
   end
end endtask

task check_ans; begin
    x=1;
    while(inf.C_out_valid)
    begin
        if(x>1) begin
            $display("********************************************************");
            $display ("                          FAIL!                        ");
            $display ("              Outvalid is more than 1 cycles           ");
            $display("********************************************************");
            repeat(9) @(negedge clk);
            $finish;
        end
        // check ans in DRAM
        if(!pattern_wb) begin
            // write ans
            `ACCT2NETLIST(acct) = `ADDR32(u_DRAM,(addr_start+(addr<<2)) );
            if(acct_golden!=acct)begin
                $display("*****************************************************************************");
                $display ("                          FAIL! write Mail Base %h  ",i);
                $display ("                          Ans                Your");
                $display ("          bank            %16b         %16b  ",acct_golden.bank,acct.bank);
                $display ("          acct_no         %16b         %16b  ",acct_golden.acct_no,acct.acct_no);
                $display ("          ecrp_pw         %16b         %16b  ",acct_golden.ecrp_pw,acct.ecrp_pw);
                $display ("          blnc            %16b         %16b  ",acct_golden.blnc,acct.blnc);
                $display("*****************************************************************************");
                repeat(9) @(negedge clk);
                $finish;
            end
        end else begin
            // read
            `ACCT2NETLIST(acct) = inf.C_data_r;
            if(acct_golden!=acct)begin
                $display("*****************************************************************************");
                $display ("                          FAIL! read Mail Base %h  ",i);
                $display ("                          Ans                Your");
                $display ("          bank            %16b         %16b  ",acct_golden.bank,acct.bank);
                $display ("          acct_no         %16b         %16b  ",acct_golden.acct_no,acct.acct_no);
                $display ("          ecrp_pw         %16b         %16b  ",acct_golden.ecrp_pw,acct.ecrp_pw);
                $display ("          blnc            %16b         %16b  ",acct_golden.blnc,acct.blnc);
                $display("*****************************************************************************");
                repeat(9) @(negedge clk);
                $finish;
            end
        end

        @(negedge clk);
        x=x+1;
    end
    $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mexecution cycle : %3d,\033[m \033[0;34m 0x%h \033[m",p ,lat,addr_start+(p<<2));
end endtask

task YOU_PASS_task; begin
    $display ("--------------------------------------------------------------------");
    $display ("                         Congratulations!                           ");
    $display ("                  You have passed all patterns                      ");
    $display ("--------------------------------------------------------------------");
    repeat(2)@(negedge clk);
    $finish;
end endtask

endmodule
