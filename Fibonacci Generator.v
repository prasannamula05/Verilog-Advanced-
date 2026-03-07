module fibo_gen (input clk, reset, output [3:0] fibo_out); 
  
  wire [3:0] add_out, reg0_in, reg1_in; 
  reg [3:0] reg0, fibo_out; 
  
  add_4bit add_4bit0(.A(fibo_out), .B(reg0),.S(add_out)); 
  assign reg0_in = reset ? 1 : add_out; 
  assign reg1_in = reset ? 0 : reg0; 
  reg_4bit reg_4bit0(.clk(clk), .D(reg0_in), .Q(reg0)); 
  reg_4bit reg_4bit1(.clk(clk), .D(reg1_in), .Q(fibo_out)); 
  
  /*always @(posedge clk) 
    begin 
      reg0 <= reg0_in;
      fibo_out <= reg1_in; 
    end 
endmodule */ 
endmodule 

module add_4bit(input [3:0] A, B, Cin, output [4:0] S ); 
    wire C1, C2, C3 ;
    
    full_add fa0 (.a(A[0]), .b(B[0]), .Cin(0), .sum(S[0]), .Cout(C1));
  full_add fa1 (.a(A[1]), .b(B[1]), .Cin(C1), .sum(S[1]), .Cout(C2));
  full_add fa2 ( .a(A[2]), .b(B[2]), .Cin(C2), .sum(S[2]), .Cout(C3)); 
  full_add fa3 (.a(A[3]), .b(B[3]), .Cin(C3), .sum(S[3])); 
  
endmodule 

module full_add (input a, b, Cin, output sum, Cout); 
  
  assign sum = a^b^Cin; 
  assign Cout = (a|b) + (b|Cin) + (Cin|a); 
  
endmodule 

module reg_4bit(input clk, input [3:0] D, output reg [3:0] Q); 
  
  always @(posedge clk) 
    Q <= D; 
  
endmodule 
  
  
  // TEST BENCH 

module fibo_tb(); 
  
  reg clk, reset; 
  wire [3:0] fibo_out; 
  
  always #5 clk = ~clk; 
  
 fibo_gen fibo_gen1(.clk(clk), .reset(reset), .fibo_out(fibo_out)); 
  
  
  
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
  
