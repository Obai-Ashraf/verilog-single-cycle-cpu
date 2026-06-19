`timescale 1ns / 1ps

module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg [3:0] ALUControl  
);

always @(*) begin
    RegWrite = 0;
    ALUSrc = 0;
    MemRead = 0;
    MemWrite = 0;
    MemtoReg = 0;
    Branch = 0;
    ALUControl = 4'b0000;

    case(opcode)
        7'b0110011: begin
            RegWrite = 1;
            ALUSrc = 0;
            case({funct7, funct3})
                10'b0000000_000: ALUControl = 4'b0000; 
                10'b0100000_000: ALUControl = 4'b0001; 
                10'b0000000_111: ALUControl = 4'b0010; 
                10'b0000000_110: ALUControl = 4'b0011; 
                10'b0000000_100: ALUControl = 4'b0100; 
                10'b0000000_001: ALUControl = 4'b0101; 
                10'b0000000_101: ALUControl = 4'b0110; 
                10'b0000000_011: ALUControl = 4'b0111; 
                default: ALUControl = 4'b0000;
            endcase
        end
        7'b0010011: begin
            RegWrite = 1;
            ALUSrc = 1;
            case(funct3)
                3'b000: ALUControl = 4'b0000; 
                3'b111: ALUControl = 4'b0010; 
                3'b110: ALUControl = 4'b0011; 
                3'b100: ALUControl = 4'b0100; 
                3'b001: ALUControl = 4'b0101; 
                3'b101: ALUControl = 4'b0110; 
                3'b010: ALUControl = 4'b0111; 
                default: ALUControl = 4'b0000;
            endcase
        end

        7'b0000011: begin
            RegWrite = 1;
            ALUSrc = 1;
            MemRead = 1;
            MemtoReg = 1;
            ALUControl = 4'b0000; 
        end
        7'b0100011: begin
            ALUSrc = 1;
            MemWrite = 1;
            ALUControl = 4'b0000; 
        end

        7'b1100011: begin
            Branch = 1;
            case(funct3)
                3'b000: ALUControl = 4'b0001; 
                3'b001: ALUControl = 4'b0001; 
                3'b100: ALUControl = 4'b0111; 
                3'b101: ALUControl = 4'b0111; 
                default: ALUControl = 4'b0000;
            endcase
        end

        default: ALUControl = 4'b0000;
    endcase
end

endmodule