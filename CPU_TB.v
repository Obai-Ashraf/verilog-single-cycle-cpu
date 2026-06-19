`timescale 1ns / 1ps

module RISC_V_CPU_TB;

// ============================================================
// Clock & Reset
// ============================================================
reg clk;
reg reset;

// ============================================================
// Internal Signal Taps
// ============================================================
wire [63:0] pc;
wire [63:0] next_pc;
wire [31:0] instruction;
wire [6:0]  opcode;
wire [4:0]  rd, rs1, rs2;
wire [2:0]  funct3;
wire [6:0]  funct7;
wire [63:0] immediate;

wire        RegWrite;
wire        ALUSrc;
wire        MemRead;
wire        MemWrite;
wire        MemtoReg;
wire        Branch;
wire [3:0]  ALUControl;

wire [63:0] read_data1;
wire [63:0] read_data2;
wire [63:0] write_data;

wire [63:0] alu_result;
wire        zero_flag;
wire        less_flag;
wire [63:0] alu_b;
wire [63:0] mem_read_data;

// ============================================================
// DUT Instantiation
// ============================================================
RISC_V_CPU uut (
    .clk(clk),
    .reset(reset)
);

// ============================================================
// Wire taps into uut
// ============================================================
assign pc           = uut.pc;
assign next_pc      = uut.next_pc;
assign instruction  = uut.instruction;
assign opcode       = uut.opcode;
assign rd           = uut.rd;
assign rs1          = uut.rs1;
assign rs2          = uut.rs2;
assign funct3       = uut.funct3;
assign funct7       = uut.funct7;
assign immediate    = uut.immediate;
assign RegWrite     = uut.RegWrite;
assign ALUSrc       = uut.ALUSrc;
assign MemRead      = uut.MemRead;
assign MemWrite     = uut.MemWrite;
assign MemtoReg     = uut.MemtoReg;
assign Branch       = uut.Branch;
assign ALUControl   = uut.ALUControl;
assign read_data1   = uut.read_data1;
assign read_data2   = uut.read_data2;
assign write_data   = uut.write_data;
assign alu_result   = uut.alu_result;
assign zero_flag    = uut.zero_flag;
assign less_flag    = uut.less_flag;
assign alu_b        = uut.alu_b;
assign mem_read_data= uut.mem_read_data;

// ============================================================
// Clock: 10 ns period (100 MHz)
// ============================================================
initial clk = 1'b0;
always #5 clk = ~clk;

// ============================================================
// Main Test
// ============================================================
integer i;
integer pass_count;
integer fail_count;

initial begin
    $dumpfile("riscv_cpu_sim.vcd");
    $dumpvars(0, RISC_V_CPU_TB);

    pass_count = 0;
    fail_count = 0;

    $display("\n");
    $display("╔══════════════════════════════════════════════════════╗");
    $display("║    RISC-V 64-bit Single-Cycle CPU Testbench         ║");
    $display("║    Nile University — CSC311 Spring 2026             ║");
    $display("╚══════════════════════════════════════════════════════╝\n");

    // ----------------------------------------------------------
    // PHASE 1: Reset
    // ----------------------------------------------------------
    $display("┌──────────────────────────────────┐");
    $display("│  PHASE 1: RESET                  │");
    $display("└──────────────────────────────────┘");
    reset = 1'b1;
    #20;
    reset = 1'b0;
    $display("  [%0t ns] Reset released — PC = %0d\n", $time, pc);

    // ----------------------------------------------------------
    // PHASE 2: Execute Program (15 instructions + some NOPs)
    // ----------------------------------------------------------
    $display("┌──────────────────────────────────────────────────────┐");
    $display("│  PHASE 2: INSTRUCTION EXECUTION TRACE               │");
    $display("└──────────────────────────────────────────────────────┘");
    $display("  %-6s %-12s %-10s %-8s %-8s %-6s %-6s",
             "PC", "Instr(hex)", "Opcode", "rd", "ALU_Out", "Zero", "RW");
    $display("  %-6s %-12s %-10s %-8s %-8s %-6s %-6s",
             "------","----------","--------","------","--------","----","--");

    // Run enough cycles: 15 instructions + branch skip + buffer
    repeat(20) begin
        @(posedge clk);
        #1; // small delay for signals to settle
        $display("  %-6d 0x%08h  op=%07b  x%-2d  %-10d  %b     %b",
                 pc, instruction, opcode, rd, $signed(alu_result), zero_flag, RegWrite);
    end

    $display("");

    // ----------------------------------------------------------
    // PHASE 3: Verification
    // ----------------------------------------------------------
    $display("┌──────────────────────────────────────────────────────┐");
    $display("│  PHASE 3: REGISTER FILE CONTENTS                    │");
    $display("└──────────────────────────────────────────────────────┘");
    $display("  ┌──────┬────────────────────┬──────────────────────┐");
    $display("  │ Reg  │   Decimal Value    │     Hex Value        │");
    $display("  ├──────┼────────────────────┼──────────────────────┤");
    for (i = 0; i < 32; i = i + 1) begin
        if (uut.reg_file.registers[i] != 0 || i == 0) begin
            $display("  │  x%-2d │ %18d │ 0x%016h │",
                     i, $signed(uut.reg_file.registers[i]),
                     uut.reg_file.registers[i]);
        end
    end
    $display("  └──────┴────────────────────┴──────────────────────┘\n");

    // ----------------------------------------------------------
    // PHASE 4: Assertion Checks
    // ----------------------------------------------------------
    $display("┌──────────────────────────────────────────────────────┐");
    $display("│  PHASE 4: EXPECTED RESULTS VERIFICATION             │");
    $display("└──────────────────────────────────────────────────────┘");

    check_reg( 0, 64'd0,                  "x0  = 0      (hardwired zero)");
    check_reg(15, 64'd5,                  "x15 = 5      (addi x15,x0,5)");
    check_reg(16, 64'hFFFFFFFFFFFFFFFF,   "x16 = -1     (addi x16,x0,-1)");
    check_reg(17, 64'd6,                  "x17 = 6      (sub x17,x15,x16)");
    check_reg(18, 64'd4,                  "x18 = 4      (and x18,x17,x15)");
    check_reg(19, 64'd128,                "x19 = 128    (sll x19,x18,x15)");
    check_reg(20, 64'd0,                  "x20 = 0      (sub x20,x19,x19)");
    check_reg(22, 64'd80,                 "x22 = 80     (addi x22,x0,80)");
    check_reg(23, 64'd128,                "x23 = 128    (ld x23,0(x22))");
    check_reg(21, 64'd100,                "x21 = 100    (branch+addi 99+1)");

    $display("");
    $display("┌──────────────────────────────────────────────────────┐");
    $display("│  PHASE 5: DATA MEMORY CHECK                         │");
    $display("└──────────────────────────────────────────────────────┘");
    // sd x19, 0(x22): address=80 => mem index = 80>>3 = 10
    if (uut.data_mem.mem[10] === 64'd128) begin
        $display("  [PASS] Mem[80] = %0d  (sd x19,0(x22))", uut.data_mem.mem[10]);
        pass_count = pass_count + 1;
    end else begin
        $display("  [FAIL] Mem[80] = %0d  (expected 128)", uut.data_mem.mem[10]);
        fail_count = fail_count + 1;
    end

    $display("");
    $display("┌──────────────────────────────────────────────────────┐");
    $display("│  PHASE 6: INSTRUCTION MEMORY DUMP                   │");
    $display("└──────────────────────────────────────────────────────┘");
    $display("  ┌───────┬────────────┬──────────────────────────────┐");
    $display("  │ Word  │    Hex     │  Assembly                    │");
    $display("  ├───────┼────────────┼──────────────────────────────┤");
    $display("  │ [0]   │ 0x%08h │  addi x0,  x0,  7            │", uut.inst_mem.mem[0]);
    $display("  │ [1]   │ 0x%08h │  addi x15, x0,  5            │", uut.inst_mem.mem[1]);
    $display("  │ [2]   │ 0x%08h │  addi x16, x0, -1            │", uut.inst_mem.mem[2]);
    $display("  │ [3]   │ 0x%08h │  sub  x17, x15, x16          │", uut.inst_mem.mem[3]);
    $display("  │ [4]   │ 0x%08h │  and  x18, x17, x15          │", uut.inst_mem.mem[4]);
    $display("  │ [5]   │ 0x%08h │  sll  x19, x18, x15          │", uut.inst_mem.mem[5]);
    $display("  │ [6]   │ 0x%08h │  sub  x20, x19, x19          │", uut.inst_mem.mem[6]);
    $display("  │ [7]   │ 0x%08h │  addi x22, x0,  80           │", uut.inst_mem.mem[7]);
    $display("  │ [8]   │ 0x%08h │  sd   x19, 0(x22)            │", uut.inst_mem.mem[8]);
    $display("  │ [9]   │ 0x%08h │  ld   x23, 0(x22)            │", uut.inst_mem.mem[9]);
    $display("  │ [10]  │ 0x%08h │  blt  x16, x15, L1(+12)      │", uut.inst_mem.mem[10]);
    $display("  │ [11]  │ 0x%08h │  addi x21, x0, 7  (skipped)  │", uut.inst_mem.mem[11]);
    $display("  │ [12]  │ 0x%08h │  beq  x0, x0, END (skipped)  │", uut.inst_mem.mem[12]);
    $display("  │ [13]  │ 0x%08h │  L1: addi x21, x0, 99        │", uut.inst_mem.mem[13]);
    $display("  │ [14]  │ 0x%08h │  END: addi x21, x21, 1       │", uut.inst_mem.mem[14]);
    $display("  └───────┴────────────┴──────────────────────────────┘");

    $display("");
    $display("╔══════════════════════════════════════════════════════╗");
    $display("║  SUMMARY: %0d PASSED  |  %0d FAILED                      ║",
             pass_count, fail_count);
    $display("╚══════════════════════════════════════════════════════╝\n");

    #50;
    $finish;
end

// ============================================================
// Task: Check Register
// ============================================================
task check_reg;
    input integer    reg_num;
    input [63:0]     expected;
    input [200*8:1]  label;
    begin
        if (uut.reg_file.registers[reg_num] === expected) begin
            $display("  [PASS] %0s", label);
            pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] %0s  => got %0d (0x%h)",
                     label,
                     $signed(uut.reg_file.registers[reg_num]),
                     uut.reg_file.registers[reg_num]);
            fail_count = fail_count + 1;
        end
    end
endtask

endmodule