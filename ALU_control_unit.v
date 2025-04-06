`include "adder.v"
`include "ff.v"
`include "counter.v"
`include "mux2_1.v"

module ALU_control_unit (
    input [7:0] INBUS,
    input clk, start, rst_n,
    output wire [7:0] OUTBUS,
    output reg finish
);

    // Operation codes
    parameter 
        ADD = 2'b00, 
        SUBTRACT = 2'b01, 
        MULTIPLY = 2'b10, 
        DIVIDE = 2'b11;

    // State machine states
    parameter 
        IDLE = 4'b0000,
        READ_OPERATION = 4'b0001,
        READ_1 = 4'b0010,
        READ_2 = 4'b0011,
        READ_3 = 4'b0100,
        OPERATION_1 = 4'b0101,
        OPERATION_2 = 4'b0110,
        DIVISION_CORRECTION = 4'b0111,
        OUTBUS_1 = 4'b1001,
        OUTBUS_2 = 4'b1010;

    // Internal state registers
  	reg [3:0] cur_state, next_state;
  	reg [2:0] MAX_COUNT;

    // Signals for operations
    reg [1:0] operation_code;
  	reg [8:0] A;
  	reg [7:0] M, Q; 
    reg read_A, read_M, read_Q, read_op;
    reg add, invert, double, shift_l, shift_r, increment, set_last_bit_Q;
    reg outbus_A, outbus_Q;
  
  	wire reset_n; 
	assign reset_n = rst_n & (cur_state != IDLE);
  
  ff #(.WIDTH(2)) FF_OP_CODE (
    .d(INBUS[1:0]),
    .load(read_op),
    .clk(clk),
    .reset_n(reset_n),
    .q(operation_code)
  );
  
  mux2_1 #(.WIDTH(3)) MUX_MAX_COUNT (
    .in0(3'd7),
    .in1(3'd3),
    .sel(operation_code == MULTIPLY),
    .out(MAX_COUNT)
  );
  
  reg [2:0] count;
  counter #(.WIDTH(3)) COUNTER (
    .clk(clk),
    .reset_n(reset_n),
    .increment(increment),
    .count(count)
  );
  
  wire [8:0] sum_result;
  reg [8:0] B;
  reg carry_in;
 
  wire [8:0] B1;
  mux2_1 #(.WIDTH(9)) DOUBLE_IT(
    .in0(M),
    .in1({M[7:0], 1'b0}),
    .sel(double),
    .out(B1)
  );
  
  mux2_1 #(.WIDTH(9)) INVERT (
    .in0(B1),
    .in1(~B1),
    .sel(invert),
    .out(B)
  );
  
  assign carry_in = invert;
  
  adder #(.WIDTH(9)) _ADD (
    .A(A),
    .B(B),
    .carry_in(carry_in),
    .SUM(sum_result)
  );
  
  wire A_load;
  
  mux2_1 #(.WIDTH(1)) A_LOAD (
    .in0(1'b0),
    .in1(1'b1),
    .out(A_load),
    .sel(read_A | add | shift_r | shift_l)
  );
  
  wire [8:0] A_next_read, A_next_sum, A_next_shifted, A_next;
  
  mux2_1 #(.WIDTH(9)) A_NEXT_1 (
    .in0(A),
    .in1({INBUS[7], INBUS}),
    .out(A_next_read),
    .sel(read_A)
  );
  
  mux2_1 #(.WIDTH(9)) A_NEXT_2 (
    .in0(A_next_read),
    .in1(sum_result),
    .out(A_next_sum),
    .sel(add)
  );
  
  mux2_1 #(.WIDTH(9)) A_NEXT_3 (
    .in0(A_next_sum),
    .in1({A[7], A[7], A[7:2]}),
    .out(A_next_shifted),
    .sel(shift_r)
  );
  
  mux2_1 #(.WIDTH(9)) A_NEXT_4 (
    .in0(A_next_shifted),
    .in1({A[8], A[6:0], Q[7]}),
    .out(A_next),
    .sel(shift_l)
  );
  
  ff #(.WIDTH(9)) FF_A (
    .d(A_next),
    .load(A_load),
    .clk(clk),
    .reset_n(reset_n),
    .q(A)
  );
  
  wire Q_load;
  
  mux2_1 #(.WIDTH(1)) Q_LOAD (
    .in0(1'b0),
    .in1(1'b1),
    .out(Q_load),
    .sel(read_Q | shift_r | shift_l | set_last_bit_Q)
  );
  
  wire [7:0] Q_next_read, Q_next_shifted_1, Q_next_shifted_2, Q_next;
  
  mux2_1 #(.WIDTH(8)) Q_NEXT_1 (
    .in0(Q),
    .in1(INBUS),
    .out(Q_next_read),
    .sel(read_Q)
  );
  
  mux2_1 #(.WIDTH(8)) Q_NEXT_2 (
    .in0(Q_next_read),
    .in1({A[1], A[0], Q[7:2]}),
    .out(Q_next_shifted_1),
    .sel(shift_r)
  );
  
  mux2_1 #(.WIDTH(8)) Q_NEXT_3 (
    .in0(Q_next_shifted_1),
    .in1({Q[6:1], ~A[8], 1'b0}),
    .out(Q_next_shifted_2),
    .sel(shift_l)
  );
  
  mux2_1 #(.WIDTH(8)) Q_NEXT_4 (
    .in0(Q_next_shifted_2),
    .in1({Q[7:1], ~A[8]}),
    .out(Q_next),
    .sel(set_last_bit_Q)
  );
  
  ff #(.WIDTH(8)) FF_Q (
    .d(Q_next),
    .load(Q_load),
    .clk(clk),
    .reset_n(reset_n),
    .q(Q)
  );
  
  wire Q_1, Q_1_next;
  
  mux2_1 #(.WIDTH(1)) Q_1_NEXT (
    .in0(Q_1),
    .in1(Q[1]),
    .out(Q_1_next),
    .sel(shift_r)
  );
  
  ff #(.WIDTH(8)) M_ff (
    .d(INBUS),
    .q(M),
    .clk(clk),
    .load(read_M),
    .reset_n(reset_n)
  );
  
  ff #(.WIDTH(1)) FF_Q_1(
    .d(Q_1_next),
    .load(Q_load),
    .clk(clk),
    .reset_n(reset_n),
    .q(Q_1)
  );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          cur_state <= IDLE;
  		  read_op<=0;
          	
        end else begin
            cur_state <= next_state;
        end
    end

  always @(*) begin
        next_state = IDLE; // Default to IDLE state

        case (cur_state)
            IDLE: begin
                if (start) next_state = READ_OPERATION;
                else next_state = IDLE;
            end

            READ_OPERATION: begin
                next_state = READ_1;
            end

            READ_1: begin
                next_state = READ_2;
            end 

            READ_2: begin 
                next_state = READ_3;
            end 

            READ_3: begin 
                next_state = OPERATION_1;
            end 

            OPERATION_1: begin
                if (operation_code == ADD || operation_code == SUBTRACT) 
                    next_state = OUTBUS_1;
                else next_state = OPERATION_2;
            end

            OPERATION_2: begin 
                if (MAX_COUNT != count) begin 
                    next_state = OPERATION_1;
                end else begin
                    if (operation_code == DIVIDE) begin
                      next_state = DIVISION_CORRECTION;
                    end else next_state = OUTBUS_1;
                end 
            end

            DIVISION_CORRECTION: begin 
                next_state = OUTBUS_1;
            end  

            OUTBUS_1: begin 
                next_state = OUTBUS_2;
            end 

            OUTBUS_2: begin 
                next_state = IDLE;
            end 

            default: next_state = IDLE;
        endcase
    end

    always @(cur_state) begin
        read_A = 0; read_M = 0; read_Q = 0; add = 0; invert = 0; double = 0; shift_l = 0; shift_r = 0;
        increment = 0; set_last_bit_Q = 0; outbus_A = 0; outbus_Q = 0; finish = 0; read_op = 0;
        
        case (cur_state)
            IDLE: finish = 0;
            READ_OPERATION: read_op = 1;
            READ_1: begin                     
              if (operation_code == MULTIPLY) read_Q = 1;
              else read_A = 1;
            end 
            READ_2: begin 
              if (operation_code == DIVIDE)
                  read_Q = 1;
                else read_M = 1;
                
            end 
            READ_3: begin 
              if (operation_code == DIVIDE) begin 
                read_M = 1;
              end 
            end 
            OPERATION_1: begin 
                case (operation_code)
                    ADD: add = 1;
                    SUBTRACT: begin
                        add = 1; invert = 1;
                    end
                    MULTIPLY: begin 
                        case ({Q[1], Q[0], Q_1})
                            3'b001: add = 1;
                            3'b010: add = 1;
                            3'b011: begin 
                                add = 1; double = 1;
                            end
                            3'b101: begin 
                                add = 1; invert = 1;
                            end
                            3'b110: begin 
                                add = 1; invert = 1;
                            end
                            3'b100: begin 
                                add = 1; invert = 1; double = 1;
                            end
                        endcase
                    end
                    DIVIDE: begin 
                        if (count == 0) begin
                            add = 1; invert = 1;
                        end else begin
                            if (A[8] == 1) add = 1;
                            else begin
                                add = 1; invert = 1;
                            end
                        end
                    end
                endcase
            end 

            OPERATION_2: begin 
              if (operation_code == MULTIPLY) shift_r = 1;
              if (MAX_COUNT != count) begin 
                increment = 1;
                if(operation_code == DIVIDE) shift_l = 1;
              end 
            end 

            DIVISION_CORRECTION: begin 
              	if(A[8]) add = 1;
              	set_last_bit_Q = 1;
            end 

            OUTBUS_1: begin 
                outbus_A = 1;
                finish = 1;
            end 
            OUTBUS_2: begin 
                outbus_Q = 1;
                finish = 1;
            end
        endcase
    end

  assign OUTBUS = {8{outbus_A}} & A[7:0] | {8{outbus_Q}} & Q;

endmodule
