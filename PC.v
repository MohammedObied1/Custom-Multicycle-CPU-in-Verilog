`timescale 1ns / 1ps

module PC (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_write,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else if (pc_write)
            pc <= next_pc;
    end

endmodule