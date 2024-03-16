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

//      x^4 + a^76*x^3 + a^251*x^2 + a^81*x + a^10
//       8'h01   8'h1e     8'hd8     8'he7     8'h74

parameter G0 = 8'h74 ; // 0x25 ==  37 == 0010 0101   ==  α^36
parameter G1 = 8'he7 ; // 0xe0 == 224 == 01110 0000   ==  α^203
parameter G2 = 8'hd8 ; // 0x08 ==   8 == 0000 1000   ==  α^3
parameter G3 = 8'h1e ; // 0xac == 172 == ?1010 1100?   ==  α^220

reg code_en;            // RS 编码器的活动状态
reg ps_out_en;          // parity symbols 校验字符的输出
reg [2:0] dout_cnt;     // 输出校验字符 计数器 ； 每次共输出8个校验字符
reg [7:0] remainder [3:0];
wire [7:0] product [3:0];
// .a(din_sop?din:din^remainder[3]   的含义是： 第一个din数据进入 不进行 加法器的处理直接进入乘法器。但是除了第一个数据，后续的所有数据都需要跟最后一位寄存器进行加法 再进入乘法器。 
gf256mul mul0(.a(din_sop?din:din^remainder[3]), .b(G0), .z(product[0]));
gf256mul mul1(.a(din_sop?din:din^remainder[3]), .b(G1), .z(product[1]));
gf256mul mul2(.a(din_sop?din:din^remainder[3]), .b(G2), .z(product[2]));
gf256mul mul3(.a(din_sop?din:din^remainder[3]), .b(G3), .z(product[3]));

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin   // 复位寄存器全部置零
  remainder[0] <= 0;
  remainder[1] <= 0;
  remainder[2] <= 0;
  remainder[3] <= 0;
  
end
else if (din_sop)
begin   // 开始输入数据 （第一次输入数据）       RS编码的 加法器 设计
  remainder[0] <= product[0];
  remainder[1] <= product[1];
  remainder[2] <= product[2];
  remainder[3] <= product[3];

end
else if (din_val)
begin   // 持续输入数据                        RS编码的 加法器 设计
  remainder[0] <= product[0] ;
  remainder[1] <= product[1] ^ remainder[0];
  remainder[2] <= product[2] ^ remainder[1];
  remainder[3] <= product[3] ^ remainder[2];

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
  dout_cnt <= 3;
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
