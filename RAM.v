module dmem(input clk,we,input [31:0]ALUout,B,output [31:0]rd);
reg [31:0] RAM [0:63];
assign rd = RAM[ALUout];
always @(posedge clk)
if(we)
RAM[ALUout]<=B;
endmodule