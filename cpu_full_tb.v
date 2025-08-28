`timescale 1ns / 1ps

module cpu_full_tb;

   
    reg         clk;
    reg         rst;
    integer     cycle_count;
    reg [31:0]  prev_pc;


    integer     i, j;

   
    wire [31:0] regs_out [0:15];
    wire [31:0] mem_out  [0:255];

    localparam LAST_INSTR_ADDR = 100;

  
    CPU uut (
        .clk        (clk),
        .rst        (rst),
      
        .regs_out   (regs_out),
        .mem_out    (mem_out)
    );

  
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    initial begin
        rst = 1;
        #20 rst = 0;
    end

   
    initial begin
        prev_pc = 32'hFFFFFFFF;
        #5;
        $display("\n================================================");
        $display("  Time(ns)  |    PC    |  ALU_Out  | WriteBack");
        $display("================================================");
    end

  
    always @(posedge clk) begin
        if ((uut.pc_unit.pc !== prev_pc) && (uut.pc_unit.pc < LAST_INSTR_ADDR)) begin
            $display("%8t   |  %2d     |   %h   |   %h",
                     $time,
                     uut.pc_unit.pc,
                     uut.alu_out_buf.alu_out,
                     uut.write_back_data
            );
        end
        prev_pc <= uut.pc_unit.pc;
    end

   
    initial begin
        cycle_count = 0;
        #22;
        forever begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            if (cycle_count == 200) begin
                $display("\n** Simulation complete (%0d clock cycles) **\n", cycle_count);

  
                $display("----- Nonzero Data Memory Contents -----");
                for (i = 0; i < 256; i = i + 1) begin
                    if (mem_out[i] !== 32'h00000000) begin
                        $display("Mem[%0d] = %h", i, mem_out[i]);
                    end
                end

                
                $display("\n----- Nonzero Register File Contents -----");
                for (j = 0; j < 16; j = j + 1) begin
                   
                        $display("R[%0d] = %h  == %0d", j, regs_out[j], regs_out[j]);
                    
                end

                $finish;
            end
        end
    end

endmodule
