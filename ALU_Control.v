`timescale 1ns / 1ps

module ALU_Control (
    input  wire [1:0] alu_op,
    input  wire [5:0] opcode,
    output reg  [3:0] alu_operation
);

    always @(*) begin
        case (alu_op)
            2'b00:  alu_operation = 4'b0001;

            2'b01: begin
                case (opcode)
                    6'b000010: alu_operation = 4'b0010; 
                    6'b000011: alu_operation = 4'b0011; 
                    default:   alu_operation = 4'b0010; 
                endcase
            end

            2'b10: begin
                case (opcode)
                    6'b000001: alu_operation = 4'b0001; 
                    default:   alu_operation = 4'b0001;
                endcase
            end

            2'b11: begin
                case (opcode)
                    6'b000000: alu_operation = 4'b0000;
                    6'b000100: alu_operation = 4'b0100; 
                    6'b000101: alu_operation = 4'b0101;
                    default:   alu_operation = 4'b0000;
                endcase
            end

            default: alu_operation = 4'b0000;
        endcase
    end

endmodule