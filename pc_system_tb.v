`timescale 1ns / 1ps

module pc_system_tb;
    reg clk;
    reg reset;
    reg branch;
    reg [2:0] funct3;
    reg zero;
    reg less;
    reg [63:0] imm;
    wire [63:0] pc;
    wire [63:0] next_pc;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate modules
    program_counter pc_reg(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    pc_update pc_upd(
        .pc(pc),
        .funct3(funct3),
        .zero(zero),
        .less(less),
        .imm(imm),
        .branch(branch),
        .next_pc(next_pc)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reusable check task
    task check_pc(input [255:0] test_name, input [63:0] expected);
        begin
            if (pc === expected) begin
                $display("PASS: %0s -> PC = %0d", test_name, pc);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s -> PC = %0d (expected %0d)", test_name, pc, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("========================================");
        $display("PC_SYSTEM TESTBENCH (funct3/branch design)");
        $display("========================================");

        clk = 0;
        reset = 1;
        branch = 0;
        funct3 = 3'b000;
        zero = 0;
        less = 0;
        imm = 64'd0;

        // Test 1: Reset
        $display("\nTest 1: Reset PC to 0");
        #10;
        check_pc("Reset", 64'd0);

        // Test 2: branch=0, no branch regardless of funct3/zero/less -> PC+4
        $display("\nTest 2: branch=0 (disabled) -> PC+4");
        reset = 0;
        branch = 0;
        funct3 = 3'b000;
        zero = 1; // even if zero is true, branch disabled means not taken
        #10;
        check_pc("Branch disabled", 64'd4);

        // Test 3: funct3=000 (BEQ), branch=1, zero=1 -> TAKEN
        $display("\nTest 3: BEQ (funct3=000) branch=1 zero=1 -> TAKEN +100");
        branch = 1;
        funct3 = 3'b000;
        zero = 1;
        imm = 64'd100;
        #10;
        check_pc("BEQ taken", 64'd104); // 4 + 100

        // Test 4: funct3=000 (BEQ), branch=1, zero=0 -> NOT TAKEN
        $display("\nTest 4: BEQ (funct3=000) branch=1 zero=0 -> NOT TAKEN, PC+4");
        zero = 0;
        #10;
        check_pc("BEQ not taken", 64'd108); // 104 + 4

        // Test 5: funct3=001 (BNE), branch=1, zero=0 -> TAKEN (~zero=1)
        $display("\nTest 5: BNE (funct3=001) branch=1 zero=0 -> TAKEN +200");
        funct3 = 3'b001;
        zero = 0;
        imm = 64'd200;
        #10;
        check_pc("BNE taken", 64'd308); // 108 + 200

        // Test 6: funct3=001 (BNE), branch=1, zero=1 -> NOT TAKEN
        $display("\nTest 6: BNE (funct3=001) branch=1 zero=1 -> NOT TAKEN, PC+4");
        zero = 1;
        #10;
        check_pc("BNE not taken", 64'd312); // 308 + 4

        // Test 7: funct3=100 (BLT), branch=1, less=1 -> TAKEN
        $display("\nTest 7: BLT (funct3=100) branch=1 less=1 -> TAKEN +150");
        funct3 = 3'b100;
        less = 1;
        imm = 64'd150;
        #10;
        check_pc("BLT taken", 64'd462); // 312 + 150

        // Test 8: funct3=100 (BLT), branch=1, less=0 -> NOT TAKEN
        $display("\nTest 8: BLT (funct3=100) branch=1 less=0 -> NOT TAKEN, PC+4");
        less = 0;
        #10;
        check_pc("BLT not taken", 64'd466); // 462 + 4

        // Test 9: funct3=101 (BGE), branch=1, less=0 -> TAKEN (~less=1)
        $display("\nTest 9: BGE (funct3=101) branch=1 less=0 -> TAKEN +300");
        funct3 = 3'b101;
        less = 0;
        imm = 64'd300;
        #10;
        check_pc("BGE taken", 64'd766); // 466 + 300

        // Test 10: funct3=101 (BGE), branch=1, less=1 -> NOT TAKEN
        $display("\nTest 10: BGE (funct3=101) branch=1 less=1 -> NOT TAKEN, PC+4");
        less = 1;
        #10;
        check_pc("BGE not taken", 64'd770); // 766 + 4

        // Test 11: Backward branch (BEQ, negative imm = -100)
        $display("\nTest 11: BEQ backward branch (imm = -100)");
        funct3 = 3'b000;
        zero = 1;
        imm = 64'hFFFFFFFFFFFFFF9C; // -100
        #10;
        check_pc("Backward branch", 64'd670); // 770 - 100

        // Test 12: Undefined funct3 (e.g. 3'b010) with branch=1 -> default case, not taken
        $display("\nTest 12: Undefined funct3 (010) branch=1 -> default, NOT TAKEN, PC+4");
        funct3 = 3'b010;
        zero = 1;
        less = 1;
        imm = 64'd999; // should be ignored
        #10;
        check_pc("Undefined funct3 default", 64'd674); // 670 + 4

        // Test 13: Reset mid-execution
        $display("\nTest 13: Reset mid-execution");
        reset = 1;
        #10;
        check_pc("Reset mid-execution", 64'd0);

        // Test 14: Coming out of reset with branch=1 immediately (BEQ, zero=1)
        $display("\nTest 14: Post-reset BEQ branch=1 zero=1 -> TAKEN");
        reset = 0;
        branch = 1;
        funct3 = 3'b000;
        zero = 1;
        imm = 64'd50;
        #10;
        check_pc("Post-reset BEQ taken", 64'd50); // 0 + 50

        $display("\n========================================");
        $display("SUMMARY: %0d PASSED, %0d FAILED (of %0d tests)", pass_count, fail_count, pass_count + fail_count);
        $display("========================================\n");

        $finish;
    end
endmodule