\m5_TLV_version 1d: tl-x.org
\m5
   
   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   //1. I don't have IMem getting syntax error. So, Only one Instruction executing.
   //   `READONLY_MEM($pc, $instr);
   //2. Loaded directlry one Instruction opcode.
   //     Result is fine
   //     There is random signal generation for others bits which is causing ADDI for those regusters also.
   // =================================================
   
   use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])
   //m4_test_prog()
                   
\TLV
   $reset = *reset;
   
   $next_pc[31:0] = $reset ? ($is_b_instr ? $br_tgt_pc[31:0] : $pc[31:0]) : 32'b0;
   //always @(posedge clk) or shift by 1 clk cycle.
   $pc[31:0] = >>1$next_pc[31:0];
   
   // For testing as of now hard coded to select branch instruction
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_i_instr = $instr[6:2] ==  5'b0000x || $instr[6:2] == 5'b001x0 || $instr[6:2] == 5'b11001;
   $is_r_instr = $instr[6:2] ==  5'b01011 || $instr[6:2] == 5'b01100 || $instr[6:2] == 5'b10100;
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   $is_b_instr = $instr[6:2] == 5'b11000;
   $is_j_instr = $instr[6:2] == 5'b11011;
   
   // Extract fields
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0] = $instr[19:15];
   $rs2[4:0] = $instr[24:20];
   $rd[4:0] = $instr[11:7];
   $opcode[6:0] = $instr[6:0];
   $rs1_valid = $is_i_instr || $is_r_instr || $is_s_instr || $is_b_instr;
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   $rd_valid  = $is_i_instr || $is_r_instr || $is_u_instr || $is_j_instr;
   $imm_valid = $is_i_instr || $is_s_instr || $is_b_instr || $is_u_instr || $is_j_instr;
   //`BOGUS_USE($rd $rd_valid $rs1 $rs1_valid $rs2 $rs2_valid $funct3 $opcode)
   
   //Directly loading always one INSTR Below one.
   $instr[31:0] = 32'h01500093;
   $imm[31:0] =
     $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
     $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
     $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
     $is_u_instr ? { $instr[31:12], 12'b0 } :
     $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20],
                      $instr[30:25], $instr[24:21], 1'b0 } :
                    32'b0;
   
   $dec_bits[10:0] = {$instr[30],$funct3,$opcode};
   
   // Instruction decoder logic.
   $is_beq   = $dec_bits ==? 11'bx_000_1100011;
   $is_bne   = $dec_bits ==? 11'bx_001_1100011;
   $is_blt   = $dec_bits ==? 11'bx_100_1100011;
   $is_bge   = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu  = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu  = $dec_bits ==? 11'bx_111_1100011;
   $is_addi  = $dec_bits ==? 11'bx_000_0010011;
   $is_add   = $dec_bits ==? 11'b0_000_0110011;
   $is_lui   = $dec_bits ==? 11'bx_xxx_0110111;
   $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
   $is_jal   = $dec_bits ==? 11'bx_xxx_1101111;
   $is_jalr  = $dec_bits ==? 11'bx_000_1100111;
   $is_slti  = $dec_bits ==? 11'bx_010_0010011;
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
   $is_xori  = $dec_bits ==? 11'bx_100_0010011;
   $is_ori   = $dec_bits ==? 11'bx_110_0010011;
   $is_andi  = $dec_bits ==? 11'bx_111_0010011;
   $is_slli  = $dec_bits ==? 11'bx_001_0010011;
   $is_srli  = $dec_bits ==? 11'b0_101_0010011;
   $is_srai  = $dec_bits ==? 11'b1_101_0010011;
   $is_sub   = $dec_bits ==? 11'bx_000_0110011;
   $is_sll   = $dec_bits ==? 11'bx_001_0110011;
   $is_slt   = $dec_bits ==? 11'bx_010_0110011;
   $is_sltu  = $dec_bits ==? 11'bx_011_0110011;
   $is_xor   = $dec_bits ==? 11'bx_100_0110011;
   $is_srl   = $dec_bits ==? 11'b0_101_0110011;
   $is_sra   = $dec_bits ==? 11'b1_101_0110011;
   $is_or    = $dec_bits ==? 11'bx_110_0110011;
   $is_and   = $dec_bits ==? 11'bx_111_0110011;
   $is_load  = $opcode[6:0] ==? 7'b0000011;
   
   //I don't have IMem getting syntax error. So, Only one Instruction executing.
   //`READONLY_MEM($pc, $instr);
   
   // Register File Module
   m5+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $result[31:0], $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   
   // ALU Basic implementation of adder only
   $result[31:0] =
      $is_addi ? ($src1_value + $imm) :
      $is_add  ? ($src1_value + $src2_value) :
      $is_xori ? ($src1_value ^ $imm) :
      $is_xor  ? ($src1_value ^ $src2_value) :
      $is_sub  ? ($src1_value - $src2_value) :
      $is_or   ? ($src1_value | $src2_value) :
      $is_and  ? ($src1_value & $src2_value) :
      $is_ori  ? ($src1_value | $imm) :
      $is_andi ? ($src1_value & $imm) :
      $is_slt  ? ($src1_value < $src2_value) :
      $is_slti  ? ($src1_value < $imm) :
      $is_sltiu ? ($src1_value < $imm) :
      $is_slli  ? ($src1_value << $imm) :
      $is_sll   ? ($src1_value << $src2_value) :
      $is_srli  ? ($src1_value >> $imm) :
      $is_srl   ? ($src1_value >> $src2_value) :
      $is_srai  ? ($src1_value >>> $imm) :
      $is_srai  ? ($src1_value >>> $src2_value) :
      $is_lui   ? ({$imm, 12'b0}) :
      $is_auipc ? ({$imm, 12'b0} + $pc[31:0]) :
      //$is_beq   ?
      //$is_bne   ?
      //$is_blt   ?
      //$is_bltu  ?
      //$is_bge   ?
      //$is_bgeu  ?
      //$is_jal   ?
      //$is_jalr  ?
      32'b0;
   
   // Branch Taken Detection
   
   $taken_br =
      $is_beq  ? ($src1_value == $src2_value) :
      $is_bne  ? ($src1_value != $src2_value) :
      $is_blt  ? ($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31]) :
      $is_bge  ? ($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31]) :
      $is_bltu ? ($src1_value < $src2_value) :
      $is_bgeu ? ($src1_value >= $src2_value) :
      
                 1'b0;

   $br_tgt_pc[31:0] = $pc[31:0] + $imm[31:0];
   // For branching ones
   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule