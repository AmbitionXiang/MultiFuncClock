`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/26 10:47:33
// Design Name: 
// Module Name: clock
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


module clock(iclk,key1,key2,key3,key4,key5,key6,led0,led1,led2,led3,led4,
    led5,led6,led7,led8,led9,led10,led11,led12,led13,led14,led15,
    r1,g1,b1,r2,g2,b2,
    seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0,
    segA,segB,segC,segD,segE,segF,segG,segP
    );
    parameter STATE_WID = 4;
    parameter S0 = 4'b0000;   //时间显示状态
    parameter S1 = 4'b0001;   //日期显示状态
    parameter S2 = 4'b0010;   //调整时间：时
    parameter S3 = 4'b0011;   //调整时间：分
    parameter S4 = 4'b0100;   //调整时间：秒
    parameter S5 = 4'b0101;   //设置日期：年
    parameter S6 = 4'b0110;   //设置日期：月
    parameter S7 = 4'b0111;   //设置日期：日
    parameter S8 = 4'b1000;   //设置闹钟1：时
    parameter S9 = 4'b1001;   //设置闹钟1：分
    parameter S10 = 4'b1010;   //设置闹钟2：时
    parameter S11 = 4'b1011;   //设置闹钟2：分
    parameter S12 = 4'b1100;   //设置闹钟3：时
    parameter S13 = 4'b1101;   //设置闹钟3：分
    parameter S14 = 4'b1110;   //设置倒计时：分
    parameter S15 = 4'b1111;   //设置倒计时：秒
    input iclk;
    input key1,key2,key3,key4,key5,key6;
    output reg led0,led1,led2,led3,led4,led5,led6,led7,led8,led9,led10,led11,led12,led13,led14,led15;
    output reg r1,g1,b1,r2,g2,b2;  //2个三色led,r1闹钟灯,r2倒计时灯
    output reg seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0;   //8个数码管
    output reg segA,segB,segC,segD,segE,segF,segG,segP;  //每个数码管中的8段
    
    wire [15:0] pre_dis,year_dis,month_dis,day_dis,H_dis,M_dis,S_dis;   //dis结构：高8位-十位，低8位-个位。每八位从高到低对应segP~segA
    wire [15:0] s_year_dis,s_month_dis,s_day_dis,s_H_dis,s_M_dis,s_S_dis;
    wire [15:0] s_H1_dis,s_M1_dis,s_H2_dis,s_M2_dis,s_H3_dis,s_M3_dis;
    wire [15:0] s_M4_dis,s_S4_dis,M_down_dis,S_down_dis; 
    wire [2:0] q;  //模8计数器输出 
    wire co;       //模8计数器计数满符号
    
    wire [7:0] year,month,day,H,M,S;
    
    reg [7:0] s_year,s_month,s_day,s_H,s_M,s_S; //s->set
    reg [7:0] s_H1,s_M1,s_H2,s_M2,s_H3,s_M3;   //3个闹钟的时/分设置
    reg [7:0] s_M4,s_S4,M_down,S_down;   //倒计时分/秒设置，倒计时分/秒
    wire [7:0] day_max;
    
    reg [STATE_WID-1:0] state_c;  //当前状态
    reg [STATE_WID-1:0] state_n;  //下个状态
    
    reg alarm1,alarm2,alarm3;    //闹钟响标志
    reg [7:0] alarm_count1,alarm_count2,alarm_count3;       //闹钟持续计时
    
    reg count_down, pause;                //倒计时是否已经开始,是否暂停。
    reg [7:0] down_count;             //倒计时结束后计5秒 用于led闪烁
    wire rst_n,load;              //105036abcd
    wire clk_1Hz,clk_2Hz,clk_1000Hz,clk_50MHz;
    reg odevity;
    assign rst_n = key1;
    assign load = key6 && (!state_c[3]) && (state_c[2]||state_c[1]);  //设置日期和时间并按下确定
    
    int_div #(100000000,32) nclk1(iclk,clk_1Hz);     //计时时钟
    int_div #(50000000,32) nclk2(iclk,clk_2Hz);      //灯闪烁时钟
    int_div #(100000,32) nclk1000(iclk,clk_1000Hz);  //数码管动态显示时钟
    int_div #(2,32) nclk50_000_000(iclk,clk_50MHz);  //按键消抖时钟
    myclock u1(clk_1Hz,rst_n,load,s_year,s_month,s_day,s_H,s_M,s_S,year,month,day,H,M,S);       //获取时间(高电平复位)
    disp_dec PreYear(8'd20,pre_dis);              
    disp_dec Year(year,year_dis);                 //日期显示
    disp_dec Month(month,month_dis);
    disp_dec Day(day,day_dis);
    disp_dec Hour(H,H_dis);                      //时间显示
    disp_dec Minute(M,M_dis);
    disp_dec Second(S,S_dis);      
    disp_dec SetYear(s_year,s_year_dis);                 //设置的日期显示
    disp_dec SetMonth(s_month,s_month_dis);
    disp_dec SetDay(s_day,s_day_dis);
    disp_dec SetHour(s_H,s_H_dis);                      //设置的时间显示
    disp_dec SetMinute(s_M,s_M_dis);
    disp_dec SetSecond(s_S,s_S_dis);                 
    disp_dec SetHour1(s_H1,s_H1_dis);                      //设置闹钟1 时间显示
    disp_dec SetMinute1(s_M1,s_M1_dis);
    disp_dec SetHour2(s_H2,s_H2_dis);                      //设置闹钟2 时间显示
    disp_dec SetMinute2(s_M2,s_M2_dis);
    disp_dec SetHour3(s_H3,s_H3_dis);                      //设置闹钟3 时间显示
    disp_dec SetMinute3(s_M3,s_M3_dis);
    disp_dec SetMinute4(s_M4,s_M4_dis);                      //设置倒计时 时间显示
    disp_dec SetSecond4(s_S4,s_S4_dis);
    disp_dec SetMinuteDown(M_down,M_down_dis);                      //实际倒计时 时间显示
    disp_dec SetSecondDown(S_down,S_down_dis);
    days_per_month w2(clk_2Hz,s_month,s_year,day_max);    //获取每月的最大天数
    counter_sync_r c(clk_1000Hz,rst_n,q,co);        //模8计数器 
    
    always @(posedge clk_1000Hz)                     //数码管动态扫描
        begin
            case(state_c)
                S0:
                    case(q)
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= H_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= H_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= M_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= M_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        3'd1:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= S_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111101;
                        end
                        3'd0:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= S_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111110;
                        end
                        default:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00111111;
                        end
                    endcase
                S1:
                    case(q)
                        3'd7:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= pre_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b01111111;
                        end
                        3'd6:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= pre_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b10111111;
                        end
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= year_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= year_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= month_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= month_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        3'd1:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= day_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111101;
                        end
                        3'd0:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= day_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111110;
                        end
                    endcase
                S2,S3,S4:
                    case(q)
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        3'd1:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_S_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111101;
                        end
                        3'd0:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_S_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111110;
                        end
                        default:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00111111;
                        end
                    endcase
                S5,S6,S7:
                    case(q)
                        3'd7:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= pre_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b01111111;
                        end
                        3'd6:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= pre_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b10111111;
                        end
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_year_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_year_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_month_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_month_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        3'd1:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_day_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111101;
                        end
                        3'd0:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_day_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111110;
                        end
                    endcase              
                S8,S9:
                    case(q)
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H1_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H1_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M1_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M1_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        default:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00111100;
                        end
                    endcase
                S10,S11:
                    case(q)
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H2_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H2_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M2_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M2_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        default:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00111100;
                        end
                    endcase
                S12,S13:
                    case(q)
                        3'd5:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H3_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11011111;
                        end
                        3'd4:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_H3_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11101111;
                        end
                        3'd3:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M3_dis[15:8];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                        end
                        3'd2:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M3_dis[7:0];
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                        end
                        default:begin
                            {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                            {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00111100;
                        end
                    endcase                
                S14,S15:
                    if(count_down == 0)
                        begin
                            case(q)
                                3'd3:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M4_dis[15:8];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                                end
                                3'd2:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= s_M4_dis[7:0];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                                end
                                3'd1:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= s_S4_dis[15:8];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111101;
                                end
                                3'd0:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= s_S4_dis[7:0];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111110;
                                end
                                default:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00001111;
                                end
                            endcase  
                        end  
                    else
                        begin
                            case(q)
                                3'd3:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= M_down_dis[15:8];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11110111;
                                end
                                3'd2:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= M_down_dis[7:0];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111011;
                                end
                                3'd1:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= S_down_dis[15:8];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111101;
                                end
                                3'd0:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} <= S_down_dis[7:0];
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} <= 8'b11111110;
                                end
                                default:begin
                                    {segP,segG,segF,segE,segD,segC,segB,segA} = 8'b11111111;
                                    {seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0} = 8'b00001111;
                                end
                            endcase                        
                        end            
            endcase
        end
    always @(posedge clk_2Hz)               //闹钟灯闪烁
        begin
            if(!rst_n)
                begin
                    r1 = 0;
                    g1 = 0;
                    b1 = 0;
                end
            else
                begin
                    if((alarm1&&alarm_count1>8'd15)||(alarm2&&alarm_count2>8'd15)||(alarm3&&alarm_count3>8'd15))
                        r1 = ~r1;
                    else if((alarm1 && alarm_count1>8'd0 && alarm_count1<=8'd5)||(alarm2 && alarm_count2>8'd0 && alarm_count2<=8'd5)||(alarm3 && alarm_count3>8'd0 && alarm_count3<=8'd5))
                        r1 = ~r1;
                    else 
                        r1 = 0;
                end
        end
    always @(posedge clk_2Hz)                       //倒计时灯闪烁
        begin
            if(!rst_n)
                begin
                    r2 = 0;
                    g2 = 0;
                    b2 = 0;
                end
            else
                begin
                    if(down_count > 0)
                        r2 = ~r2;
                    else
                        r2 = 0;
                    if(count_down ==1)
                        g2 = 1;
                    else
                        g2 = 0;
                end
        end
    always @(posedge clk_2Hz)   //奇偶分频
        odevity <= odevity + 1;
    always @(posedge clk_2Hz)  //切换功能
        begin
            if(!rst_n)
                begin
                    state_c<=S0;        //状态转换用
                    state_n<=S1;
                    alarm1 <= 0;         //闹钟用
                    alarm2 <= 0;
                    alarm3 <= 0;
                    alarm_count1 <= 0;
                    alarm_count2 <= 0;
                    alarm_count3 <= 0;
                    pause <= 0;        //倒计时用
                    count_down <= 0;
                    down_count <= 0;
                    s_H1 <= 0;s_M1 <= 0;s_H2 <= 0;s_M2 <= 0;s_H3 <= 0;s_M3 <= 0;
                    s_M4 <= 0;s_S4 <= 0;
                end
            if(key2)
                begin
                    state_c<=state_n;
                    if(state_n == S15)
                        state_n<= S0;
                    else
                        state_n<=state_n+1;
                end
            if(key3)
                begin
                    if(state_c == S14 || state_c == S15)
                        begin 
                            count_down <=1;   //倒计时开始
                            M_down <= s_M4;
                            S_down <= s_S4; 
                            pause <= 0;
                        end    
                end
            if(key4)
                begin
                    if(alarm1&& (alarm_count1> 8'd15))
                        begin
                            alarm_count1 <= 0;   //5秒内按解除键，停止响动
                        end
                    if(alarm2&& (alarm_count2> 8'd15))
                        begin
                            alarm_count2 <= 0;   //5秒内按解除键，停止响动
                        end
                    if(alarm3&& (alarm_count3> 8'd15))
                        begin
                            alarm_count3 <= 0;   //5秒内按解除键，停止响动
                        end
                    if((state_c == S14 || state_c == S15) && count_down == 0)
                        begin
                            count_down <=1;   //倒计时开始
                            M_down <= s_M4;
                            S_down <= s_S4;
                            pause <= 0;
                        end
                    if((state_c == S14 || state_c == S15) && count_down == 1 && pause == 0)  //开始后暂停
                        pause <= 1; 
                    if((state_c == S14 || state_c == S15) && count_down == 1 && pause == 1)  //暂停后继续开始
                        pause <= 0;
                end
            if(key5)
                begin
                    case(state_c)
                        S2: 
                            begin
                                if(s_H == 8'd23)
                                    s_H <= 8'd0;
                                else
                                    s_H <= s_H+1'b1;
                            end
                        S3:
                            begin
                                if(s_M == 8'd59)
                                    s_M <= 8'd0;
                                else
                                    s_M <= s_M+1'b1;
                            end
                        S4:
                            begin
                                if(s_S == 8'd59)
                                    s_S <= 8'd0;
                                else
                                    s_S <= s_S+1'b1;
                            end
                        S5:
                            begin
                                if(s_year == 8'd99)
                                    s_year <= 0;
                                else
                                    s_year <= s_year+1'b1;
                            end
                        S6:
                            begin
                                if(s_month == 8'd12)
                                    s_month <= 0;
                                else
                                    s_month <= s_month+1'b1;
                            end
                        S7:
                            begin
                                if(s_day == day_max)
                                    s_day <= 0;
                                else 
                                    s_day <= s_day+ 1'b1;
                            end
                        S8:
                            begin
                                if(s_H1 == 8'd23)
                                    s_H1 <= 8'd0;
                                else
                                    s_H1 <= s_H1+1'b1;
                            end
                        S9:
                            begin
                                if(s_M1 == 8'd59)
                                    s_M1 <= 8'd0;
                                else 
                                    s_M1 <= s_M1+1'b1;
                            end
                        S10:
                            begin
                                if(s_H2 == 8'd23)
                                    s_H2 <= 8'd0;
                                else
                                    s_H2 <= s_H2+1'b1;
                            end
                        S11:
                            begin
                                if(s_M2 == 8'd59)
                                    s_M2 <= 8'd0;
                                else 
                                    s_M2 <= s_M2+1'b1;
                            end                
                        S12:
                            begin
                                if(s_H3 == 8'd23)
                                    s_H3 <= 8'd0;
                                else
                                    s_H3 <= s_H3+1'b1;
                            end
                        S13:
                            begin
                                if(s_M3 == 8'd59)
                                    s_M3 <= 8'd0;
                                else 
                                    s_M3 <= s_M3+1'b1;
                            end
                        S14:
                            begin
                                if(s_M4 == 8'd59)
                                    s_M4 <= 8'd0;
                                else 
                                    s_M4 <= s_M4+1'b1;
                            end
                        S15:
                            begin
                                if(s_S4 == 8'd59)
                                    s_S4 <= 8'd0;
                                else 
                                    s_S4 <= s_S4+1'b1;                       
                            end
                        default: begin end
                    endcase
                end
            if(key6)
                begin
                    if(state_c == S8 || state_c == S9)
                        alarm_count1 <= 20;
                    if(state_c == S10 || state_c == S11)
                        alarm_count2 <= 20;  
                    if(state_c == S12 || state_c == S13)
                        alarm_count3 <= 20;   
                end
            if(state_c == S1)
                begin
                    s_year <= year;s_month <= month;s_day <= day;s_H <= H;s_M <= M;s_S <= S;
                end
            if(!odevity)            //1HZ
                begin
                    if(s_H1 == H && s_M1 == M && alarm_count1>8'd0)    //闹钟部分
                        begin
                            alarm1 <= 1;
                            alarm_count1 <= alarm_count1 - 1'b1;
                        end
                    if(s_H2 == H && s_M2 == M && alarm_count2>8'd0)
                        begin
                            alarm2 <= 1;
                            alarm_count2 <= alarm_count2 - 1'b1;
                        end
                    if(s_H3 == H && s_M3 == M && alarm_count3>8'd0)
                        begin
                            alarm3 <= 1;
                            alarm_count3 <= alarm_count3 - 1'b1;
                        end
                    if(s_H1 != H || s_M1 != M)
                        begin
                            alarm1 <= 0;
                        end
                    if(s_H2 != H || s_M2 != M)
                        begin
                            alarm2 <= 0;
                        end
                    if(s_H3 != H || s_M3 != M)
                        begin
                            alarm3 <= 0;
                        end
                    //倒计时部分
                    if(count_down == 1 && pause == 0)    //倒计时开始且不暂停，就计时
                        begin
                            if(S_down == 8'd0 && M_down == 8'd0)
                                begin
                                    count_down <= 0;       //倒计时结束
                                    down_count <= 5;
                                end
                            else if(S_down == 8'd0)
                                begin
                                    S_down <= 8'd59;
                                    M_down <= M_down - 1'b1;
                                end
                            else
                                S_down <= S_down - 1'b1;
                        end
                    if(down_count > 0)
                        down_count <= down_count - 1'b1;
                end
        end
    always @(state_c)
        begin
            case(state_c)
                S0: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0000_0001;
                S1: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0000_0010;
                S2: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0000_0100;
                S3: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0000_1000;
                S4: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0001_0000;
                S5: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0010_0000;
                S6: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_0100_0000;
                S7: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0000_1000_0000;
                S8: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0001_0000_0000;
                S9: {led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0010_0000_0000;
                S10:{led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_0100_0000_0000;
                S11:{led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0000_1000_0000_0000;
                S12:{led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0001_0000_0000_0000;
                S13:{led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0010_0000_0000_0000;
                S14:{led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b0100_0000_0000_0000;
                S15:{led15,led14,led13,led12,led11,led10,led9,led8,led7,led6,led5,led4,led3,led2,led1,led0} <= 16'b1000_0000_0000_0000;
            endcase
        end
endmodule
