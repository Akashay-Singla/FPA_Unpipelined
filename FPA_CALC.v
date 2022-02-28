/*This Part of code represents the floating point CALC state and is designed to fetch two 
iEE754 format inputs from Floating Point input 1 and Input 2 state and to perform the 
addition on them by first separating the inputs into sign, exponent and mantissa. It also performs
normalization and checks the underflow and overflow condition.
*/
module fpa_adder(input clk_34,rst_34,
input [15:0]Finput1_34,Finput2_34,
output reg[15:0]FPSUM_34,
output reg Ovf_Flag_34,Unf_Flag_34);

reg [12:0] M1_ST0,M2_ST0,M1_ST1,M2_ST1,M_Final;  //Mantissa Registers of input 1 & 2 
reg [4:0]E1_ST0,E2_ST0,E1_ST1,E2_ST1,E_Final;  //Exponent Registers of input 1 & 2
reg S1_ST0,S2_ST0,S1_ST1,S2_ST1,S_Final;      //Sign bit register of input 1 & 2
reg Bit_Ovf;    //For storing the values for bit overflow condition
reg [14:0] M1_Add,M2_Add,M_Sum,Fsum; //Register for addition
reg [12:0] M1_ST0_temp,M2_ST0_temp;
reg [4:0] E1_ST0_temp, E2_ST0_temp,Temp;

always @(*) begin
 //Separate the input 1 into sign, exponent & mantissa
  S1_ST0 = Finput1_34[15] ;                //Sign bit of input 1
  E1_ST0 = Finput1_34[14:10];              //Exponent bit of input 1
  M1_ST0[11:0] = {Finput1_34[9:0],2'b00};  //Mantissa of input 1 with guard and round bit

 //Separate the input 2 into sign, exponent and mantissa
  S2_ST0 = Finput2_34[15];                 //Sign bit of input2
  E2_ST0 = Finput2_34[14:10];              //Exponent bit of input 2
  M2_ST0[11:0] = {Finput2_34[9:0],2'b00};  //Mantissa of input 2 with guard and round bit 

//Add the prefix bit to both matissa for making 1.XX format
if (Finput1_34 == 0) begin
M1_ST0[12] = 1'b0 ;
end
else begin
M1_ST0[12] = 1'b1 ;
end
if (Finput2_34 == 0) begin
M2_ST0[12] = 1'b0 ;
end
else begin
M2_ST0[12] = 1'b1 ;
end
//Compare the exponents of both inputs

if (E1_ST0 < E2_ST0) begin 
  Temp =  E2_ST0-E1_ST0;//Compare exponent 2 > exponent 1         
  M1_ST1 = M1_ST0>>Temp; 
  M2_ST1 = M2_ST0; //Shift the bits to right by 1 of input1's mantissa
  E1_ST1 = E2_ST0;//Increment the input 1's exponent by 1
end
else begin //compare exponent 1 > exponent 2
  Temp =  E1_ST0-E2_ST0;
  M1_ST1 = M1_ST0;
  M2_ST1 = M2_ST0>>Temp;//Shift the bits to right by 1 of input2's mantissa
  E1_ST1 = E1_ST0;//Increment the input2's exponent by 1
end
  
  S1_ST1 = S1_ST0;      
  S2_ST1 = S2_ST0;

//Adder Stage 
//Mantissa is prefixed by two bit so as not to lose sign bit in case of overflow addition
//Two's complement for the negative number 
M1_Add = (S1_ST1== 1'b1) ? (~{2'b00, M1_ST1}) + 1 : {2'b00, M1_ST1} ;
M2_Add = (S2_ST1 == 1'b1) ? (~{2'b00, M2_ST1}) + 1 : {2'b00, M2_ST1} ; 
M_Sum = M1_Add + M2_Add ;//Addition of Final Mantissa
//If result is negative then perform 2's complement
Fsum = ((M_Sum[14]) == 1'b0) ? M_Sum : ~M_Sum + 1 ;

//Performing normalization & checking the overflow and underflow condition and gives the final output
S_Final = M_Sum[14];  //Fetching the sign bit of final result
//Check the bit overflow condition so that no one will be left in the 
//1st & 3rd bit while transfering into 13 bit mantissa
Bit_Ovf = Fsum[14] ^ Fsum[13] ;    
//If bit overflow is present then shifts the bits of final result to right 
M_Final = (Bit_Ovf==1'b1)? Fsum>>1 : Fsum[12:0]; 
//If bit overflow is present then increments the exponent by 1
E_Final = (Bit_Ovf==1'b1) ? E1_ST1 +1 : E1_ST1;  

//Check the normalization
//Check MSB of M_Final. if it is not 1 then perform the normalization until it comes equal to 1
while (M_Final[12] != 1  && E_Final!=0) begin  
M_Final = M_Final<<1;//Shift the bits of fraction to left by 1
E_Final = E_Final-1;//decrement the exponent by 1
end
end
always@(posedge clk_34 or rst_34) begin
  if(rst_34) begin
  Ovf_Flag_34<=1'b0;
  Unf_Flag_34<=1'b0;
  FPSUM_34 <= 16'h0000;
  end
  else begin
//check the overflow condition (2^5 -1)
if(E_Final == 31) begin                  
  Ovf_Flag_34<= 1'b1; //Raise the overflow flag
  Unf_Flag_34<=1'b0;  //Pull down the underflow flag
  FPSUM_34 <= 16'h0000; //No result
end

//Check the underflow condititon
else if (E_Final == 5'b00000) begin
  Unf_Flag_34 <=1'b1; //Raise the underflow flag
  Ovf_Flag_34 <=1'b0; //Pull down the overflow flag
  FPSUM_34 <= 16'h0000;  //No result
end

//if no overflow and underflow condition is present, then gives the final result
else  begin
  Ovf_Flag_34 <=1'b0;  //Pull down the overflow flag
  Unf_Flag_34 <= 1'b0; //Pull down the underflow flag
  FPSUM_34 <= {S_Final,E_Final,M_Final[11:2]}; //Concatinate Sign,Exponent & Mantissa
  end
end
end
endmodule

 
