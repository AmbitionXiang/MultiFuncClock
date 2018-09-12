`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/26 00:10:07
// Design Name: 
// Module Name: myclock
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


module myclock(                                     //正常计时状态
    input CLK,
    input rst,
    input load,
    input [7:0] s_year,
    input [7:0] s_month,
    input [7:0] s_day,
    input [7:0] s_H,
    input [7:0] s_M,
    input [7:0] s_S,
    output [7:0] year,
    output [7:0] month,
    output [7:0] day,
    output [7:0] H,
    output [7:0] M,
    output [7:0] S
    );

    reg[7:0] m_H,m_M,m_S;
    reg[7:0] m_year;
    reg[7:0] m_month;
    reg[7:0] m_day;
    wire [7:0] day_max;
    assign year = m_year;
    assign month = m_month;
    assign day = m_day;
    assign H = m_H;                  
    assign M = m_M;
    assign S = m_S;
    days_per_month w(CLK,m_month,m_year,day_max);  //获取每月的最大天数
    always@(posedge CLK)
        begin
            if(~rst)                //复位
                begin
                    m_year<=0;
                    m_month<=1;
                    m_day<=1;
                    m_H<=0;
                    m_M<=0;
                    m_S<=0;
                end
            else if(load)        //同步置数
                begin
                    m_year<=s_year;
                    m_month<=s_month;
                    m_day<=s_day;
                    m_H<=s_H;
                    m_M<=s_M;
                    m_S<=s_S;
                end
            else
                begin
                    if(m_S==8'd59)
                            begin
                                m_S<=8'd0;
                                if(m_M==8'd59)
                                    begin
                                        m_M<=8'd0;
                                        if(m_H==8'd23)
                                            begin
                                                m_H<=8'd0;
                                                if(m_day==day_max)
                                                    begin
                                                        m_day<=6'd1;
                                                        if(m_month==4'd12)
                                                            begin
                                                                m_month<=4'd1;
                                                                if(m_year==8'd99)
                                                                    m_year<=8'd0;
                                                                else
                                                                    m_year<=m_year+1'b1;
                                                            end
                                                        else
                                                            m_month<=m_month+1'b1;
                                                    end
                                                else
                                                    m_day<=m_day+1'b1;
                                            end
                                        else
                                            m_H<=m_H+1'b1;
                                    end
                                else
                                    m_M<=m_M+8'd1;
                            end
                        else
                            m_S<=m_S+8'd1;                
                end 
        end        
endmodule
