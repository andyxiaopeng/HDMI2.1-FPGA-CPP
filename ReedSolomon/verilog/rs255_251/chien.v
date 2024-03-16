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


// 模块内部工作原理概述：
// 首先，初始化变量和计数器，以及定义三个伽罗华域元素α1、α2、α3作为初始值（其中 a是生成元)
// 使用gf256mul模块计算α的幂次以及错误位置多项式与这些幂次的乘积（term1、term2、term3）。
// 将这些乘积累加得到elp_result，当elp_result为0时，说明找到了一个错误位置。
// 使用error_cnt跟踪已找到的错误数量，byte_cnt作为GF(256)域内指数的循环计数器。
// 当elp_result为0时，根据error_cnt的值将找到的错误位置及对应的伽罗华域元素赋值给输出。
// 控制信号dec_en负责启动和停止整个搜索过程，当start有效且error_num不为0时启动搜索，搜索完指定数量的错误或超出GF(256)的最大指数时停止。



`timescale 1ns/100ps
module chien(
       input clk,
       input rst_n,
       input start,
       input [1:0] error_num,            // number of errors   错误的数量
       input [7:0] elp0,            // elp0, elp1, elp2, elp3：错误位置多项式的系数，这里的模块仅针对最高三次项的系数
       input [7:0] elp1,
       input [7:0] elp2,
       input [7:0] elp3,

       output reg [7:0] el1,        // el1 和 el2：表示找到的第一个和第二个错误位置
       output reg [7:0] el2,

       output reg [7:0] gf_el1,     // gf_el1 和 gf_el2：对应的伽罗华域元素（在GF(256)中）
       output reg [7:0] gf_el2,

       output reg done
       );

reg dec_en;
reg [1:0] error_cnt;            // 已找到的错误数量
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