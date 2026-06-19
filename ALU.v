`timescale 1ns / 1ps

module ALU(
    input [63:0] A,
    input [63:0] B,
    input [3:0] ALUControl,
    output reg [63:0] Result,
    output Zero,
    output Less
);

always @(*) begin
    case(ALUControl)
        4'b0000: Result = A + B;                              
        4'b0001: Result = A - B;                              
        4'b0010: Result = A & B;                              
        4'b0011: Result = A | B;                              
        4'b0100: Result = A ^ B;                              
        4'b0101: Result = A << B[5:0];                        
        4'b0110: Result = A >> B[5:0];                        
        4'b0111: Result = ($signed(A) < $signed(B)) ? 64'd1 : 64'd0; 
        default: Result = 64'd0;
    endcase
end

assign Zero = (Result == 64'd0) ? 1'b1 : 1'b0;
// FIX: BLT requires SIGNED comparison
assign Less = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;

endmodule