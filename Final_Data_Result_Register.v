`timescale 1ns / 1ps

module Final_Data_Result_Register (
    input wire clk,
    input wire rst,
    input wire load,
    input wire [31:0] Final_Data_max_in,
    output reg [31:0] Final_Data_max_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            Final_Data_max_out <= 32'b0;
        else if (load)
            Final_Data_max_out <= Final_Data_max_in;
    end
		
endmodule

