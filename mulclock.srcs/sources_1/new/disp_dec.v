`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/25 21:21:01
// Design Name: 
// Module Name: disp_dec
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


module disp_dec(
    input [7:0] hex,   //8λ��������������
    output [15:0] dispout  //2λʮ���������߶ζ�����ʾ����
    );
    reg[7:0] dec;
    
    always@(hex)
        begin
            dec[7:4] = hex/4'd10;
            dec[3:0] = hex%4'd10;
        end
    dual_hex u1(1'b0,dec,dispout);  //����2λ�������߶���ʾģ��
endmodule
