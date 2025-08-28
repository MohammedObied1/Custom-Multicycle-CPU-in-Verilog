`timescale 1ns / 1ps

module MainControl (
    input wire [5:0] opcode,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg alu_src,
    output reg mem_to_reg,
    output reg [1:0] pc_src
);

    always @(*) begin
        reg_write    = 0;
        mem_read     = 0;
        mem_write    = 0;
        alu_src      = 0;
        mem_to_reg   = 0;
        pc_src       = 2'b00;

        case (opcode)
            6'b000000: reg_write = 1; 
            6'b000001: reg_write = 1;
            6'b000010: reg_write = 1; 
            6'b000011: reg_write = 1; 
            6'b000100: begin
                reg_write = 1;
                alu_src   = 1;
            end
            6'b000101: begin 
                reg_write = 1;
                alu_src   = 1;
            end
            6'b000110: begin 
                reg_write  = 1;
                mem_read   = 1;
                alu_src    = 1;
                mem_to_reg = 1;
            end
            6'b000111: begin 
                mem_write = 1;
                alu_src   = 1;
            end
            6'b001000: begin 
                reg_write  = 1;
                mem_read   = 1;
                alu_src    = 1;
                mem_to_reg = 1;
            end
            6'b001001: begin 
                mem_write = 1;
                alu_src   = 1;
            end
            6'b001010, 6'b001011, 6'b001100: pc_src = 2'b01; 
            6'b001101: pc_src = 2'b10; 
            6'b001110, 6'b001111: begin 
                reg_write = (opcode == 6'b001111); 
                pc_src    = 2'b11;
            end
        endcase
    end

endmodule

