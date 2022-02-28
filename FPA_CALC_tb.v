/*This testbench is designed to test the FPCALC state code. 
-Akashay Singla*/
`timescale 1ns/1ps
module FPADD_tb();
reg clk_34, rst_34;
reg[15:0]Finput1_34,Finput2_34;
wire[15:0]FPsum_34;
wire Ovf_Flag_34,Unf_Flag_34;

fpa_adder u1(clk_34,rst_34,Finput1_34,Finput2_34,FPsum_34,Ovf_Flag_34,Unf_Flag_34);

initial begin
  $dumpfile("FPA_log.vcd");
  $dumpvars;
  #100
  $finish;
end

initial begin
  clk_34 =1'b0;
  rst_34=1'b0;
  #5
  Finput1_34 <= 16'h5620;//98
  Finput2_34 <= 16'h5948;//169
  //output 267 : 5C2C in iEE754
  #10
  Finput1_34 <= 16'h5630;//99
  Finput2_34 <= 16'hD590;//-89
  //output 10 : 4900
 #10
   Finput1_34<= 16'hD1A0; //-45
   Finput2_34<= 16'h54F0;//79
  //output 34: 5040 in iEE754
  #10
  Finput1_34 <= 16'hDC6C;//-283
  Finput2_34 <= 16'hD420;//-66
//output -349: DD74 in iEE75
 #10
  Finput1_34 <= 16'h0000; //0
  Finput2_34 <= 16'h0000;//0
//output =underflow
#10
 Finput1_34 <= 16'h0000;//0
 Finput2_34 <= 16'hD750;//-117
//output -117: D750 in IEEE654 format//

 #10
 Finput1_34 <= 16'hD6E2;//-110.125
 Finput2_34 <= 16'h563E;//99.875
 //output -10.25 : C920

 #10
 Finput1_34 <= 16'h56EE;//110.875
 Finput2_34 <= 16'h5632;//99.125
 //output underflow
//output 210: 5A90
end

always #5 clk_34 =~clk_34;
initial $monitor ("Finput1_34: %h, Finput2_34: %h, FPsum_34: %h, Ovf_Flag_34: %b, Unf_Flag_34: %b",Finput1_34, Finput2_34, FPsum_34, Ovf_Flag_34, Unf_Flag_34);
endmodule
