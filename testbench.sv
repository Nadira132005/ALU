`timescale 1ns / 1ps

module ALU_control_unit_tb;

    // Inputs
    reg [7:0] INBUS;
    reg clk;
    reg start;
    reg rst_n;
    
    // Outputs
    wire [7:0] OUTBUS;
    wire finish;

    // Instantiate the ALU control unit
    ALU_control_unit uut (
        .INBUS(INBUS),
        .clk(clk),
        .start(start),
        .rst_n(rst_n),
        .OUTBUS(OUTBUS),
        .finish(finish)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 10ns period clock
    end

    // Test procedure
    initial begin
      	$dumpfile("dump.vcd"); $dumpvars;
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        INBUS = 8'b0;
        
        // Reset the ALU
        #20;
        rst_n = 1;

        // Test case 1: Addition
        #20;
      INBUS = 8'b00000000;   // Set input for addition (INBUS = 0)
        start = 1;             // Start operation (start signal)
        #10;
        start = 0;             // Clear start signal
        
        // Wait until finish signal is high
        wait(finish == 1);
        
        // Read the result
        #10;  // Wait 1 clock cycle
      $display("Addition Result: %d", OUTBUS);
        
        // Test case 2: Subtraction
        #20;
      INBUS = 8'b00000001;   // Set input for subtraction (INBUS = 1)
        start = 1;             // Start operation
        #10;
        start = 0;
        
        // Wait until finish signal is high
        wait(finish == 1);
        
        // Read the result
        #10;
      $display("Subtraction Result: %d", OUTBUS);
        
        // Test case 3: Multiplication (Booth radix 4)
        #20;
      	@(posedge clk);
      	INBUS = 8'b00000010;   // Set input for multiplication (INBUS = 2)
        start = 1;             // Start operation
      	@(posedge clk);
        start = 0;
      	@(posedge clk);
      	INBUS = 8'd23;
      	@(posedge clk);
      	INBUS = 8'd4;
        
        // Wait until finish signal is high
        wait(finish == 1);
        
        // Read the result
      	@(posedge clk);
      $display("Multiplication Result: %d", OUTBUS);
        
        @(posedge clk); 
        @(posedge clk);
      	INBUS = 8'b00000011;   // Set input for division (INBUS = 3)
        start = 1;             
      	@(posedge clk);
        start = 0;
      	@(posedge clk);
        INBUS = 8'b0010_1101;
      	@(posedge clk);
      	INBUS = 8'b0001_0110;
      	@(posedge clk);
        INBUS = 8'b1000_0111;
      	wait(finish == 1);
        
      	@(posedge clk)
      $display("Remainder Result: %d", OUTBUS);
      @(posedge clk)
      $display("Quotient Result: %d", OUTBUS); 
        // Finish the simulation
        $finish;
    end

endmodule
