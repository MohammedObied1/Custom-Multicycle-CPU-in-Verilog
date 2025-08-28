`timescale 1ns / 1ps

module IR (
    input  wire        clk,
    input  wire        rst,
    input  wire        load,
    input  wire [31:0] instruction_in,
    output wire [5:0]  opcode,
    output wire [3:0]  rd,
    output wire [3:0]  rs,
    output wire [3:0]  rt,
    output wire [13:0] imm
);
    reg [31:0] IR_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            IR_reg <= 32'd0;
        else if (load)
            IR_reg <= instruction_in;
    end

    assign opcode = IR_reg[31:26];
    assign rd     = IR_reg[25:22];
    assign rs     = IR_reg[21:18];
    assign rt     = IR_reg[17:14];
    assign imm    = IR_reg[13:0];
endmodule