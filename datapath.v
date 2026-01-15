module datapath(input clk, output wire [31:0] ALUout);
//input to the datapath from cp
wire wGPR, wdmem, mux2sel, mux3sel, mux4sel, RegDst, branch;
wire [4:0] control;
wire branch_type,ncond,mux5out;

//wires need to connect
wire [31:0]PCin,PCout,adderout,mux1out,Instr,mux4out,A,B,mux2out,mux3out,extendout,dmemout;
wire cond,branch_taken;
wire [4:0] write_reg;

controlpath cp(.Instr(Instr),.wGPR(wGPR),.wdmem(wdmem),.mux2sel(mux2sel),.mux3sel(mux3sel),.mux4sel(mux4sel),.RegDst(RegDst),.branch(branch),.control(control),.branch_type(branch_type));//instanstiate control path to datapath

//assign branch_taken=cond && branch;
and and1(branch_taken,mux5out,branch);

PC_32bit p1(clk,PCin,PCout);
assign PCin=mux1out;

adder a1(PCout,adderout);
mux32bit m1(ALUout,adderout,branch_taken,mux1out);
IM imem(PCout,Instr);
GPR g1(clk,wGPR,Instr[25:21],Instr[20:16],write_reg,mux4out,A,B);
mux32bit m2(adderout,A,mux2sel,mux2out);
mux32bit m3(extendout,B,mux3sel,mux3out);
sign_extend e1(Instr[15:0],extendout);
ALU a2(mux2out,mux3out,control,ALUout);
mux32bit m4(ALUout,dmemout,mux4sel,mux4out);
dmem d1(clk,wdmem,ALUout,B,dmemout);

assign cond = (A==32'b0);//compare if rs==0 for branch
assign write_reg = RegDst ? Instr[15:11] : Instr[20:16];// musx to differentiate between the register and immediate type of dat
//below code is to implement bneqz
assign ncond=~cond;
assign mux5out=branch_type?cond:ncond;
endmodule