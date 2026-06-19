`timescale 1ns/1ps

module Task3_tb;

    // Clock generation (10ns period)
    reg clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Register File Signals
    reg RegWrite;
    reg [4:0] rs1, rs2, rd;
    reg [63:0] write_data;
    wire [63:0] read_data1, read_data2;

    RegisterFile RF (
        .clk(clk), .RegWrite(RegWrite), 
        .rs1(rs1), .rs2(rs2), .rd(rd), 
        .write_data(write_data), 
        .read_data1(read_data1), .read_data2(read_data2)
    );

    // Immediate Generator Signals
    reg [31:0] instruction;
    wire [63:0] immediate;

    ImmediateGenerator IG (
        .instruction(instruction), 
        .immediate(immediate)
    );

    initial begin
        $display("===== START TEST =====");
        RegWrite = 0; rs1 = 0; rs2 = 0; rd = 0; write_data = 0; instruction = 0;

        // Test 1: Write 100 into register x5
        #10;
        RegWrite = 1; rd = 5; write_data = 64'd100;
        #10;
        RegWrite = 0; rs1 = 5;
        #10;
        $display("x5 = %d (Expected: 100)", read_data1);

        // Test 2: Verify x0 remains zero upon write attempt
        RegWrite = 1; rd = 0; write_data = 64'd999;
        #10;
        RegWrite = 0; rs1 = 0;
        #10;
        $display("x0 = %d (Expected: 0)", read_data1);

        // Test 3: ADDI Immediate (addi x1, x0, 5)
        instruction = 32'h00500093; 
        #10;
        $display("ADDI Imm = %d (Expected: 5)", immediate);

        // Test 4: LD Immediate for RV64 (ld x6, 8(x5))
        instruction = 32'h0082b303; 
        #10;
        $display("LD Imm   = %d (Expected: 8)", immediate);

        // Test 5: SD Immediate for RV64 (sd x3, 16(x0))
        instruction = 32'h00303823; 
        #10;
        $display("SD Imm   = %d (Expected: 16)", immediate);

        // Test 6: BEQ Immediate (beq x13, x14, 4)
        instruction = 32'h00e68263; 
        #10;
        $display("BEQ Imm  = %d (Expected: 4)", immediate);

        // Test 7: Shift Immediate for RV64 (slli x4, x9, 3)
        instruction = 32'h00349213; 
        #10;
        $display("SLLI Imm = %d (Expected: 3)", immediate);

        $display("===== END TEST =====");
        #20;
        $finish;
    end

endmodule