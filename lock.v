module lock(clk, x, reset, out); 
  
  input clk, x, reset; 
  output out; 
  reg [2:0] state, nextstate; 
  
  
  parameter RESET = 3'b000;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b011;
  parameter S4 = 3'b100;
  parameter S5 = 3'b101;
  
  always @(posedge clk) 
    if (reset) 
      state <= RESET; 
  else 
    state <= nextstate; 
  
  always @(*) begin 
    case (state) 
      RESET: if (x) nextstate = S1; else nextstate = RESET; 
      S1: if (x) nextstate = S2 ; else nextstate = S1; 
      S2: if (x) nextstate = S3 ; else nextstate = RESET; 
      S3: if (x) nextstate = S4 ; else nextstate = S1; 
      S4: if (x) nextstate = S5 ; else nextstate = S3; 
      S5: if (x) nextstate = RESET ; else nextstate = S1; 
      default: nextstate = RESET;
    endcase 
  end 
  
  
  assign out = (nextstate == S5);
 
  
endmodule   


// TEST Bench 

module lock_tb(); 
  
  reg clk, x, reset; 
  wire out; 
  
  lock lock1(.clk(clk), .reset(reset), .x(x), .out(out)); 
  
  always #5 clk = ~clk; 
  
  initial begin
    clk = 0; 
    reset = 1; 
    #10
    x = 0; 
    #20
    reset = 0; 
    #10
    x = 1; 
    #100
    $finish; 
  end 
           
   initial begin
    $dumpfile("dump.vcd"); 
     $dumpvars(0, lock_tb);
   end 
  
endmodule 
  
    
