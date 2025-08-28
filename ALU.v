`timescale 1ns / 1ps

module ALU (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_op,
    output reg  [31:0] result,
    output wire        zero,
    output wire        neg,
    output wire        pos
);

    always @(*) begin
        result = 32'b0;
        case (alu_op)
            4'b0000: result = a | b;    
            4'b0001: result = a + b;    
            4'b0010: result = a - b;   
            4'b0011: begin              
                if (a == b)
                    result = 32'b0;
                else if (a < b)
                    result = -32'd1;
                else
                    result = 32'd1;
                   end
            4'b0100: result = a | b;   
            4'b0101: result = a + b;    
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 0);
    assign neg  = result[31];
    assign pos  = (~result[31]) && (result != 0);

endmodule
