module GPR(input clk,wGPR,
               input [4:0]rs,rt,rd,
               input  [31:0]wd,
               output  [31:0]rd1,rd2);// 32 bit output data
               
reg [31:0] GPR [0:31];


integer i;

// Initialize all registers to 0
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        GPR[i] = 32'h00000000;
    end
end

always @(posedge clk) begin
    if(wGPR && rd != 5'b00000) begin  // Don't write to R0
        GPR[rd] <= wd;
    end
end

assign rd1 =GPR[rs];
assign rd2 =GPR[rt];

endmodule