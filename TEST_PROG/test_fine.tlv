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
   
   //Decoding Type of Instruction
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_i_instr = $instr[6:2] ==  5'b0000x || $instr[6:2] == 5'b001x0 || $instr[6:2] == 5'b11001;
   $is_r_instr = $instr[6:2] ==  5'b01011 || $instr[6:2] == 5'b01100 || $instr[6:2] == 5'b10100;
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   $is_b_instr = $instr[6:2] == 5'b11000;
   $is_j_instr = $instr[6:2] == 5'b11011;
   `BOGUS_USE($is_u_instr $is_i_instr $is_r_instr $is_s_instr $is_b_instr $is_j_instr);
   
   //Decode Logic Extraction of Fields.
   //Source Register 2
   $rs2[4:0]    = $instr[24:20];
   //The Surce Register 2 is valid only for R, S and B type Instructions.
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   //Source Register 1
   $rs1[4:0]     = $instr[19:15];
   $rs1_valid    = $is_r_instr || $is_s_instr || $is_i_instr;
   $funct3[2:0]  = $instr[14:12];
   $funct3_valid = $is_r_instr || $is_s_instr || $is_i_instr;
   $funct7[6:0]  = $instr[31:25];
   $funct7_valid = $is_r_instr;
   //Destination Register
   $rd[4:0]      = $instr[11:7];
   $rd_valid     = $is_u_instr || $is_i_instr || $is_r_instr;
   //Opcode
   $opcode[6:0]  = $instr[6:0];
   //Immediate Lets use like 32bit. Sign Extension. Repeat last bit
   $imm_valid = $is_i_instr || $is_s_instr || $is_b_instr || $is_u_instr || $is_j_instr;
   $imm[31:0] =
     $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
     $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
     $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
     $is_u_instr ? { $instr[31:12], 12'b0 } :
     $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0 } :
                   32'b0;
   `BOGUS_USE($rs2 $rs2_valid $rs1 $rs1_valid $funct3 $funct3_valid $funct7 $funct7_valid $rd $rd_valid $opcode $imm_valid $imm);
   
   //Instruction Decode Table
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
   $is_lb    = $dec_bits ==? 11'bx_000_0000011;
   $is_lh    = $dec_bits ==? 11'bx_001_0000011;
   $is_lw    = $dec_bits ==? 11'bx_010_0000011;
   $is_lbu   = $dec_bits ==? 11'bx_100_0000011;
   $is_lhu   = $dec_bits ==? 11'bx_101_0000011;
   $is_sb    = $dec_bits ==? 11'bx_000_0000011;
   $is_sh    = $dec_bits ==? 11'bx_001_0000011;
   $is_sw    = $dec_bits ==? 11'bx_010_0000011;
   $is_load  = $opcode[6:0] ==? 7'b0000011;
   `BOGUS_USE($is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_addi $is_add $is_lui $is_auipc $is_jal $is_jalr $is_slti $is_sltiu $is_xori $is_ori $is_andi $is_slli $is_srli $is_srai $is_sub $is_sll $is_slt $is_sltu $is_xor $is_srl $is_sra $is_or $is_and $is_load $is_lb $is_lh $is_lw $is_lbu $is_lhu $is_sb $is_sh $is_sw)
   
   //Register File Read
   //m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rd_en1, $rd_index1[4:0], $rd_data1, $rd_en2, $rd_index2[4:0], $rd_data2)
   m4+rf(32, 32, $reset, $rd_valid, $rd[4:0], $result[31:0], $rs1_valid, $rs1, $src1_value, $rs2_valid, $rs2, $src2_value)
   `BOGUS_USE($reset $rd_valid $rd $result $rs1_valid $rs1 $src1_value $rs2_valid $rs2 $src2_value)
   
   $sltu_rslt[31:0]  = {31'b0, $src1_value < $src2_value};
   $sltui_rslt[31:0] = {31'b0, $src1_value < $imm};
   $sext_src1[63:0]  = {{32{$src1_value[31]}}, $src1_value};
   $sra_rslt[63:0]   = $sext_src1 >> $src2_value[4:0];
   $srai_rslt[63:0]  = $sext_src1 >> $imm[4:0];
   
   //ALU Basic Computation
   $result[31:0] =
      $is_addi  ? ($src1_value + $imm) :
      $is_add   ? ($src1_value + $src2_value) :
      $is_xori  ? ($src1_value ^ $imm) :
      $is_xor   ? ($src1_value ^ $src2_value) :
      $is_sub   ? ($src1_value - $src2_value) :
      $is_or    ? ($src1_value | $src2_value) :
      $is_and   ? ($src1_value & $src2_value) :
      $is_ori   ? ($src1_value | $imm) :
      $is_andi  ? ($src1_value & $imm) :
      $is_slt   ? (($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0, $src1_value[31]}) :
      $is_slti  ? (($src1_value[31] == $imm[31]) ? $sltiu_rslt : {31'b0, $src1_value[31]}) :
      $is_sltiu ? ($src1_value < $imm) :
      $is_slli  ? ($src1_value << $imm[5:0]) :
      $is_sll   ? ($src1_value << $src2_value) :
      $is_srli  ? ($src1_value >> $imm[5:0]) :
      $is_srl   ? ($src1_value >> $src2_value) :
      $is_srai  ? $srai_rslt[31:0] :
      $is_sra   ? $sra_rslt[31:0] :
      $is_lui   ? {$imm[31:12], 12'b0} :
      $is_auipc ? $imm + $pc[31:0] :
      $is_sltu  ? $sltu_rslt :
      $is_sltiu ? $sltiu_rslt :
      $is_jal   ? $pc + 32'd4 :
      $is_jalr  ? $pc + 32'd4 :
      32'b0;
   `BOGUS_USE($is_addi $is_add $is_xori $is_xor $is_sub $is_or $is_and $is_ori $is_andi $is_slt $is_slti $is_sltiu $is_slli  $is_sll $is_srli $is_srl $is_srai $is_sra $is_lui $is_auipc)
   
   $taken_br =
      $is_beq  ? ($src1_value == $src2_value) :
      $is_bne  ? ($src1_value != $src2_value) :
      $is_blt  ? ($src1_value < $src2_value)  ^ ($src1_value[31] != $src2_value[31]) :
      $is_bge  ? ($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31]) :
      $is_bltu ? ($src1_value < $src2_value)  :
      $is_bgeu ? ($src1_value >= $src2_value) : 1'b0;
   `BOGUS_USE($taken_br $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu)
   
   $br_tgt_pc[31:0] = $pc[31:0] + $imm[31:0];
   $jalr_tgt_pc[31:0] = $src1_value + $imm;
   `BOGUS_USE($br_tgt_pc $pc $imm);
   
   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *passed = *cyc_cnt > 800;
   //*passed = 1'b0;
   *failed = 1'b0;
   //Instruction Memory Basically stores the Instruction. Assumed store it at ADDR index PC 
\SV
   endmodule
