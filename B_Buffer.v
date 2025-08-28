`timescale 1ns / 1ps

module B_Buffer (
    input  wire        clk,
    input  wire        rst,
    input  wire        load,
    input  wire [31:0] data_in,
    output reg  [31:0] data_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 32'd0;
        else if (load)
            data_out <= data_in;
    end
endmodule