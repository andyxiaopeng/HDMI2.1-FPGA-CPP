`timescale 1ns/100ps
module syndrome(
       input clk,
       input rst_n,
       input din_val,
       input din_sop,
       input din_eop,
       input [7:0] din,
       output reg syndrome_val,
       output reg [7:0] syndrome1,
       output reg [7:0] syndrome2,
       output reg [7:0] syndrome3,
       output reg [7:0] syndrome4,
       output reg [7:0] syndrome5,
       output reg [7:0] syndrome6,
       output reg [7:0] syndrome7,
       output reg [7:0] syndrome8
       );



// syndrome s = r(x) = r0 + r1*x + r2*x^2 + ... + r_n-1*x^(n-1)
//                   = (((r_n-1*x + r_n-2)*x + r_n-3)*x + ...+ r1)*x + r0

wire [7:0] sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8 ;

gf256mul mul1(.a(8'h02), .b(syndrome1), .z(sp1));
gf256mul mul2(.a(8'h04), .b(syndrome2), .z(sp2));
gf256mul mul3(.a(8'h08), .b(syndrome3), .z(sp3));
gf256mul mul4(.a(8'h10), .b(syndrome4), .z(sp4));
gf256mul mul5(.a(8'h20), .b(syndrome5), .z(sp5));
gf256mul mul6(.a(8'h40), .b(syndrome6), .z(sp6));
gf256mul mul7(.a(8'h80), .b(syndrome7), .z(sp7));
gf256mul mul8(.a(8'h1d), .b(syndrome8), .z(sp8));
/*
    十六进制    十进制     二进制                 幂数值
    2           2           0000 0010               1
    4           4           0000 0100               2
    8           8           0000 1000               3
    10          16          0001 0000               4
    20          32          0010 0000               5
    40          64          0100 0000               6
    80          128         1000 0000               7
    1d          29          0001 1101               8
*/

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin   // 复位信号启动，s寄存器赋值为0
  syndrome1 <= 0;
  syndrome2 <= 0;
  syndrome3 <= 0;
  syndrome4 <= 0;
  syndrome5 <= 0;
  syndrome6 <= 0;
  syndrome7 <= 0;
  syndrome8 <= 0;
end
else if (din_val)   // 输入数据有效信号
  if (din_sop)      // 是 输入数据的第一位
  begin
    syndrome1 <=  din;
    syndrome2 <=  din;
    syndrome3 <=  din;
    syndrome4 <=  din;
    syndrome5 <=  din;
    syndrome6 <=  din;
    syndrome7 <=  din;
    syndrome8 <=  din;
  end
  else              // 不是 输入数据的第一位
  begin // 加法器实现
    syndrome1 <= sp1 ^ din;
    syndrome2 <= sp2 ^ din;
    syndrome3 <= sp3 ^ din;
    syndrome4 <= sp4 ^ din;
    syndrome5 <= sp5 ^ din;
    syndrome6 <= sp6 ^ din;
    syndrome7 <= sp7 ^ din;
    syndrome8 <= sp8 ^ din;
  end

always @(posedge clk or negedge rst_n)
if (!rst_n)
  syndrome_val <= 0;
else
  syndrome_val <= din_eop;



endmodule