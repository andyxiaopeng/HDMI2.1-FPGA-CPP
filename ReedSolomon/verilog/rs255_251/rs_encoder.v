//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 21:07:19
// Design Name: 
// Module Name: rs_encoder
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


`timescale 1ns/100ps
module rs_encoder(
      input clk,
      input rst_n,
      input din_val,    // �������ݵ���Ч��
      input din_sop,    // ��������Ŀ�ʼ �ź�
      input din_eop,    // ��������Ľ��� �ź�
      input [7:0] din,
      output reg dout_val,  // �������Ч�źţ����� ����λ���� + У��λ���ݣ�
      output reg dout_sop,  // ��������Ŀ�ʼ ��־
      output reg dout_eop,  // ��������Ľ��� ��־       dout_eop ��ʾ RS ��������������ݵĽ���λ�ñ�־
      output reg [7:0] dout,
      output reg busy
      
      );

//      x^4 + a^76*x^3 + a^251*x^2 + a^81*x + a^10
//       8'h01   8'h1e     8'hd8     8'he7     8'h74

parameter G0 = 8'h74 ; // 0x25 ==  37 == 0010 0101   ==  ��^36
parameter G1 = 8'he7 ; // 0xe0 == 224 == 01110 0000   ==  ��^203
parameter G2 = 8'hd8 ; // 0x08 ==   8 == 0000 1000   ==  ��^3
parameter G3 = 8'h1e ; // 0xac == 172 == ?1010 1100?   ==  ��^220

reg code_en;            // RS �������Ļ״̬
reg ps_out_en;          // parity symbols У���ַ������
reg [2:0] dout_cnt;     // ���У���ַ� ������ �� ÿ�ι����8��У���ַ�
reg [7:0] remainder [3:0];
wire [7:0] product [3:0];
// .a(din_sop?din:din^remainder[3]   �ĺ����ǣ� ��һ��din���ݽ��� ������ �ӷ����Ĵ���ֱ�ӽ���˷��������ǳ��˵�һ�����ݣ��������������ݶ���Ҫ�����һλ�Ĵ������мӷ� �ٽ���˷����� 
gf256mul mul0(.a(din_sop?din:din^remainder[3]), .b(G0), .z(product[0]));
gf256mul mul1(.a(din_sop?din:din^remainder[3]), .b(G1), .z(product[1]));
gf256mul mul2(.a(din_sop?din:din^remainder[3]), .b(G2), .z(product[2]));
gf256mul mul3(.a(din_sop?din:din^remainder[3]), .b(G3), .z(product[3]));

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin   // ��λ�Ĵ���ȫ������
  remainder[0] <= 0;
  remainder[1] <= 0;
  remainder[2] <= 0;
  remainder[3] <= 0;
  
end
else if (din_sop)
begin   // ��ʼ�������� ����һ���������ݣ�       RS����� �ӷ��� ���
  remainder[0] <= product[0];
  remainder[1] <= product[1];
  remainder[2] <= product[2];
  remainder[3] <= product[3];

end
else if (din_val)
begin   // ������������                        RS����� �ӷ��� ���
  remainder[0] <= product[0] ;
  remainder[1] <= product[1] ^ remainder[0];
  remainder[2] <= product[2] ^ remainder[1];
  remainder[3] <= product[3] ^ remainder[2];

end


always @(posedge clk or negedge rst_n)
if (!rst_n)
  code_en <= 0;
else if (din_sop)   // �� din_sop �źţ���ʼ��־��Ϊ�ߵ�ƽʱ��code_en ������Ϊ 1����ʾ��ʼ���������ݽ��б���
  code_en <= 1;
else if (din_eop)   //�� din_eop �źţ�������־��Ϊ�ߵ�ƽʱ��code_en ������Ϊ 0����ʾֹͣ����
  code_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  ps_out_en <= 0;
else if (din_eop)       // �� din_eop �źţ�������־��Ϊ�ߵ�ƽʱ��ps_out_en ������Ϊ 1����ʾ���У�����
  ps_out_en <= 1;
else if (dout_cnt == 0) // �� dout_cnt �Ĵ�����ֵ��Ϊ��ʱ��ps_out_en ����Ϊ 1����ȷ���������У����ţ��� dout_cnt �Ĵ�����ֵΪ��ʱ��ps_out_en ����Ϊ 0��ֹͣ���У���ַ�
  ps_out_en <= 0;


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dout_cnt <= 0;
else if (din_eop)   // ��ʼ������ַ����м���
  dout_cnt <= 3;
else if (ps_out_en && (dout_cnt != 0)) // �� ps_out_en �Ĵ���Ϊ 1 �� dout_cnt ��Ϊ��ʱ��dout_cnt �ݼ�����ʾ��ǰ��� У���ַ���
  dout_cnt <= dout_cnt - 1;


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dout_val <= 0;
else if (din_val | ps_out_en)   // �� din_val �źţ�����������Ч��־��Ϊ�ߵ�ƽʱ������ ps_out_en �źţ�У������źţ�Ϊ�ߵ�ƽʱ��dout_val ������Ϊ 1����ʾ������λ׼����Ҫ���
  dout_val <= 1;
else
  dout_val <= 0;

always @(posedge clk or negedge rst_n)  // ��������źŵ����ݣ� ��������� ����λ���ݣ���������� У��λ����
if (!rst_n)
  dout <= 0;
else if (din_val)   // din_val �źţ�����������Ч��־��Ϊ�ߵ�ƽʱ, dout ������Ϊ�������� din ��ֵ
  dout <= din;
else if (ps_out_en) // ps_out_en �źţ�У���ַ� ����źţ�Ϊ�ߵ�ƽʱ��dout ������Ϊ �����Ĵ��� ����Ӧ����
  dout <= remainder[dout_cnt];


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dout_sop <= 0;
else
  dout_sop <= din_sop;      // ����ʼ�����ݽ��룬�ͱ�ʾ�������


always @(posedge clk or negedge rst_n) // dout_eop ָʾ RS ������������ݵĽ���λ��
if (!rst_n)
  dout_eop <= 0;
else if ((dout_cnt == 0) && ps_out_en) // �� dout_cnt ���������㣨dout_cnt == 0���� ps_out_en �źţ�У��λ����źţ�Ϊ�ߵ�ƽʱ��dout_eop ������Ϊ 1����ʾ������ݵ����һ������λ
  dout_eop <= 1;
else
  dout_eop <= 0;

endmodule
