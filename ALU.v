module ALU(input [31:0]A,B,input[4:0]control,output reg [31:0]out);
always @(*)
begin
case(control)
5'b00000 : begin//ADD
            out=A+B;
            end
5'b00001 : begin//SUB
            out=A-B;
            end 
5'b00010 : begin//AND
            out=A&B;
            end
5'b00011 : begin//OR
            out=A|B;
            end
5'b00100 : begin//SLT
            out = (A < B) ? 32'b1 : 32'b0;
            end
5'b00101 : begin//MUL
            out=A*B;
            end
default : out=0;
endcase
end
endmodule