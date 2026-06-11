// Code your design here
module natural_numbers (
  input[1:0] N_in,
  input clk,
  input N_valid,
  input reset, 
  input ack_signal, 
  output reg[4:0] sum,
  output reg Sum_valid); 
  
  
  wire [2:0] i_mux_out; 
  wire [3:1] sum_mux_out; 
  wire [3:0] add_out; 
  wire [2:0] N_mux_out; 
  wire i_eq_N_state; 
  wire i_eq_N; 
  reg [1:0] i; 
  reg [2:0] state, nextstate; 
  reg [1:0] N_reg; 
  
 

parameter IDLE = 2'b00; 
parameter BUSY = 2'b01; 
parameter DONE = 2'b11; 
  
  assign i_mux_out = (state == IDLE) ? 1 : i+1; 
  
  assign sum_mux_out = ( state == IDLE ) ? 0: 
    (state == BUSY) ? add_out:
    (state == DONE) ? sum: 
    2'b10; 
  
  assign N_mux_out = (state == IDLE) ? N_in : N_reg; 
  
  assign add_out = i + sum; 
  
  assign i_eq_N = (N_reg == i); 
  
   
  always @(posedge clk or posedge reset) 
    if (reset)
      begin 
      sum <= 0;  
      i <= 0; 
      N_reg <= 0; 
    end 
    else 
      begin
      
         N_reg <= N_mux_out; 
         sum <= sum_mux_out; 
         i <= i_mux_out;  
    end   

  always @(*) 
    begin 
      case (state) 
        
        IDLE : if (N_valid) nextstate = BUSY; else nextstate = IDLE; 
        BUSY : if (i_eq_N) nextstate = DONE; else nextstate = BUSY; 
        DONE : if (ack_signal) nextstate = IDLE;  
        
      endcase 
    end 
  
  always @(posedge clk) 
    if (reset) 
      state <= IDLE; 
  else 
    state <= nextstate; 
  
 assign Sum_valid = (state == DONE); 
  
endmodule 



// Test Bench 

// Code your testbench here
// or browse Examples
module natural_number_tb();
  
  reg [1:0] N_in;
  reg clk; 
  reg reset;
  reg N_valid;
  reg ack_signal; 
  wire [4:0] sum;
  wire Sum_valid; 
  
  natural_numbers natural_numbers1( .N_in(N_in), .clk(clk), .reset(reset), .N_valid(N_valid), .sum(sum), .Sum_valid(Sum_valid), .ack_signal(ack_signal)); 
  
  always #5 clk = ~clk; 
  
  initial begin 
    clk = 0; 
    reset = 1; 
    N_valid = 0; 
    N_in = 0; 
    #10 
    
    reset = 0; 
    N_in = 3; 
    N_valid = 1; 
    ack_signal = 0;
   
    #10 
    ack_signal = 0; 
    N_valid = 0; 
    N_in = 7; 
    #50  
    ack_signal = 1; 
    #5
    ack_signal = 0; 
    #200
    $finish; 
  end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, natural_number_tb);
   end 
  
endmodule 
  
