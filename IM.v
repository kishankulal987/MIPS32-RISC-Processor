module IM(input [31:0] PC,output [31:0] Instr);
    reg [31:0] RAM [63:0];
    integer i;
    initial begin

        for (i = 0; i < 64; i = i + 1)
            RAM[i] = 32'h0; // Initialize to 0
        $readmemh("D:/new volume/100daysRTL/RISC MISP 32/RISC MISP 32.srcs/sources_1/new/memfile.dat", RAM);
        $display("Loaded memfile.dat into instruction memory");
    end
    assign Instr = RAM[PC];
endmodule