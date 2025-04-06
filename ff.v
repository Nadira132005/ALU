module ff #(
    parameter WIDTH = 1  
)(
    input wire clk,         
    input wire reset_n,       
    input wire load,       
    input wire [WIDTH-1:0] d, 
    output reg [WIDTH-1:0] q   
);


  always @(posedge clk) begin
  if (!reset_n) 
        q <= 0; 
    else if (load) 
        q <= d; 
    else q <= q;
end

endmodule
