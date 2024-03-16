//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 21:07:19
// Design Name: 
// Module Name: chien
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


// ģ���ڲ�����ԭ�������
// ���ȣ���ʼ�������ͼ��������Լ���������٤�޻���Ԫ�ئ�1����2����3��Ϊ��ʼֵ������ a������Ԫ)
// ʹ��gf256mulģ���������ݴ��Լ�����λ�ö���ʽ����Щ�ݴεĳ˻���term1��term2��term3����
// ����Щ�˻��ۼӵõ�elp_result����elp_resultΪ0ʱ��˵���ҵ���һ������λ�á�
// ʹ��error_cnt�������ҵ��Ĵ���������byte_cnt��ΪGF(256)����ָ����ѭ����������
// ��elp_resultΪ0ʱ������error_cnt��ֵ���ҵ��Ĵ���λ�ü���Ӧ��٤�޻���Ԫ�ظ�ֵ�������
// �����ź�dec_en����������ֹͣ�����������̣���start��Ч��error_num��Ϊ0ʱ����������������ָ�������Ĵ���򳬳�GF(256)�����ָ��ʱֹͣ��



`timescale 1ns/100ps
module chien(
       input clk,
       input rst_n,
       input start,
       input [1:0] error_num,            // number of errors   ���������
       input [7:0] elp0,            // elp0, elp1, elp2, elp3������λ�ö���ʽ��ϵ���������ģ����������������ϵ��
       input [7:0] elp1,
       input [7:0] elp2,
       input [7:0] elp3,

       output reg [7:0] el1,        // el1 �� el2����ʾ�ҵ��ĵ�һ���͵ڶ�������λ��
       output reg [7:0] el2,

       output reg [7:0] gf_el1,     // gf_el1 �� gf_el2����Ӧ��٤�޻���Ԫ�أ���GF(256)�У�
       output reg [7:0] gf_el2,

       output reg done
       );

reg dec_en;
reg [1:0] error_cnt;            // ���ҵ��Ĵ�������
reg [7:0] byte_cnt;
reg [7:0] alpha1, alpha2, alpha3 ;
wire [7:0] palpha1, palpha2, palpha3 ;
wire [7:0] term1, term2, term3 ;
wire [7:0] elp_result;

gf256mul mul1(.a(alpha1), .b(8'h02), .z(palpha1));
gf256mul mul2(.a(alpha2), .b(8'h04), .z(palpha2));
gf256mul mul3(.a(alpha3), .b(8'h08), .z(palpha3));


gf256mul mul5(.a(alpha1), .b(elp1), .z(term1));
gf256mul mul6(.a(alpha2), .b(elp2), .z(term2));
gf256mul mul7(.a(alpha3), .b(elp3), .z(term3));


assign elp_result = elp0 ^ term1 ^ term2 ^ term3 ;

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  alpha1 <= 0;
  alpha2 <= 0;
  alpha3 <= 0;
end
else if (start)
begin
  alpha1 <= 8'h02;  // a^1
  alpha2 <= 8'h04;  // a^2
  alpha3 <= 8'h08;  // a^3
end
else if (dec_en)
begin
  alpha1 <= palpha1;
  alpha2 <= palpha2;
  alpha3 <= palpha3;
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1 <= 0;
  el2 <= 0;
  gf_el1 <= 0;
  gf_el2 <= 0;
  
end
else if (start)
begin
  el1 <= 0;
  el2 <= 0;
  gf_el1 <= 0;
  gf_el2 <= 0;
  
end
else if ((elp_result == 0) && dec_en)
  case(error_cnt)
    0: begin el1 <= byte_cnt;  gf_el1 <= alpha1; end
    1: begin el2 <= byte_cnt;  gf_el2 <= alpha1; end

  endcase

always @(posedge clk or negedge rst_n)
if (!rst_n)
  error_cnt <= 0;
else if (start)
  error_cnt <= 0;
else if ((elp_result == 0) && dec_en)
  error_cnt <= error_cnt + 1;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  byte_cnt <= 0;
else if (start)
  byte_cnt <= 0;
else if (dec_en)
  byte_cnt <= byte_cnt + 1;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  dec_en <= 0;
else if (start & (error_num != 0))
  dec_en <= 1;
else if (((error_cnt == error_num) || (byte_cnt == 8'hfe)))
  dec_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  done <= 0;
else if (start & (error_num == 0))
  done <= 1;
else if (dec_en && ((error_cnt == error_num) || (byte_cnt == 8'hfe)))
  done <= 1;
else
  done <= 0;

endmodule