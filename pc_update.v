module pc_update(
    input [63:0] pc,
    input [2:0] funct3,      
    input zero,              
    input less,              
    input [63:0] imm,
    input branch,            
    output reg [63:0] next_pc
);

reg take_branch;

always @(*) begin
    take_branch = 1'b0;
    
    if (branch) begin
        case(funct3)
            3'b000: take_branch = zero;           
            3'b001: take_branch = ~zero;          
            3'b100: take_branch = less;           
            3'b101: take_branch = ~less;          
            default: take_branch = 1'b0;
        endcase
    end
    
    if (take_branch)
        next_pc = pc + imm;
    else
        next_pc = pc + 64'd4;
end

endmodule