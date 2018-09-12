`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/26 10:32:41
// Design Name: 
// Module Name: key_debounce
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


module key_debounce(in_key,clk,clr,out_key);                  //°´¼üÏû¶¶
    input in_key,clk,clr;
    output out_key;
    reg delay1,delay2,delay3;
    always@( posedge clk)//CLK 50M
        begin
            if(clr == 0)
               begin
                   delay1  <= 0;
                   delay2  <= 0;
                   delay3  <= 0; 
               end
            else
               begin
                   delay1  <= in_key; 
                   delay2  <= delay1;
                   delay3  <= delay2;
               end
        end
assign out_key = delay1&delay2&delay3;
endmodule