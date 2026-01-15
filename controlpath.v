module controlpath(input [31:0]Instr,output reg wGPR,wdmem,mux2sel,mux3sel,mux4sel,RegDst,branch,branch_type,output reg [4:0]control);

always @(*)//write into GPR if it is R type and I type except branch and SW
begin
case(Instr[31:26])
6'b001001 : wGPR=0;
6'b001101 : wGPR=0;
6'b001110 : wGPR=0;
default : wGPR=1;
endcase
end

always @(*)//set write to data memory only if it is LW
begin
if(Instr[31:26]==6'b001001)
wdmem=1;
else
wdmem=0;
end

always @(*)//set branch into 1 if it is branch instruction
begin
if(Instr[31:26]==6'b001101 || Instr[31:26]==6'b001110)
branch=1;
else
branch=0;
end

always @(*)// set mux2sel 1 if branch instruction
begin
if(branch)
mux2sel=1;
else
mux2sel=0;
end

always @(*)//set mux3sel to 0 and RegDst to 1 for R type instruction else vice versa
begin
if(Instr[29]==1'b1)
begin
mux3sel=1;
RegDst=0;
end
else begin
mux3sel=0;
RegDst=1;
end
end

always @(*)//set mux4sel to 0 if it is LW instruction else 0
begin
if(Instr[31:26]==6'b001000)
mux4sel=0;
else
mux4sel=1;
end

always @(*) //control signal for ALU
begin
case(Instr[31:26])
//R type intruction
6'b000000 : control=5'b00000;
6'b000001 : control=5'b00001;
6'b000010 : control=5'b00010;
6'b000011 : control=5'b00011;
6'b000100 : control=5'b00100;
6'b000101 : control=5'b00101;
//I type instruction
6'b001000 : control=5'b00000;
6'b001001 : control=5'b00000;
6'b001010 : control=5'b00000;
6'b001011 : control=5'b00001;
6'b001100 : control=5'b00100;
6'b001101 : control=5'b00000;
6'b001110 : control=5'b00000;
default : control=5'b00000;
endcase
end

always @(*)// set branch_type to 1 if it is beqz else 0;
begin
if(Instr[31:26]==6'b001110)
branch_type=1;
else
branch_type=0;
end

endmodule