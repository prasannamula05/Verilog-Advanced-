module RCA_nbit #(parameter n = 8) (A_n, B_n, Cin, Cout, S_n); 
  input wire [n-1:0] A_n, B_n; 
  input wire Cin; 
  output wire Cout; 
  output wire [n-1:0] S_n; 
  
  wire [n:0] C; 
  
  assign C[0] = Cin; 
  
  genvar i; 
  generate 
    for (i = 0; i < n; i = i + 1) begin: make_fadders
      FullAdder fa(.FA_A(A_n[i]), .FA_B(B_n[i]), .Cin(C[i]), .FA_S(S_n[i]), .Cout(C[i+1])); 
    end 
  endgenerate 
  
  assign Cout = C[n]; 
  
endmodule 

module HalfAdder(A, B, Cout, S); 
  input A, B; 
  output Cout, S; 
  
  assign S = A^B; 
  assign Cout = A&B; 
  
endmodule 

module FullAdder(FA_A, FA_B, Cin, FA_S, Cout); 
  input FA_A, FA_B; 
  input Cin; 
  output FA_S, Cout; 
  
  wire ha0_S, ha0_C, ha1_C; 
  
  HalfAdder ha0(.A(FA_A), .B(FA_B), .Cout(ha0_C), .S(ha0_S)); 
  
  HalfAdder ha1(.A(Cin), .B(ha0_S), .Cout(ha1_C), .S(FA_S)); 
  
  assign Cout = ha0_C | ha1_C; 
  
endmodule 

// Test Bench 

module tb_RCA_nbit; 
  
  
  parameter n = 64; 
  reg [n-1:0] A, B; 
  reg Cin; 
  wire [n-1:0] Sum; 
  wire Cout_tb; 
  
  RCA_nbit #(n) RCA_nbit1 (.A_n(A), .B_n(B), .Cin(Cin), .Cout(Cout_tb), .S_n(Sum)); 
  
  initial begin 
    
    $dumpfile("RCA_nbit.vcd");
    $dumpvars(0, tb_RCA_nbit);
    
    
    $monitor("Time = %0t | A = %b (%0d) B = %b (%0d) Cin = %b => Sum = %b (%0d) Cout_tb= %b", $time, A, A, B, B, Cin, Sum, Sum, Cout_tb); 
    
    // Test Cases 
    
    A = 0; 
    B = 0; 
    Cin = 0; 
    #50;  
    
    A = 8'h05; 
    B = 8'h03; 
    Cin = 0; 
    #50; 
    
    A = 8'h06; 
    B = 8'h07; 
    Cin = 1; 
    #200;
    
    A = {n{1'b1}}; 
    B = {n{1'b1}}; 
    Cin = 1;
    #100; 
    
    $finish; 
  end 
  
endmodule 
  
  
      
