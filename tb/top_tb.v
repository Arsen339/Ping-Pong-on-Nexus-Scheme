`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2021 16:14:32
// Design Name: 
// Module Name: top_tb
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


module top_tb();
    reg clk;
    reg resetn;
    reg newClk;
    reg       [15:0]      SW;
    wire      [15:0]      LED;
    wire                  DP;
    wire      [7:0]       AN;
    wire      [6:0]       C;
    top dut(
        .clk(clk),
        .resetn(resetn),
        .SW(SW),
        .LED(LED),
        .DP(DP),
        .AN(AN),
        .C(C)
    );
    initial begin
        clk = 'b1;
        forever begin
            #10 clk = ~clk;
        end
    end
    initial begin
        resetn = 'b0;
        #100;
        resetn = 'b1;
    end
endmodule
