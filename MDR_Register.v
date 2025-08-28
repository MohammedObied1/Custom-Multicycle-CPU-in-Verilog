`timescale 1ns / 1ps

module MDR_Register (
    input  wire        clk,
    input  wire        rst,
    input  wire        load,
    input  wire [31:0] DATA_result_in,
    output reg  [31:0] DATA_result_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            DATA_result_out <= 32'b0;
        else if (load)
            DATA_result_out <= DATA_result_in;
    end

endmodule
