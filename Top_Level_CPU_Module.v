`timescale 1ns / 1ps
module RISC_V_CPU(
    input clk,
    input reset
);


wire [63:0] pc;
wire [63:0] next_pc;
wire [31:0] instruction;
wire [6:0] opcode;
wire [4:0] rd, rs1, rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [63:0] immediate;
wire RegWrite;
wire ALUSrc;
wire MemRead;
wire MemWrite;
wire MemtoReg;
wire Branch;
wire [3:0] ALUControl;
wire [63:0] read_data1;
wire [63:0] read_data2;
wire [63:0] write_data;
wire [63:0] alu_result;
wire zero_flag;
wire less_flag;
wire [63:0] alu_b;
wire [63:0] mem_read_data;

program_counter pc_module(
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc(pc)
);

InstructionMemory inst_mem(
    .pc(pc),
    .instruction(instruction)
);

assign opcode = instruction[6:0];
assign rd = instruction[11:7];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];

ImmediateGenerator imm_gen(
    .instruction(instruction),
    .immediate(immediate)
);


control_unit ctrl_unit(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .Branch(Branch),
    .ALUControl(ALUControl)
);


RegisterFile reg_file(
    .clk(clk),
    .RegWrite(RegWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

assign alu_b = ALUSrc ? immediate : read_data2;

ALU alu_module(
    .A(read_data1),
    .B(alu_b),
    .ALUControl(ALUControl),
    .Result(alu_result),
    .Zero(zero_flag),
    .Less(less_flag)
);


DataMemory data_mem(
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .address(alu_result),
    .write_data(read_data2),
    .read_data(mem_read_data)
);

assign write_data = MemtoReg ? mem_read_data : alu_result;

pc_update pc_upd(
    .pc(pc),
    .funct3(funct3),
    .zero(zero_flag),
    .less(less_flag),
    .imm(immediate),
    .branch(Branch),
    .next_pc(next_pc)
);

endmodule