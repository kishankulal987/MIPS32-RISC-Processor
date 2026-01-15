module tb_datapath();

reg clk;
wire [31:0] ALUout;

datapath dut(
    .clk(clk),
    .ALUout(ALUout)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $display("========================================");
    $display("      SWAP TEST - Compare & Swap");
    $display("========================================\n");
    
    // Show initial values
    #25;
    $display("=== After Setup (PC=2) ===");
    $display("R1 = %d", dut.g1.GPR[1]);
    $display("R2 = %d", dut.g1.GPR[2]);
    
    // After storing to memory
    #20;
    $display("\n=== After Store to Memory (PC=4) ===");
    $display("MEM[0] = %d", dut.d1.RAM[0]);
    $display("MEM[4] = %d", dut.d1.RAM[4]);
    
    // After loading from memory
    #20;
    $display("\n=== After Load from Memory (PC=6) ===");
    $display("R3 = %d (loaded from MEM[0])", dut.g1.GPR[3]);
    $display("R4 = %d (loaded from MEM[4])", dut.g1.GPR[4]);
    
    // After comparison
    #10;
    $display("\n=== After SLT Comparison (PC=7) ===");
    $display("R2 = %d (R3 < R4? %d < %d)", dut.g1.GPR[2], 
             dut.g1.GPR[3], dut.g1.GPR[4]);
    
    // Wait for completion
    #80;
    #1;
    
    $display("\n========================================");
    $display("           FINAL RESULTS");
    $display("========================================");
    $display("\n=== Memory Contents ===");
    $display("MEM[0] = %d (expected: 5 - smaller value)", dut.d1.RAM[0]);
    $display("MEM[4] = %d (expected: 10 - larger value)", dut.d1.RAM[4]);
    
    $display("\n=== Final Register Values ===");
    $display("R6 = %d (loaded from MEM[0])", dut.g1.GPR[6]);
    $display("R7 = %d (loaded from MEM[4])", dut.g1.GPR[7]);
    
    $display("\n========================================");
    
    // Verify sorting
    if (dut.d1.RAM[0] <= dut.d1.RAM[4] &&
        dut.g1.GPR[6] == dut.d1.RAM[0] &&
        dut.g1.GPR[7] == dut.d1.RAM[4]) begin
        $display("? SWAP TEST PASSED");
        $display("Memory is sorted in ascending order!");
    end else begin
        $display("? SWAP TEST FAILED");
    end
    
    $display("========================================\n");
    $finish;
end

// Monitor PC during execution
always @(posedge clk) begin
    if ($time < 150)
        $display("Time=%0t PC=%0d Instr=%h", $time, dut.PCout, dut.Instr);
end

endmodule
