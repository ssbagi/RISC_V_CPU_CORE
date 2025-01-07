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
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])                   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LFBuildingaRISCVCPUCore/main/lib/riscvshelllib.tlv'])
   //`define READONLY_MEM(ADDR, DATA) logic [31:0] MEM[4294967295:0]; assign DATA = MEM[ADDR]; always @(*) MEM[ADDR] = ADDR;
   m4_test_prog()
   
\TLV
   $reset = *reset;
   //...
   // Here, for every clk cycle my IMem has to provide the PC to Decode. In Mean time my PC gets updated i.e., next_pc gets PC + 32bit or 4 Bytes.
   $next_pc[31:0] = $reset == 0 ? ($taken_br ? $br_tgt_pc   : 
                                   $is_jal   ? $br_tgt_pc   : 
                                   $is_jalr  ? $jalr_tgt_pc : $pc[31:0] + 32'd4) : 32'b0;
   
   $pc[31:0] = >>1$next_pc[31:0];
   
   // IMem Instantion
   `READONLY_MEM($pc[31:0], $$instr[31:0]);
   `BOGUS_USE($instr);
   *passed = *cyc_cnt > 800;
   //*passed = 1'b0;
   *failed = 1'b0;
   //Instruction Memory Basically stores the Instruction. Assumed store it at ADDR index PC 
\SV
   endmodule
