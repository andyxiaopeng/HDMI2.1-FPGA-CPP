// RS (N = 255, K = 247, 2T = 8 �� T = 4)         Ҳ����˵������247��8bit�� �ַ���Ȼ��ֹͣ����
// The Primitive Polynomial over GF(256) is  p(x) = x^8 + x^4 + x^3 + x^2 + 1
//
// g(x) �����ɶ���ʽ  �� g(x)���� 2T �������ģ�Ҳ����˵ �������������������ɶ���ʽ

// g(x) = (x+a)(x+a^2)(x+a^3)(x+a^4)(x+a^5)(x+a^6)(x+a^7)(x+a^8) ��μ���õ� x^8 + a^176*x^7 + a^240*x^6 + a^211*x^5 + a^253*x^4 + a^220*x^3 + a^3*x^2 + a^203*x + a^36 ���ڱʼǱ��м�����̵�����

// g(x) = (x+a)(x+a^2)(x+a^3)(x+a^4)(x+a^5)(x+a^6)(x+a^7)(x+a^8)
//      = x^8 + a^176*x^7 + a^240*x^6 + a^211*x^5 + a^253*x^4 + a^220*x^3 + a^3*x^2 + a^203*x + a^36
//      ���������Ħ������ݴ�  �ٽ�� �����ݴ���������ʾ���ñ�����б���ѧ ������ ˶ʿ���ĸ�¼�пɲ飩
// ���磺 ��^36 ����GF��256��Ԫ�ص��ݱ�ʾ��ͨ��������֪�� ��Ԫ�ص�������ʾΪ 0010 0101
//                                      0010 0101 �Ķ����Ʊ�ʾΪ 0x25 �� 8'h25

//          ͬ����^240  ==  0010 1100  == 0x2c == 8'h2c

//              8'he3       8'h2c       8'hb2       8'h47       8'hac       8'h08     8'he0     8'h25


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

// x^8 + a^176*x^7 + a^240*x^6 + a^211*x^5 + a^253*x^4 + a^220*x^3 + a^3*x^2 + a^203*x + a^36
//        8'he3       8'h2c       8'hb2       8'h47       8'hac       8'h08     8'he0     8'h25
parameter G0 = 8'h25 ; // 0x25 ==  37 == 0010 0101   ==  ��^36
parameter G1 = 8'he0 ; // 0xe0 == 224 == ?1110 0000?   ==  ��^203
parameter G2 = 8'h08 ; // 0x08 ==   8 == 0000 1000   ==  ��^3
parameter G3 = 8'hac ; // 0xac == 172 == ?1010 1100?   ==  ��^220
parameter G4 = 8'h47 ; // 0x47 ==  71 == ?0100 0111?   ==  ��^253
parameter G5 = 8'hb2 ; // 0xb2 == 178 == ?1011 0010?   ==  ��^211
parameter G6 = 8'h2c ; // 0x2c ==  44 == ?0010 1100?   ==  ��^240
parameter G7 = 8'he3 ; // 0xe3 == 227 == ?1110 0011?   ==  ��^176

reg code_en;            // RS �������Ļ״̬
reg ps_out_en;          // parity symbols У���ַ������
reg [2:0] dout_cnt;     // ���У���ַ� ������ �� ÿ�ι����8��У���ַ�
reg [7:0] remainder [7:0];
wire [7:0] product [7:0];
// .a(din_sop?din:din^remainder[7]   �ĺ����ǣ� ��һ��din���ݽ��� ������ �ӷ����Ĵ���ֱ�ӽ���˷��������ǳ��˵�һ�����ݣ��������������ݶ���Ҫ�����һλ�Ĵ������мӷ� �ٽ���˷����� 
gf256mul mul0(.a(din_sop?din:din^remainder[7]), .b(G0), .z(product[0]));
gf256mul mul1(.a(din_sop?din:din^remainder[7]), .b(G1), .z(product[1]));
gf256mul mul2(.a(din_sop?din:din^remainder[7]), .b(G2), .z(product[2]));
gf256mul mul3(.a(din_sop?din:din^remainder[7]), .b(G3), .z(product[3]));
gf256mul mul4(.a(din_sop?din:din^remainder[7]), .b(G4), .z(product[4]));
gf256mul mul5(.a(din_sop?din:din^remainder[7]), .b(G5), .z(product[5]));
gf256mul mul6(.a(din_sop?din:din^remainder[7]), .b(G6), .z(product[6]));
gf256mul mul7(.a(din_sop?din:din^remainder[7]), .b(G7), .z(product[7]));

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin   // ��λ�Ĵ���ȫ������
  remainder[0] <= 0;
  remainder[1] <= 0;
  remainder[2] <= 0;
  remainder[3] <= 0;
  remainder[4] <= 0;
  remainder[5] <= 0;
  remainder[6] <= 0;
  remainder[7] <= 0;
end
else if (din_sop)
begin   // ��ʼ�������� ����һ���������ݣ�       RS����� �ӷ��� ���
  remainder[0] <= product[0];
  remainder[1] <= product[1];
  remainder[2] <= product[2];
  remainder[3] <= product[3];
  remainder[4] <= product[4];
  remainder[5] <= product[5];
  remainder[6] <= product[6];
  remainder[7] <= product[7];
end
else if (din_val)
begin   // ������������                        RS����� �ӷ��� ���
  remainder[0] <= product[0] ;
  remainder[1] <= product[1] ^ remainder[0];
  remainder[2] <= product[2] ^ remainder[1];
  remainder[3] <= product[3] ^ remainder[2];
  remainder[4] <= product[4] ^ remainder[3];
  remainder[5] <= product[5] ^ remainder[4];
  remainder[6] <= product[6] ^ remainder[5];
  remainder[7] <= product[7] ^ remainder[6];
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
  dout_cnt <= 7;
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