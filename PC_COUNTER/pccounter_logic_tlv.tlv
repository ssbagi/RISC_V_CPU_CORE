\m5_TLV_version 1d: tl-x.org
\m5
   
   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
	m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])
   
\TLV
   $reset = *reset;
   //`BOGUS_USE($instr);
   //`READONLY_MEM($pc, $$instr[31:0]);
   
   // YOUR CODE HERE
   // ...
   $next_pc[31:0] = $reset == 0? 32'hABCD:$pc[31:0];
   // Below is implemting the always @(posedge clk). Not a loop we need add this in loop
   $pc[31:0] = >>1$next_pc[31:0];
   
   // Generate a set of Tetscase for PC.
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   
\SV
   endmodule
