module meal_levelpulse ( input in, clk, reset, output out);

  reg state, nextstate;

  parameter S0 = 1'b0;
  parameter S1 = 1'b1;

  
  always @(posedge clk) begin
    if (reset)
      state <= S0;
    else
      state <= nextstate;
  end

  always @(*) begin
    case (state)
      S0 : if (in == 1) nextstate = S1; else nextstate = S0; 
      S1 : if (in == 0) nextstate = S1; else nextstate = S0; 
      default: nextstate = S0;
    endcase
  end

  assign out = (state == S1 ); 

endmodule

// Test Bench 

module mealypulse_tb(); 
  
  reg clk, in, reset; 
  wire out; 
  
  always #5 clk  = ~clk; 
  
  meal_levelpulse meal_levelpulse1 ( .clk(clk), .in(in), .reset(reset), .out(out)); 
  
  initial begin 
    clk = 0; 
    reset = 1; in = 0; 
    #10
     reset = 0; in = 1; 
    #20
     in = 0; 
    #10
    in = 1;
    #20 
    in = 1; 
    #100
    $finish; 
    end 
  
    
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule 
    
