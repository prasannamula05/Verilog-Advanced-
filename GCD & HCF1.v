// Code your design here
module top_algo (
  input [3:0] A, 
  input [3:0] B, 
  input op_valid, clk, reset, ack_sum_signal,  
  output [4:0] sum,
  output sum_valid
); 
  wire [1:0] gcd_N; 
  wire gcd_valid; 
  reg gcd_ack;
  reg [1:0] A_reg, B_reg;

  gcd_number gcd_number1 ( 
    .A(A), .B(B), .op_valid(op_valid), .clk(clk), .reset(reset), .gcd_ack(gcd_ack), 
    .A_reg(A_reg), .B_reg(B_reg), .gcd_valid(gcd_valid), .gcd(gcd_N)
  ); 
    
  sum_numbers sum_numbers1 ( 
    .N_in(gcd_N), .clk(clk), .reset(reset), .N_valid(gcd_valid), 
    .ack_sum_signal(ack_sum_signal), .sum(sum), .sum_valid(sum_valid), gcd_ack(gcd_ack)
  ); 
endmodule 
  
module gcd_number (
  input [3:0] A,
  input [3:0] B,
  input op_valid,
  input clk,
  input reset,
  input gcd_ack,
  output [1:0] A_reg,
  output [1:0] B_reg,
  output gcd_valid,
  output [1:0] gcd
);
  wire [1:0] A_sel; 
  wire B_sel, A_en, B_en; 
  wire B_eq_0, A_cmp_B;  
    
  gcd_datapath gcd_d1(
    .A(A), .B(B), .clk(clk), .reset(reset), .A_sel(A_sel), .B_sel(B_sel), 
    .B_en(B_en), .A_en(A_en), .A_reg(A_reg), .B_reg(B_reg), .B_eq_0(B_eq_0), .A_cmp_B(A_cmp_B), .gcd(gcd)
  ); 
    
  gcd_controlpath gcd_c1(
    .op_valid(op_valid), .B_eq_0(B_eq_0), .A_cmp_B(A_cmp_B), 
    .clk(clk), .reset(reset), .A_sel(A_sel), .B_sel(B_sel), 
    .B_en(B_en), .A_en(A_en), .gcd_valid(gcd_valid), .gcd_ack(gcd_ack)
  ); 
endmodule 

module sum_numbers ( 
  input [1:0] N_in, 
  input clk, 
  input reset, 
  input N_valid, 
  input ack_sum_signal, 
  output [4:0] sum, 
  output sum_valid
); 
  wire [2:0] state;
  wire [1:0] i;
  wire [3:0] add_out;
  wire i_eq_1;

  sum_datapath sum_d1 (
    .clk(clk), .reset(reset), .N_in(N_in), .i_eq_1(i_eq_1), .state(state), 
    .i(i), .add_out(add_out), .sum(sum)
  ); 
  
  sum_controlpath sum_c1 (
    .N_valid(N_valid), .clk(clk), .reset(reset), .sum_valid(sum_valid), 
    .state(state), .i_eq_1(i_eq_1), .ack_sum_signal(ack_sum_signal), .gcd_ack(gcd_ack)
  );
endmodule 

