module shift_reg (input in, clk, output reg out);
  reg Q0, Q1, Q2, out; 
  
  always @(posedge clk) 
    begin 
      Q0 <= in; 
      Q1 <= Q0; 
      Q2 <= Q1; 
      out <= Q2; 
    end 
endmodule 

// TEST BENCH 
module shift_tb(); 
  
  reg clk, in; 
  wire out; 
  
  always #5 clk = ~clk; 
  
  shift_reg shift_reg1(.clk(clk), .in(in), .out(out)); 
  
  initial begin 
    
    clk = 0; 
    in = 0;
    #10 
    in = 1; 
    #10
    in = 0; 
    #1000
     $finish;
  end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule
    
