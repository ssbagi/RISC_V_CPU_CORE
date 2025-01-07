// I had made syntax was not know for instantion of the module but I know now.

\m5
   use(m5-1.0)   // Again, not actually used here, but generally useful.

//----------------------------
// Our Library
// A TLV macro definition, in this case, a Fibonacci sequence generator.

\TLV fib()
   $val[31:0] = ($reset || ! $run) ? 1 : >>1$val + >>2$val;


//----------------------------
// Self-testing testbench for this library for use in Makerchip.

\SV
   // Declare the Verilog module interface by which Makerchip and the testbench control simulation (using macro).
   m5_makerchip_module   // Compile within Makerchip to see expanded module definition.

// The testbench to provide stimulus and checking.
\TLV
   // Stimulus (drive inputs).
   $reset = *reset;
   $run = 1'b1;
   // Instantiate the DUT
   m5+fib()
   // Check outputs.
   *passed = *cyc_cnt == 20 && $val == 32'h452f; // Test for expected output after 20 cycles.
   *failed = *cyc_cnt > 40;                      // Or fail after 40.

\SV
   endmodule