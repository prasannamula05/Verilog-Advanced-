module counter_mod (input clk, reset, mode, output [3:0] count); 
  
  reg [3:0] count; 
  wire [3:0] D_count;
  
  assign D_count = reset ? 0 : (mode ? count - 1 : count +1); 
  
  always @(posedge clk)
    count <= D_count; 
  
endmodule 

// TEST BENCH 

module countermod_tb(); 
  
  reg clk, reset, mode; 
  wire [3:0] count; 
  
  always #5 clk = ~clk; 
  
  counter_mod counter_mod1(.clk(clk), .reset(reset), .mode(mode), .count(count)); 
  
  initial begin 
    clk = 0; 
    reset = 0; mode = 0; 
    #10
    reset = 1; mode = 1; 
    #500
    reset = 0; mode = 0; 
    #1000
    $finish; 
  end 
  
   
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule
  
  
