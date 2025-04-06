`include "adder.v"
`include "ff.v"

module counter #(parameter WIDTH) (
  input clk, reset_n, increment,
  output reg [WIDTH - 1:0] count
);
  
  wire [WIDTH-1:0] next_count;
  
  adder #(.WIDTH(WIDTH)) ADD (
    .A(count),
    .B({WIDTH{1'b0}}),
    .carry_in(1'b1),
    .SUM(next_count)
  );
  
  
  ff #(.WIDTH(WIDTH)) FF (
    .d(next_count),
    .q(count),
    .load(increment),
    .reset_n(reset_n),
    .clk(clk)
  );
endmodule