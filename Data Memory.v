`timescale 1ns/1ps

module DataMemory(
    input clk,
    input MemRead,
    input MemWrite,
    input [63:0] address,
    input [63:0] write_data,
    output reg [63:0] read_data
);

    reg [63:0] mem [0:1023];
    integer i;

    initial begin
        for(i = 0; i < 1024; i = i + 1)
            mem[i] = 64'd0;
    end

    always @(*) begin
        if (MemRead)
            read_data = mem[address[12:3]];
        else
            read_data = 64'd0;
    end

    always @(posedge clk) begin
        if (MemWrite)
            mem[address[12:3]] <= write_data;
    end

endmodule