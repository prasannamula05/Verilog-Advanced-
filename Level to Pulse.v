module level_pulse (input clk, x, reset, output reg detect); 
  reg [1:0] state, nextstate; 
  
  parameter S0 = 2'b00; 
  parameter S1 = 2'b01; 
  parameter S2 = 2'b11; 
  
  always @(posedge clk) 
    if (reset) 
      state <= S0; 
  else 
    state <= nextstate; 
  
  always @(*) begin 
    case(state) 
      
      S0 : if (x) nextstate = S1; else nextstate = S0; 
      S1 : if (x) nextstate = S2; else nextstate = S0; 
      S2 : if (x) nextstate = S2; else nextstate = S0; 
      
    endcase
  end 
  
  assign detect = (state == S1); 
  
 
endmodule 
  
  // Test Bench 
module levelpulse_tb(); 
  
  reg clk, x, reset; 
  wire detect; 
  
  always #5 clk  = ~clk; 
  
  level_pulse level_pulse1 ( .clk(clk), .x(x), .reset(reset), .detect(detect)); 
  
  initial begin 
    clk = 0; 
    reset = 1; x = 0; 
    #15
    reset = 0; x = 1; 
    #30 
     x = 0; 
    #50
    $finish; 
    end 
  
    
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule 
    
