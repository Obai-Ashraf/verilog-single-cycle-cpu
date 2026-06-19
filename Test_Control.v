module test;

reg [6:0] opcode;

wire RegWrite;
wire ALUSrc;
wire MemRead;
wire MemWrite;
wire MemtoReg;
wire Branch;
wire [1:0] ALUOp;

control_unit uut(
    .opcode(opcode),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .Branch(Branch),
    .ALUOp(ALUOp)
);

initial begin

    opcode = 7'b0110011;
    #10;

    opcode = 7'b0010011;
    #10;

    opcode = 7'b0000011;
    #10;

    opcode = 7'b0100011;
    #10;

    opcode = 7'b1100011;
    #10;

    $finish;

end

endmodule