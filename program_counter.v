`timescale 1ns / 1ps
module program_counter(
    input clk,
    input reset,
    input [63:0] next_pc,
    output reg [63:0] pc
);

always @(posedge clk) begin
    if (reset == 1'b1)
        pc <= 64'd0;  
    else
        pc <= next_pc;  
end

endmodule