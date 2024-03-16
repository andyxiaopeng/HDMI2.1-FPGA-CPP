// RS (N = 255, K = 247, 2T = 8 ， T = 4)         也就是说，输入247个8bit的 字符，然后停止输入
// The Primitive Polynomial over GF(256) is  p(x) = x^8 + x^4 + x^3 + x^2 + 1
//
// g(x) 是生成多项式  ， g(x)是由 2T 来决定的，也就是说 冗余块的数量决定了生成多项式

// g(x) = (x+a)(x+a^2)(x+a^3)(x+a^4)(x+a^5)(x+a^6)(x+a^7)(x+a^8) 如何计算得到 x^8 + a^176*x^7 + a^240*x^6 + a^211*x^5 + a^253*x^4 + a^220*x^3 + a^3*x^2 + a^203*x + a^36 ？在笔记本有计算过程的推演

// g(x) = (x+a)(x+a^2)(x+a^3)(x+a^4)(x+a^5)(x+a^6)(x+a^7)(x+a^8)
//      = x^8 + a^176*x^7 + a^240*x^6 + a^211*x^5 + a^253*x^4 + a^220*x^3 + a^3*x^2 + a^203*x + a^36
//      根据上述的α及其幂次  再结合 α的幂次与向量表示表（该表格在中北大学 刘梦欣 硕士论文附录中可查）
// 例如： α^36 这是GF（256）元素的幂表示，通过查表可以知道 该元素的向量表示为 0010 0101
//                                      0010 0101 的二进制表示为 0x25 即 8'h25

//          同理，α^240  ==  0010 1100  == 0x2c == 8'h2c

//              8'he3       8'h2c       8'hb2       8'h47       8'hac       8'h08     8'he0     8'h25


`timescale 1ns/100ps
module rs_encoder(
      input clk,
      input rst_n,
      input din_val,    // 输入数据的有效性
      input din_sop,    // 数据输入的开始 信号
      input din_eop,    // 数据输入的结束 信号
      input [7:0] din,
      output reg dout_val,  // 输出的有效信号（包括 数据位数据 + 校验位数据）
      output reg dout_sop,  // 数据输出的开始 标志
      output reg dout_eop,  // 数据输出的结束 标志       dout_eop 表示 RS 编码器的输出数据的结束位置标志
      output reg [7:0] dout,
      output reg busy
      
      );

// x^8 + a^176*x^7 + a^240*x^6 + a^211*x^5 + a^253*x^4 + a^220*x^3 + a^3*x^2 + a^203*x + a^36
//        8'he3       8'h2c       8'hb2       8'h47       8'hac       8'h08     8'he0     8'h25
parameter G0 = 8'h25 ; // 0x25 ==  37 == 0010 0101   ==  α^36
parameter G1 = 8'he0 ; // 0xe0 == 224 == ?1110 0000?   ==  α^203
parameter G2 = 8'h08 ; // 0x08 ==   8 == 0000 1000   ==  α^3
parameter G3 = 8'hac ; // 0xac == 172 == ?1010 1100?   ==  α^220
parameter G4 = 8'h47 ; // 0x47 ==  71 == ?0100 0111?   ==  α^253
parameter G5 = 8'hb2 ; // 0xb2 == 178 == ?1011 0010?   ==  α^211
parameter G6 = 8'h2c ; // 0x2c ==  44 == ?0010 1100?   ==  α^240
parameter G7 = 8'he3 ; // 0xe3 == 227 == ?1110 0011?   ==  α^176

reg code_en;            // RS 编码器的活动状态
reg ps_out_en;          // parity symbols 校验字符的输出
reg [2:0] dout_cnt;     // 输出校验字符 计数器 ； 每次共输出8个校验字符
reg [7:0] remainder [7:0];
wire [7:0] product [7:0];
// .a(din_sop?din:din^remainder[7]   的含义是： 第一个din数据进入 不进行 加法器的处理直接进入乘法器。但是除了第一个数据，后续的所有数据都需要跟最后一位寄存器进行加法 再进入乘法器。 
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
begin   // 复位寄存器全部置零
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
begin   // 开始输入数据 （第一次输入数据）       RS编码的 加法器 设计
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
begin   // 持续输入数据                        RS编码的 加法器 设计
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
else if (din_sop)   // 当 din_sop 信号（起始标志）为高电平时，code_en 被设置为 1，表示开始对输入数据进行编码
  code_en <= 1;
else if (din_eop)   //当 din_eop 信号（结束标志）为高电平时，code_en 被设置为 0，表示停止编码
  code_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  ps_out_en <= 0;
else if (din_eop)       // 当 din_eop 信号（结束标志）为高电平时，ps_out_en 被设置为 1，表示输出校验符号
  ps_out_en <= 1;
else if (dout_cnt == 0) // 当 dout_cnt 寄存器的值不为零时，ps_out_en 保持为 1，以确保连续输出校验符号；当 dout_cnt 寄存器的值为零时，ps_out_en 保持为 0，停止输出校验字符
  ps_out_en <= 0;


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dout_cnt <= 0;
else if (din_eop)   // 开始对输出字符进行计数
  dout_cnt <= 7;
else if (ps_out_en && (dout_cnt != 0)) // 当 ps_out_en 寄存器为 1 且 dout_cnt 不为零时，dout_cnt 递减，表示当前输出 校验字符。
  dout_cnt <= dout_cnt - 1;


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dout_val <= 0;
else if (din_val | ps_out_en)   // 当 din_val 信号（输入数据有效标志）为高电平时，或者 ps_out_en 信号（校验输出信号）为高电平时，dout_val 被设置为 1，表示有数据位准备好要输出
  dout_val <= 1;
else
  dout_val <= 0;

always @(posedge clk or negedge rst_n)  // 决定输出信号的数据， 可以是输出 数据位数据，可以是输出 校验位数据
if (!rst_n)
  dout <= 0;
else if (din_val)   // din_val 信号（输入数据有效标志）为高电平时, dout 被设置为输入数据 din 的值
  dout <= din;
else if (ps_out_en) // ps_out_en 信号（校验字符 输出信号）为高电平时，dout 被设置为 余数寄存器 的相应数据
  dout <= remainder[dout_cnt];


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dout_sop <= 0;
else
  dout_sop <= din_sop;      // 当开始有数据进入，就表示有输出了


always @(posedge clk or negedge rst_n) // dout_eop 指示 RS 编码器输出数据的结束位置
if (!rst_n)
  dout_eop <= 0;
else if ((dout_cnt == 0) && ps_out_en) // 当 dout_cnt 计数器归零（dout_cnt == 0）且 ps_out_en 信号（校验位输出信号）为高电平时，dout_eop 被设置为 1，表示输出数据的最后一个数据位
  dout_eop <= 1;
else
  dout_eop <= 0;

endmodule