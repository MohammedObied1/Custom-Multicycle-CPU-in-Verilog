`timescale 1ns / 1ps

module RegisterFile(
    input  wire        clk,
    input  wire        reg_write,
    input  wire [3:0]  rs,
    input  wire [3:0]  rt,
    input  wire [3:0]  rd,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
    
);
    reg [31:0] registers [0:15];
    integer i;

       initial begin
        for (i = 0; i < 16; i = i + 1)
            registers[i] = 32'h00000000;
        registers[1] = 32'd5; 
         registers[2] = 32'd8;  
    
         registers[3] = 32'd15; 
         registers[4] = 32'd15; 
         registers[5] = 32'd11; 
         registers[6] = 32'd25; 

         registers[7] = -32'd15; 

    end


    
    assign read_data1   = registers[rs];
    assign read_data2   = registers[rt];


   
    always @(posedge clk) begin
        if (reg_write) begin
            registers[rd] <= write_data;
        end
    end
endmodule