module gcd_datapath(
  input [3:0] A, 
  input [3:0] B, 
  input clk, reset, 
  input [1:0] A_sel, 
  input B_sel, B_en, A_en, 
  output reg [1:0] A_reg,
  output reg [1:0] B_reg,
  output A_cmp_B, 
  output B_eq_0,
  output [1:0] gcd
); 
  wire [1:0] Sub_out = A_reg - B_reg;
  wire [1:0] A_mux_nxt = (A_sel == 2'b00) ? A :
                         (A_sel == 2'b01) ? B_reg :
                         (A_sel == 2'b10) ? Sub_out : 2'b11;

  wire [1:0] B_mux_nxt = (B_sel) ? B : A_reg;

  assign A_cmp_B = (A_reg < B_reg); 
  assign B_eq_0 = (B_reg == 0); 
  assign gcd = A_reg;

  always @(posedge clk or posedge reset) begin 
    if (reset) begin
      A_reg <= 2'b00; 
      B_reg <= 2'b00; 
    end else begin 
      if (A_en) A_reg <= A_mux_nxt; 
      if (B_en) B_reg <= B_mux_nxt; 
    end 
  end 
endmodule 

module gcd_controlpath ( 
  input clk,
  input reset, 
  input op_valid, 
  input gcd_ack, 
  input B_eq_0, 
  input A_cmp_B, 
  output reg [1:0] A_sel, 
  output reg B_sel, 
  output reg A_en, 
  output reg B_en, 
  output reg gcd_valid
); 
  reg [1:0] state, nextstate;
  parameter IDLE = 2'b00; 
  parameter BUSY = 2'b01; 
  parameter DONE = 2'b10; 

  always @(*) begin 
    case (state)
      IDLE : if (op_valid) nextstate = BUSY; else nextstate = IDLE; 
      BUSY : if (B_eq_0) nextstate = DONE; else nextstate = BUSY; 
      DONE : if (gcd_ack) nextstate = IDLE; else nextstate = DONE; 
      default : nextstate = IDLE;
    endcase 
  end 

  always @(posedge clk or posedge reset) begin 
    if (reset)
      state <= IDLE; 
    else 
      state <= nextstate; 
  end 

  always @(*) begin 
    A_sel = 2'b00; 
    B_sel = 1'b0; 
    A_en = 1'b0; 
    B_en = 1'b0; 
    gcd_valid = 1'b0; 
    case (state) 
      IDLE: begin
        if (op_valid) begin
        A_sel = 2'b00;
        B_sel = 1'b1; 
        A_en = 1'b1; 
        B_en = 1'b1; 
        end 
      end 
      BUSY: begin 
        if (A_cmp_B) begin
          A_sel = 2'b01; 
          B_sel = 1'b0; 
          A_en = 1'b1; 
          B_en = 1'b1;
        end else begin
          A_sel = 2'b10; 
          A_en = 1'b1; 
          B_en = 1'b0;
        end
      end 
      DONE: begin
        gcd_valid = 1'b1; 
      end 
    endcase 
  end 
endmodule 

module sum_datapath (
  input clk, 
  input reset, 
  input [1:0] N_in, 
  input [2:0] state, 
  output reg [4:0] sum,
  output reg [1:0] i,
  output wire [3:0] add_out,
  output wire i_eq_1
);
  wire [1:0] i_mux_out; 
  wire [3:1] sum_mux_out; 

  assign i_mux_out = (state == 2'b00) ? N_in : i - 1; 
  assign sum_mux_out = (state == 2'b00) ? 0 : 
                           (state == 2'b01) ? add_out : 
                           (state == 2'b11) ? sum : 5'b00010;
  
  assign add_out = i + sum; 
  assign i_eq_1 = (i == 1);

  always @(posedge clk or posedge reset) begin
    if (reset) begin 
      sum <= 0;  
      i <= 0; 
    end else begin
      sum <= sum_mux_out; 
      i <= i_mux_out;     
    end  
  end 
endmodule 

module sum_controlpath ( 
  input N_valid, 
  input clk, 
  input reset, 
  input ack_sum_signal, 
  input i_eq_1, 
  output reg [2:0] state,
  output wire sum_valid
  output reg gcd_ack
);
  reg [2:0] nextstate;
  parameter IDLE = 3'b000; 
  parameter BUSY = 3'b001; 
  parameter DONE = 3'b011; 
always @(*) begin 
    gcd_ack = 1'b0; 
    case (state)   
      IDLE : if (N_valid) nextstate = BUSY; else nextstate = IDLE; 
      BUSY : if (i_eq_1) nextstate = DONE; else nextstate = BUSY; 
      DONE : begin
        if (ack_sum_signal) begin
          nextstate = IDLE;
          gcd_ack = 1'b1; 
        end else begin
          nextstate = DONE;
        end
      end
      default: nextstate = IDLE;
    endcase 
  end  
  
  always @(posedge clk or posedge reset) begin
    if (reset) 
      state <= IDLE; 
    else 
      state <= nextstate; 
  end 
  
  assign sum_valid = (state == DONE); 
endmodule 


// TEST BENCH 

// Code your testbench here
// or browse Examples
module top_algo_tb(); 
  
  reg [3:0] A;
  reg [3:0] B;
  reg op_valid; 
  reg clk; 
  reg reset; 
  reg ack_sum_signal; 
  wire [4:0] sum; 
  wire sum_valid; 
  
  always #5 clk = ~clk; 
  
  top_algo top_algo1 (.A(A), .B(B), .op_valid(op_valid), .clk(clk), .reset(reset), .ack_sum_signal(ack_sum_signal), .sum(sum), .sum_valid(sum_valid)); 
  
  initial begin 
    clk = 0; 
    reset = 1; 
    op_valid = 0; 
    ack_sum_signal = 0; 
    A = 0; 
    B = 0; 
    #10 
    reset = 0; 
    A = 4'b1100; 
    B = 4'b1000; 
    op_valid = 1; 
    #30
    op_valid = 0; 
    ack_sum_signal = 1; 
    #10
    ack_sum_signal = 0; 
    #100
    $finish; 
  end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, top_algo_tb);
   end 
  
endmodule 
    
