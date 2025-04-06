module full_adder (
    input a,        
    input b,        
    input cin,      
    output sum,     
    output cout     
);
    assign sum = a ^ b ^ cin;       
    assign cout = (a & b) | (b & cin) | (a & cin);  
endmodule

module adder #(parameter WIDTH = 8) ( 
    input [WIDTH-1:0] A,    
    input [WIDTH-1:0] B,    
  	input carry_in,    
    output [WIDTH-1:0] SUM,  
    output carry_out   
);
    wire [WIDTH:0] carry;  

  assign carry[0] = carry_in; 

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : full_adder_loop
            full_adder FA (
                .a(A[i]), 
                .b(B[i]), 
                .cin(carry[i]), 
                .sum(SUM[i]), 
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[WIDTH]; 
endmodule
