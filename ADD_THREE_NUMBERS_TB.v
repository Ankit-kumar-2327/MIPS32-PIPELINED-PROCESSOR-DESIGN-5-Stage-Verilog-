module Testbench_MIPS32;
reg clk1,clk2;
integer k;
MIPS32 mips32(.clk1(clk1),.clk2(clk2));
initial begin
    clk1 = 0 ; clk2 = 0;
    repeat(20)
    begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
    end
end
initial begin
    for(k=0 ; k<31 ; k++)
       mips32.Reg[k] = k;

       mips32.Memory[0] = 32'h2801000a;
       mips32.Memory[1] = 32'h28020014;
       mips32.Memory[2] = 32'h28030019;
       mips32.Memory[3] = 32'h00222000;
       mips32.Memory[4] = 32'h0c373800; // dummy instruction Handling data hazard
       mips32.Memory[5] = 32'h00832800;
       mips32.Memory[6] = 32'hfc000000;

       mips32.HALTED       = 0;
       mips32.PC           = 0;
       mips32.TAKEN_BRANCH = 0;

       #200
       for(k=0; k<6; k++)
       $display ("R%1d =  %2d",k,mips32.Reg[k]);
end
initial begin
    $dumpfile("ADD_THREE_NUMBER.vcd");
    $dumpvars(0,Testbench_MIPS32);
    #350 $finish;
end
endmodule