`timescale 1ns/1ps

module ALU_tb;

reg [63:0] A;
reg [63:0] B;
reg [3:0] ALUControl;

wire [63:0] Result;
wire Zero;

ALU uut(
    .A(A),
    .B(B),
    .ALUControl(ALUControl),
    .Result(Result),
    .Zero(Zero)
);

initial begin

    A = 10;
    B = 5;
    ALUControl = 4'b0000;
    #10;

    ALUControl = 4'b0001;
    #10;

    ALUControl = 4'b0010;
    #10;

    ALUControl = 4'b0011;
    #10;

    ALUControl = 4'b0100;
    #10;

    A = 8;
    B = 2;
    ALUControl = 4'b0101;
    #10;

    ALUControl = 4'b0110;
    #10;

    $finish;
end

endmodule