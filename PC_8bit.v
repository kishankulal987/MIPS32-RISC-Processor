module PC_32bit(input clk,input [31:0]inp,output reg [31:0]out);
always @(posedge clk)
begin
out<=inp;
end

initial begin
    out = 32'h00000000;
end

endmodule