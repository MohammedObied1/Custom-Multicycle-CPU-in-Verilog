`timescale 1ns / 1ps

module ALU_Result_Register (
    input  wire        clk,
    input  wire        rst,
    input  wire        load,
    input  wire [31:0] alu_in,
    output reg  [31:0] alu_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_out <= 32'b0;
        end else if (load) begin
            alu_out <= alu_in;
        end
    end

endmodule
