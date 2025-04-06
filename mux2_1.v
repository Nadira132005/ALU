module mux2_1 #(
    parameter WIDTH = 8
)(
  input [WIDTH-1:0] in0,  
  input [WIDTH-1:0] in1,
    input sel,
    output [WIDTH-1:0] out
);
  
  assign out = {WIDTH{~sel}} & in0 | {WIDTH{sel}} & in1;
endmodule
