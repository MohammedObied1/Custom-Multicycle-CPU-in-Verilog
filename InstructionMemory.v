module InstructionMemory (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];

    initial begin
      
        $readmemb("alu_l_s.mem", mem);
    end

    assign instr = mem[addr];
endmodule
