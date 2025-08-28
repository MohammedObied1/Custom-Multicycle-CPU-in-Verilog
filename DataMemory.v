`timescale 1ns / 1ps

module DataMemory (
    input  wire        clk,       
    input  wire        mem_write,  
    input  wire        mem_read,   
    input  wire [31:0] addr,      
    input  wire [31:0] write_data, 
    output reg  [31:0] read_data   
);

  
    reg [31:0] mem [0:255];
    integer    i;

    initial begin
       
      mem[8]  = 32'hAAAAAAAA;
      mem[9]  = 32'hBBBBBBBB;
      mem[18]  = 32'hCCCCCCCC;


        for (i = 0; i < 256; i = i + 1) begin
          if (i != 8 && i != 9 && i != 18 )
                mem[i] = 32'h00000000;
        end
    end

    always @(posedge clk) begin
        if (mem_write) begin
        
            mem[addr] <= write_data;
        end
    end

   
    always @(*) begin
        if (mem_read)
            read_data = mem[addr];
        else
            read_data = 32'h00000000;
    end

endmodule
