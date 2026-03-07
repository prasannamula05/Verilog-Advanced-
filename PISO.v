module serial_adder (
  input[3:0] A_in,
  input[3:0] B_in,
  input load,
  input clk,
  input reset,
  output reg [3:0] S,
  output reg Cout); 
 
  
  reg [3:0] shift_reg_A;
  reg [3:0] shift_reg_B; 
  
  reg Carry;
  
  wire A_bit = shift_reg_A[0];
  wire B_bit = shift_reg_B[0]; 
  
 
  assign S = A_bit^B_bit^Carry; 
  wire carry_next = (A_bit&B_bit)|(B_bit&Carry)|(Carry&A_bit); 
  
  assign Cout = Carry; 
  
  always @(posedge clk or posedge reset) begin 
    if (reset) begin 
      shift_reg_A <= 4'b0; 
      shift_reg_B <= 4'b0; 
      Carry <= 1'b0; 
      end 
    else if (load) begin 
      shift_reg_A <= A_in; 
      shift_reg_B <= B_in; 
      Carry <= 1'b0; 
    end 
    else begin 
      shift_reg_A <= shift_reg_A >> 1; 
      shift_reg_B <= shift_reg_B >> 1; 
      Carry <= carry_next; 
    end 
  end 
  
endmodule
      
  // TEST BENCH 

module serial_adder_tb();
    reg clk, reset, load;
    reg [3:0] A_in, B_in;
    wire S, Cout;
    
    serial_adder serial_adder1 (
        .clk(clk),
      .reset(reset),
        .load(load),
        .A_in(A_in),
        .B_in(B_in),
      .S(S),
      .Cout(Cout)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        load = 0;
        #10 
        reset = 0;
        A_in = 4'b0101; 
        B_in = 4'b0011;
        #10 
        load = 1;
        #10 
        load = 0;
        #100;
        
        $finish;
      
    end 
  
   initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0);
   end 
  
endmodule 
      
      
      
