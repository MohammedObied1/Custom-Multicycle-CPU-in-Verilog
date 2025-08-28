`timescale 1ns / 1ps

module CPU (
    input  wire        clk,
    input  wire        rst,
   
    output wire [31:0] regs_out [0:15],  
    output wire [31:0] mem_out  [0:255]  
);

    localparam FETCH        = 4'd0;
    localparam DECODE       = 4'd1;
    localparam EXECUTE      = 4'd2;
    localparam MEM          = 4'd3;		
	
    localparam LDW_LWRD     = 4'd4; 
    localparam LDW_LWWR     = 4'd5; 
    localparam LDW_UPRD     = 4'd6; 
    localparam LDW_UPWR     = 4'd7;   
	
    localparam SDW_UPWR     = 4'd8; 
    localparam WRITEBACK    = 4'd9; 
    localparam HALT         = 4'd10;

    reg [3:0] state, next_state;

    reg        ir_write, load_a, load_b, load_alu_out;			 
	
	
    reg        load_mdr, reg_write_fsm, mem_read_fsm, mem_write_fsm;  
	
    reg        mem_to_reg_fsm, pc_write_fsm;
    reg  [1:0] pc_src_fsm;

    wire [5:0]  opcode;
    wire [3:0]  rd, rs, rt;			   
	
    wire [13:0] imm; 
	localparam OP_SW  = 6'b000111;		
	
    localparam OP_SDW = 6'b001001;

    wire [31:0] pc_out, instr;
    reg  [31:0] pc_in;


wire [31:0] PCPlusOne   = pc_out + 32'd1;		  

wire [31:0] ImmSE       = {{18{imm[13]}}, imm};	 

wire [31:0] ImmZE       = {18'd0, imm};
wire [31:0] branch_tgt  = PCPlusOne + ImmSE;   

wire [31:0] jump_tgt    = ImmZE;              


mux4to1 #(32) PC_mux (
  .in0(PCPlusOne),    
  .in1(branch_tgt),   		 
  
  .in2(A_out),        
  .in3(jump_tgt),     		
  
  .sel(pc_src_fsm),
  .out(pc_in)
);




    PC pc_unit (
	.clk      (clk),			   
	
        .rst      (rst),
        .pc_write (pc_write_fsm),		   
		
        .next_pc  (pc_in),
        .pc       (pc_out)
    );

   
    InstructionMemory imem (.addr(pc_out), .instr(instr));	
	
    IR instruction_reg (
	.clk(clk), .rst(rst), .load(ir_write),	
	
        .instruction_in(instr),
        .opcode(opcode), .rd(rd), .rs(rs), .rt(rt), .imm(imm)
    );


    wire [31:0] rd1, rd2, rd2p1, A_out, B_out; 
	
    reg  [3:0] rd_sel_index;				  
	
    reg  [31:0] write_back_data;
	



reg [3:0] data_sel;					  

always @(*) begin					 
	
    if (opcode == OP_SDW) begin		
		
        if (state == DECODE)		
			
            data_sel = rd;           
        else if (state == MEM)		
			
            data_sel = rd + 4'd1;     
        else
            data_sel = rt;       
			
    end
    else if (opcode == OP_SW)
        data_sel = rd;                
    else						   
		
        data_sel = rt;                
end

RegisterFile regfile (
.clk        (clk),			  

  .reg_write  (reg_write_fsm),
  .rs         (rs),
  .rt         (data_sel),   	   
  
  .rd         (rd_sel_index),
  .write_data (write_back_data),
  .read_data1 (rd1),			   
  
  .read_data2 (rd2)
);


   A_Buffer A_buf (
  .clk      (clk),
  .rst      (rst),		   
  
  .load     (load_a),
  .data_in  (rd1),   	   
  
  .data_out (A_out)
);

B_Buffer B_buf (
  .clk      (clk),
  .rst      (rst),		
  
  .load     (load_b),
  .data_in  (rd2),   
  .data_out (B_out)
);


  
wire [1:0] selB =
(opcode == 6'b000100)                                  ? 2'b01 :  

((opcode == 6'b000101)                                 ? 2'b10 :   

    ((opcode == 6'b000110 || opcode == 6'b000111 ||
	opcode == 6'b001000 || opcode == 6'b001001)        ? 2'b10 :	  
	
                                                             2'b00)); 


    wire [1:0] alu_op_fsm =
         (opcode==6'b000000)?2'b11:
         (opcode==6'b000001)?2'b10:			   
		 
         ((opcode==6'b000010||opcode==6'b000011)?2'b01:		 
		 
         ((opcode==6'b000100||opcode==6'b000101)?2'b11:2'b00));	  
		 

    wire [3:0] alu_operation;
    ALU_Control alu_ctrl (.alu_op(alu_op_fsm), .opcode(opcode), .alu_operation(alu_operation));

   
    wire   [31:0] alu_input_b;

mux4to1 #(32) B_mux (
.in0(B_out),  			  

  .in1(ImmZE),   
  .in2(ImmSE),   			  
  
  .in3(ImmSE),   
  .sel(selB),
  .out(alu_input_b)
);


    wire        zero, neg, pos;
    wire [31:0] alu_result;
    ALU alu_unit (
	.a(A_out), .b(alu_input_b),	   
	
	.alu_op(alu_operation),		
	
	.result(alu_result),		
	
        .zero(zero), .neg(neg), .pos(pos)
    );


    wire [31:0] alu_result_buf;
    ALU_Result_Register alu_out_buf (		
	
	.clk(clk), .rst(rst), .load(load_alu_out),
	
	
        .alu_in(alu_result), .alu_out(alu_result_buf)
    );

  
    wire [31:0] addr0        = alu_result_buf;	
	
    wire [31:0] addr1        = alu_result_buf + 32'd1;
    wire [31:0] dmem_read_data;


 wire [31:0] mem_addr;
  mux2to1 #(32) Addr_mux (
    .in0(addr0),
    .in1(addr1),	 
	
    .sel(state == LDW_UPRD || state == SDW_UPWR),
    .out(mem_addr)
  );

 
  wire [31:0] mem_wdata = B_out;

  DataMemory dmem (
    .clk        (clk),
    .mem_write  (mem_write_fsm),	 
	
    .mem_read   (mem_read_fsm),
    .addr       (mem_addr),
    .write_data (mem_wdata),
    .read_data  (dmem_read_data)
  );
  
  
  
  	  
genvar ri;
generate

  for (ri = 0; ri < 15; ri = ri + 1) begin
    assign regs_out[ri] = regfile.registers[ri];
  end
endgenerate


assign regs_out[15] = pc_out;


genvar mi;
generate
  for (mi = 0; mi < 256; mi = mi + 1) begin
    assign mem_out[mi] = dmem.mem[mi];
  end
endgenerate

  
    wire [31:0] mdr_out;
    MDR_Register mdr_reg (			
	
	
	.clk(clk), .rst(rst), .load(load_mdr), 
	
	
	.DATA_result_in(dmem_read_data),  
	
	
        .DATA_result_out(mdr_out)
    );

    
    reg [31:0] call_ret_addr;
    always @(posedge clk or posedge rst) begin	
		
        if (rst) call_ret_addr <= 32'd0;	  
			
			
        else if (state==EXECUTE && opcode==6'b001111) 
			
			
            call_ret_addr <= PCPlusOne;			
			
    end


wire sel_cll    = (opcode == 6'b001111) && (state == WRITEBACK);  


wire sel_mem    = mem_to_reg_fsm     ||   ((opcode == 6'b001000)  &&   ((state == LDW_LWWR)  ||   (state == LDW_UPWR)));
wire sel_ldw_up = (opcode == 6'b001000) && (state == LDW_UPWR);

wire [31:0] wb_mux1_out;
mux2to1 #(32) WB_mem_mux (		  


  .in0(alu_result_buf),
  .in1(mdr_out),			  
  
  
  .sel(sel_mem),			 
  
  .out(wb_mux1_out)			  
  
  
);

mux2to1 #(32) WB_cll_mux (
.in0(wb_mux1_out),		  

.in1(call_ret_addr),		  

.sel(sel_cll),			  

  .out(write_back_data)
);

wire [3:0] rd_mux1_out;
mux2to1 #(4) RD_ldw_mux (	 

  .in0(rd),
  .in1(rd + 4'd1),			  
  
  .sel(sel_ldw_up),			  
  
  .out(rd_mux1_out)			  
  
);

mux2to1 #(4) RD_cll_mux (
.in0(rd_mux1_out),	   

.in1(4'd14),				

.sel(sel_cll),			

  .out(rd_sel_index)		  
  
);


  


    always @(posedge clk or posedge rst) begin
        if (rst) state <= FETCH;
        else     state <= next_state;
    end

  
    always @(*) begin

        ir_write         = 1'b0;
        load_a           = 1'b0;
        load_b           = 1'b0;
        load_alu_out     = 1'b0;
        load_mdr         = 1'b0;
        reg_write_fsm    = 1'b0;
        mem_read_fsm     = 1'b0;
        mem_write_fsm    = 1'b0;
        mem_to_reg_fsm   = 1'b0;
        pc_write_fsm     = 1'b0;
        pc_src_fsm       = 2'b00;
        next_state       = state;

        case (state)
            FETCH: begin
                ir_write     = 1'b1;
                pc_write_fsm = 1'b1;
                pc_src_fsm   = 2'b00;
                next_state   = DECODE;
            end
DECODE: begin
    load_a = 1'b1;
    load_b = 1'b1;
 
    if ((opcode==6'b001000 && rd[0]) ||
        (opcode==6'b001001 && rt[0]))
        next_state = HALT;
    else
        next_state = EXECUTE;
end


             EXECUTE: begin
    load_alu_out = 1'b1;
   

    case (opcode)
        6'b001010: if (A_out == 32'd0) begin
            pc_write_fsm = 1'b1;
            pc_src_fsm   = 2'b01; 
        end

        6'b001011: if (A_out > 32'd0) begin
            pc_write_fsm = 1'b1;
            pc_src_fsm   = 2'b01;
        end

        6'b001100: if ($signed(A_out) < 0) begin
            pc_write_fsm = 1'b1;
            pc_src_fsm   = 2'b01;
        end

        6'b001101: begin
            pc_write_fsm = 1'b1;
            pc_src_fsm   = 2'b10; 
        end

        6'b001110: begin
            pc_write_fsm = 1'b1;
            pc_src_fsm   = 2'b11; 
        end

        6'b001111: begin
            pc_write_fsm = 1'b1;
            pc_src_fsm   = 2'b11; 
        end

        default: ;
    endcase

    next_state = MEM;
end
            MEM: begin
                case (opcode)
                    6'b000110: begin
						mem_read_fsm=1;	  
						
					load_mdr=1; 
					next_state=WRITEBACK; 
					end 				   
					
                    6'b001000: begin 
					mem_read_fsm=1; 		
					
					load_mdr=1; 
					next_state=LDW_LWWR;	 
					
					
					end   
                    6'b000111: begin 
					mem_write_fsm=1;
					next_state=FETCH;		
					
					end                 
                   6'b001001: begin           
          mem_write_fsm = 1;
        			  load_b        = 1;
          next_state    = SDW_UPWR;
        end             
		default: 
		next_state=WRITEBACK;
                endcase
            end

            LDW_LWRD: 
			begin              
			next_state=FETCH;  
			end
            LDW_LWWR: 
			
			
			begin 
				
				reg_write_fsm=1;
			
				
				mem_to_reg_fsm=1; 
			
				next_state=LDW_UPRD; 
			
			end
           
			LDW_UPRD:  begin
			
				
				mem_read_fsm=1;	
			
			load_mdr=1;    
			
			
			next_state=LDW_UPWR;
			
			
			end
           
			LDW_UPWR: 
			
			
			begin
				reg_write_fsm=1; 
				
			mem_to_reg_fsm=1; 
			next_state=FETCH;   
			end
            SDW_UPWR:
			begin
     mem_write_fsm = 1;
    
      next_state    = FETCH;
    end

            WRITEBACK: begin
                case (opcode)
                    6'b000000,6'b000001,6'b000010,6'b000011,
                    6'b000100,6'b000101:
					reg_write_fsm=1;       
                    6'b000110:           begin 
					reg_write_fsm=1;
					mem_to_reg_fsm=1; 
					end 	 
					
                    6'b001111:      
					reg_write_fsm=1;   
					
                    default: ;	
					
                endcase			   
				
                if (opcode==6'b111111) 
					next_state=HALT;
                else                  
					next_state=FETCH;
            end

            HALT: begin
                next_state = HALT;
            end

            default: next_state = FETCH;
        endcase
    end	  
	

endmodule

