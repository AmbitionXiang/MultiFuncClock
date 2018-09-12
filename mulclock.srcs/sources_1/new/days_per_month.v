`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/26 09:28:32
// Design Name: 
// Module Name: days_per_month
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


module days_per_month(
    input clk,
    input [7:0] month,    //1-12
    input [7:0] year,    //0-99
    output reg [7:0] num       //1-31
    );
    reg[1:0] remainder;
    always@(posedge clk)
        begin
            case(month)
                8'd1: num=8'd31;
                8'd2:
                    begin
                        remainder = year%8'd4;
                        if(remainder == 8'd0)   //»ÚƒÍ
                            num=8'd29;
                        else
                            num=8'd28;
                    end
                8'd3: num=8'd31;
                8'd4: num=8'd30;
                8'd5: num=8'd31;
                8'd6: num=8'd30;
                8'd7: num=8'd31;
                8'd8: num=8'd31;
                8'd9: num=8'd30;
                8'd10:num=8'd31;
                8'd11:num=8'd30;
                8'd12:num=8'd31;
                default: begin end
            endcase
        end
endmodule
