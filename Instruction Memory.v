`timescale 1ns/1ps

module InstructionMemory(
    input  [63:0] pc,
    output [31:0] instruction
);

    reg [31:0] mem [0:1023];
    integer i;

    initial begin
    
        mem[0]  = 32'h00700013;
        mem[1]  = 32'h00500793;
        mem[2]  = 32'hFFF00813;
        mem[3]  = 32'h410788B3;
        mem[4]  = 32'h00F8F933;
        mem[5]  = 32'h00F919B3;
        mem[6]  = 32'h41398A33;
        mem[7]  = 32'h05000B13;
        mem[8]  = 32'h013B3023;
        mem[9]  = 32'h000B3B83;
        mem[10] = 32'h00F84663;
        mem[11] = 32'h00700A93;
        mem[12] = 32'h00000463;
        mem[13] = 32'h06300A93;
        mem[14] = 32'h001A8A93;

        for (i = 15; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;
    end

    
    assign instruction = mem[pc[11:2]];

endmodule