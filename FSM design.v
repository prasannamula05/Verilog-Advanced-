module fsm_design (input in, clk, output out); 
  wire D0, D1, D2; 
   reg Q0, Q1, Q2; 
  
   assign D0 = (~Q2)&(~Q0)&(in); 
  assign D1 = (~Q0)&(in)&(~Q2)&(Q1) | (~Q2)&(~Q1)&(Q0)&(in); 
  assign D2 = (Q0)&(in)&(~Q2)&(Q1) | (Q2)&(~Q1)&(~Q0)&(in); 
  assign out = Q2;
  
  always @(posedge clk) 
    begin 
      Q0<= D0; 
      Q1<= D1; 
      Q2<= D2; 
    end 
endmodule 

// Test Bench 
module fsm_design_tb(); 
  reg in, clk; 
  wire out; 
  
  always #5 clk = ~clk; 
  
  
  fsm_design fsm_design1(.in(in), .clk(clk), .out(out)); 
  
  initial begin 
    clk = 0; 
    in = 0; 
    #10 
    in = 1; 
    #10
    in = 0; 
    #10
    in = 1; 
    #10
    in = 1; 
    #1000
    $finish; 
    end 
  
    
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule 
    
    
