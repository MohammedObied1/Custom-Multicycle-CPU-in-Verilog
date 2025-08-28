`timescale 1ns / 1ps

module PC_Control (
    input wire [5:0] opcode,     
    input wire zero,             
    input wire neg,             
    input wire pos,              
    input wire [3:0] state,     

    output reg pc_write,         
    output reg [1:0] pc_src     
);

    localparam FETCH   = 4'd0;
    localparam DECODE  = 4'd1;
    localparam EXECUTE = 4'd2;

    always @(*) begin
        pc_write = 1'b0;
        pc_src   = 2'b00;  

        case (opcode)
           
            6'b000010: begin 
                if (state == EXECUTE) begin
                    pc_write = 1;
                    pc_src   = 2'b11; 
                end
            end

            6'b000011: begin 
                if (state == EXECUTE) begin
                    pc_write = 1;
                    pc_src   = 2'b11; 
                end
            end

          
            6'b000110: begin 
                if (state == EXECUTE) begin
                    pc_write = 1;
                    pc_src   = 2'b10;
                end
            end

            6'b001010: begin 
                if (state == EXECUTE && zero) begin
                    pc_write = 1;
                    pc_src   = 2'b01; 
                end
            end

            6'b001011: begin 
                if (state == EXECUTE && pos) begin
                    pc_write = 1;
                    pc_src   = 2'b01;
                end
            end

            6'b001100: begin 
                if (state == EXECUTE && neg) begin
                    pc_write = 1;
                    pc_src   = 2'b01;
                end
            end

            default: begin
                if (state == FETCH) begin
                    pc_write = 1;
                    pc_src   = 2'b00;  
                end
            end
        endcase
    end

endmodule

