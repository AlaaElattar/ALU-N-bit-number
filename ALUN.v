/* Alaa Mahmoud Ebrahim		20190105
   Rana Ihab Ahmed			20190207
   Omar Khaled Alhaj		20190351
   Group:CS-S2
*/

`define NUM_BITS 4

module mux4(output d, input s1, input s2, input a3, input a2, input a1, input a0);
	wire [3:0] temp;
	and(temp[3], a3, s1, s2);
	and(temp[2], a2, ~s1, s2);
	and(temp[1], a1, s1, ~s2);
	and(temp[0], a0, ~s1, ~s2);
	or(d, temp[3], temp[2], temp[1], temp[0]);
endmodule

module mux2(output d, input s1, input a1, input a0);
	wire [1:0] temp;
	and(temp[0], a0, ~s1);
	and(temp[1], a1, s1);
	or(d, temp[1], temp[0]);
endmodule


module half_adder(sum, carry, a, b);
   input a, b;
   output sum, carry;
   xor(sum, a, b);
   and(carry, a, b);
endmodule

module full_adder(sum, carry, x, y, z);
   input x, y, z;
   output sum, carry;
   wire s1, c1, c2;
   half_adder h1(s1, c1, x, y);
   half_adder h2(sum, c2, s1, z);
   or(carry, c1, c2);
endmodule

module arithmeticCircuit(output[N+1:0]D, input[N:0]A, input[N:0]B, input s1, input s2);
   parameter N = `NUM_BITS-1;	//3
   wire [N +1:0] carry;
   wire [N:0] out;
   xor(carry[0],s1,s2);

   generate 
   genvar i; 
   for(i=0;i<=N;i=i+1)
   begin
	  mux4 m(out[i], s1, s2, 1'b1, 1'b0, ~B[i], B[i]);
   	  full_adder f(D[i], carry[i+1], carry[i], A[i], out[i]);     	
   end
   endgenerate   
   
   buf(D[N+1], carry[N+1]); 
endmodule

module logicCircuit(input s1, input s2, input [N:0]a, input [N:0]b, output [N + 1:0]outArray);
	//s2 s1
	//00 = XOR, 10 = OR, 01 = XOR, 11 = AND
	parameter N = `NUM_BITS-1;
	wire[N:0] TEMP;
	wire[N:0] AND;
	wire[N:0] OR;
	wire[N:0] XOR;
	//
	generate
	genvar i;
	for(i=0;i<=N;i=i+1)
	begin
      and(AND[i], a[i], b[i]);
	end
	endgenerate
	//
	generate
	for(i=0;i<=N;i=i+1)
	begin
      or(OR[i], a[i], b[i]);
	end
	endgenerate
	//
	generate
	for(i=0;i<=N;i=i+1)
	begin
      xor(XOR[i], a[i], b[i]);
	end
	endgenerate
	//
	generate
	for(i=0;i<=N;i=i+1)
	begin
      mux2 m1(TEMP[i], s1, AND[i], OR[i]);
	end
	endgenerate
	//
	generate
	for(i=0;i<=N;i=i+1)
	begin
      mux2 m2(outArray[i], s2, TEMP[i], XOR[i]);
	end
	endgenerate
	//
	buf(outArray[N + 1], 0);
endmodule

module rightShift(output [N+1:0]o, input [N:0]a);
	parameter N = `NUM_BITS-1;
	buf(o[N], a[N]);
	generate
	genvar i;
	for(i=0;i<=N-1;i=i+1)
	begin
		buf(o[i], a[i+1]);
	end
	endgenerate
	buf(o[N+1], a[N]);
endmodule

module ALU(output [N+1:0]o, input [N:0]a, input [N:0]b, input s4, input s3, input s2, input s1);
	parameter N = `NUM_BITS-1;
	
	wire [N+1:0] ar;
	arithmeticCircuit arc(ar, a, b, s1, s2);
	wire [N+1:0]l;
	logicCircuit Logic(s1, s2, a, b, l);
	wire [N+1:0]shift;
	rightShift r(shift, a);
	wire [N+1:0]temp;
	
	generate
	genvar i;
	for(i=0;i<=N+1;i=i+1)
	begin
		mux2 m8(temp[i], s3, l[i], ar[i]);
		mux2 m9(o[i], s4, shift[i], temp[i]);
	end
	endgenerate
	
	//s4  s3
	//0	   0	arithmetic
	//0	   1	logic
	//1	   x	shift	
endmodule
	

module main();
   parameter N = `NUM_BITS-1;
   wire [N:0] A = 4'b0110;
   wire s1 = 0;
   wire s2 = 0;
   wire s3 = 0;
   wire s4 = 0;
   wire [N+1:0]d;
   wire [N:0]b = 4'b0111;
   //0110
   //0111
   
   ALU a(d, A, b, s4, s3, s2, s1);
   initial
   begin
		if(N==4)
			$monitor("d[5]=%b, d[4]=%b, d[3]=%b, d[2]=%b, d[1]=%b, d[0]=%b", d[5], d[4], d[3], d[2], d[1], d[0]);
		if(N==3)
			$monitor("d[4]=%b, d[3]=%b, d[2]=%b, d[1]=%b, d[0]=%b", d[4], d[3], d[2], d[1], d[0]);
		if(N==2)
			$monitor("d[3]=%b, d[2]=%b, d[1]=%b, d[0]=%b", d[3], d[2], d[1], d[0]);
		if(N==1)
			$monitor("d[2]=%b, d[1]=%b, d[0]=%b", d[2], d[1], d[0]);
		if(N==0)
			$monitor("d[1]=%b, d[0]=%b", d[1], d[0]);
      
   end 
endmodule
