module fsmabs_design (input clk, x, reset, output detect); 
  reg [2:0] state, nextstate; 
  
  parameter S0 =  3'b000;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b011;
  parameter S4 = 3'b100;
  
  always @(posedge clk)
  if (reset) state <=S0; 
  else state <= nextstate; 
  
  always @(*)
    case(state)
      S0: if (x) nextstate = S1; else nextstate = S0; 
      S1: if (x) nextstate = S2; else nextstate = S0; 
      S2: if (x) nextstate = S3; else nextstate = S0; 
      S3: if (x) nextstate = S4; else nextstate = S0; 
      S4: if (x) nextstate = S4; else nextstate = S0; 
    endcase 
  
  assign detect = (state == S4);
endmodule   
    
  // Test Bench 

module fsm_design_tb(); 
  reg  x, clk, reset; 
  wire detect; 
  
  always #5 clk = ~clk; 
  
  
  fsmabs_design fsmabs_design1( .x(x), .reset(reset), .clk(clk), .detect(detect)); 
  
  initial begin 
    clk = 0; 
    reset = 0; x = 0;
    #10 
    reset = 1; x = 1;
    #10
    reset = 0; x = 0;
    #10
    reset = 1; x = 1;
    #10
    reset = 1; x = 1; 
    #1000
    $finish; 
    end 
  
    
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule 
    
    
    
    
    
