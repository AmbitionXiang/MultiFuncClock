`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/28 13:55:55
// Design Name: 
// Module Name: testbench
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


module testbench();

reg iclk;
  reg key1,key2,key3,key4,key5,key6;
 wire led0,led1,led2,led3,led4,led5,led6,led7,led8,led9,led10,led11,led12,led13,led14,led15;
      wire r1,g1,b1,r2,g2,b2;   //2个三色led,r1闹钟灯,r2倒计时灯
       wire seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0;   //8个数码管
       wire segA,segB,segC,segD,segE,segF,segG,segP;  //每个数码管中的8段
  
     initial
     begin
    #0 key1=0;
      key2=0;
    key3=0;
    key4=0;
    key5=0;
    key6=0;
    #100 key1=1;
   #110 key1=0;
   #120 key1=1;
   #130 key1=0;
   /* #1000 key2=1;
    #1100 key2=0;
    #1200 key2=1;
    #1300 key5=1;
    forever 
    #10 key5=~key5;*/
   #200 key2=1;
   #250 key2=0;
   #300 key2=1;
   #350 key2=0;
   #400 key2=1;
    
     end
           
    initial
    begin
    #0 iclk=0;
    forever
    #10 iclk=~iclk;
  
    end
initial
begin

 end



 clock inst(iclk,key1,key2,key3,key4,key5,key6,led0,led1,led2,led3,led4,
    led5,led6,led7,led8,led9,led10,led11,led12,led13,led14,led15,
    r1,g1,b1,r2,g2,b2,
    seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0,
    segA,segB,segC,segD,segE,segF,segG,segP
    );
endmodule

