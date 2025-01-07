/*
Creation of Basic SRAM whihc has addr and dout. Based on address returns some dout value. 
*/

module memory_block(clk, addr, dout); 
  input bit clk;
  reg [31:0][31:0] mem; //unpacked 32. Each 32bit by default.
	input logic [31:0] addr;
	output logic [31:0] dout;
	
	//Creating Memory. With some value
	always @(posedge clk)
      begin
         for(int i=0;i<64;i++)
            mem[i] = $urandom_range(i,i*5);
        	#5;
      end
	
	//Generate some random address as index for memory.
	assign dout = mem[addr];   

endmodule

//Testbench
// Code your testbench here
// or browse Examples
module tb();
  bit clk;
  logic[31:0] addr; 
  logic[31:0] dout;
  memory_block GA1 (clk, addr, dout);
  
  initial
    clk = 0;
   
  always #5 clk = ~clk;
  
  initial
    begin
      for(int i=0; i<32; i++)
        begin
          addr = i;
          #5;
          $display($time,"\tADDR :: %d DOUT :: %d", addr, dout);
        end
    end
  
  initial
    begin
      #100 $stop;
    end
  
    initial
    begin
      $dumpvars();
      $dumpfile("dump.vcd");
    end
  
endmodule




