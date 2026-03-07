module counter (input reset, clk, output [3:0] count); 
  
  wire [3:0] D_count; 
  reg [3:0] count; 
  
  assign D_count = reset ? 0 : count+1; 
  
  always @ (posedge clk) 
    count <= D_count; 
endmodule 

// TEST BENCH 
module counter_tb(); 
  
  reg clk, reset; 
  wire [3:0] count; 
  
  always #5 clk = ~clk; 
  
  counter counter1(.clk(clk), .reset(reset), .count(count)); 
  
  initial begin 
    clk = 0; 
    reset = 0; 
    #10 
    reset = 1; 
    #10
    reset = 0; 
    #1000
    	$finish; 
    end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule
  
  
  
    
