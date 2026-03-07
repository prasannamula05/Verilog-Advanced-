module gcd_numbers (
  input [5:0] A_in,
  input [5:0] B_in,
  input op_valid,
  input clk,
  input reset, 
  input gcd_ack,  
  output reg [5:0] A_out, 
  output reg [5:0] B_out, 
  output reg gcd_valid,
  output reg [5:0] gcd_result
); 

  wire [5:0] A_mux_nxt;
  wire [5:0] B_mux_nxt; 
  reg [1:0] A_sel; 
  reg B_sel, B_en, A_en; 
  wire B_eq_0; 
  wire A_cmp_B; 
  wire [5:0] sub_out; 
  reg [1:0] state, nextstate; 
  
  //Changes 
 // reg do_swap;
  
  parameter WAIT = 2'b00; 
  parameter BUSY = 2'b01; 
  parameter DONE = 2'b10; 
  
  assign A_mux_nxt = (A_sel == 2'b00) ? A_in : 
    (A_sel == 2'b01) ? B_out : 
    (A_sel == 2'b10) ? A_out - B_out : 
    6'b000000; 
  
  assign B_mux_nxt = (B_sel) ? B_in : A_out;
  
  assign sub_out = A_out - B_out;
  
  assign B_eq_0 = (B_out == 0); 
  
  assign A_cmp_B = (A_out < B_out); 
  
  always @(*) begin 
    case (state) 
     WAIT : if (op_valid) nextstate = BUSY; else  nextstate = WAIT; 
      BUSY : if (B_eq_0) nextstate = DONE; else nextstate = BUSY; 
      DONE : if (gcd_ack) nextstate = WAIT; else nextstate = DONE; 
      default: nextstate = WAIT;
    endcase 
  end 
  
  always @(posedge clk or posedge reset) begin 
    if (reset)
      state <= WAIT; 
    else 
      state <= nextstate; 
  end 
  
  always @(*) begin 
    A_sel = 2'b00; 
    B_sel = 1'b0; 
    A_en = 1'b0; 
    B_en = 1'b0; 
    gcd_valid = 1'b0; 
    //do_swap = 1'b0;
    
    case (state) 
      WAIT: begin
        A_sel = 2'b00;
        B_sel = 1'b1; 
        A_en = 1'b1; 
        B_en = 1'b1; 
      end 
      
      BUSY: begin 
        if (A_cmp_B) begin
          // do_swap = 1'b1;
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
        assign gcd_result = A_out;
      end 
    endcase 
  end 
  
   always @(posedge clk or posedge reset) begin
    if (reset) begin
      A_out <= 6'b000000;
      B_out <= 6'b000000;
    //end else begin
    //  if (do_swap) begin
     //   A_out <= B_out;
    //    B_out <= A_out;
      end else begin
        if (A_en)
          A_out <= A_mux_nxt;
        if (B_en)
          B_out <= B_mux_nxt;
      end
    end

endmodule

// Test Bench 

module gcd_numbers_tb();

  reg [5:0] A_in, B_in;
  reg op_valid, clk, reset, gcd_ack;
  wire [5:0] A_out, B_out;
  wire gcd_valid;
  wire [5:0] gcd_result; 

 
  gcd_numbers gcd_number1 (
    .A_in(A_in),
    .B_in(B_in),
    .op_valid(op_valid),
    .clk(clk),
    .reset(reset),
    .gcd_ack(gcd_ack),
    .A_out(A_out),
    .B_out(B_out),
    .gcd_valid(gcd_valid), .gcd_result(gcd_result)
  );

  always #5 clk = ~clk;
  
  initial begin 
    clk = 0;
    reset = 1;
    op_valid = 0;
    gcd_ack = 0;
    A_in = 0;
    B_in = 0;
    
    #10 
    
    reset = 0; 
    A_in = 24; 
    B_in = 20;  
    op_valid = 1;
    #10;
    op_valid = 0;
    gcd_ack = 1;
    #5;
    gcd_ack = 0;
    #200
    $finish; 
  end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, gcd_numbers_tb);
   end 
  
endmodule 
  
  
  
  
