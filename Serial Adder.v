module serial_adder ( x, reset, clk, S, Cout); 
  input x, clk, reset; 
  reg[3:0] A; 
  reg[3:0] B; 
  output reg [3:0] S; 
  output reg Cout; 
  reg Cin; 
  reg [2:0] count; 
  reg [3:0] A_reg, B_reg; 
  
  wire sum_bit, carry_bit; 
  
  reg [1:0] state, nextstate; 
  
  assign sum_bit = A_reg[0]^B_reg[0]^Cin; 
  assign carry_bit = (A_reg[0]&B_reg[0])|(B_reg[0]&Cin)|(Cin&A_reg[0]); 
  
  parameter S0 = 2'b00; 
  parameter S1 = 2'B01; 
  parameter S2 = 2'b10; 
  parameter S3 = 2'b11; 
  
  always @(posedge clk or posedge reset) begin
  if (reset) begin
    state <= S0;
    count <= 0;
    Cout <= 0;
    S <= 0;
  end else 
    state <= nextstate;
end
  
  always @(*) 
    begin 
      case (state) 
        S0 : if (x) nextstate = S1; else nextstate = S0; 
        S1 : if (x) nextstate = S2; 
        S2 : if (count == 4) nextstate = S3; else nextstate = S2; 
        S3 : if (x) nextstate = S0;
        default : nextstate = S0; 
      endcase 
    end 
  
  always @(posedge clk or posedge reset) begin
  if (reset) begin
    A_reg <= 4'b1011;  
    B_reg <= 4'b0110;  
    Cin <= 0;
    count <= 0;
    S <= 0;
    Cout <= 0;
  end else begin
    case (state)
      S1: begin
        A_reg <= 4'b1011; // or load through input
        B_reg <= 4'b0110;
        Cin <= 0;
        S <= 0;
        count <= 0;
      end
      S2: begin
        S[count] <= sum_bit;
        Cin <= carry_bit;
        A_reg <= A_reg >> 1;
        B_reg <= B_reg >> 1;
        count <= count + 1;
      end
      S3: begin
        Cout <= carry_bit;
      end
    endcase
  end
end
      
endmodule 


// TEST BENCH 

module serialadder_tb();
  
  reg x, reset, clk; 
  wire [3:0] S; 
  wire Cout; 
  
  always #5 clk = ~clk; 
  
  serial_adder serial_adder1(.x(x), .reset(reset), .clk(clk), .Cout(Cout), .S(S)); 
  
  initial begin 
    
    clk = 0; 
    reset = 1; x = 0; 
    #10
    x = 1; 
    #10; 
    reset = 0; 
    #10
    x = 1; 
    #10 
    x = 0; 
    #100
    $finish;
    end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, serialadder_tb);
   end 
  
endmodule 
  
    
