`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.12.2025 17:45:09
// Design Name: 
// Module Name: TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module TB();
 reg clk, rst;
 integer k;
 wire [12:0]register_2_values;
 pipe_MIPS32 dut(.clk(clk), .register_2_values(register_2_values ), .rst(rst));
 
 always #5 clk = ~clk;
 // clock declaration:
 initial begin
    rst = 1'b1;
    clk = 1'b0;
 end
 
 initial begin
    #2 rst = 1'b0;
    
    
   // #2000
    
   // $display(" Mem[200]:%d whereas Mem[198]:%d", dut.Mem[200], dut.Mem[198]);
    
    
 end
 
    initial begin 
    $monitor ("R2: %d", register_2_values);
    #3000 $finish;  end
    endmodule
