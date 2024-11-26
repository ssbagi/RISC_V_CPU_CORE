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
	logic[31:0] next_pc;
	logic[31:0] pc;
	
	always_comb
      begin
         if(reset)
            next_pc[31:0] = 32'b0;
         else
            next_pc[31:0] = pc[31:0] + 32'b1;
      end
   
   always_ff @(posedge clk)
      begin
         pc[31:0] = next_pc[31:0];
      end
         

\TLV
   $reset = *reset;
   
   //...
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
