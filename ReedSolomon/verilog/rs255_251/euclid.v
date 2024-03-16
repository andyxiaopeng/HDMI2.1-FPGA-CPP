//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 21:07:19
// Design Name: 
// Module Name: euclid
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
module euclid(
       input clk,
       input rst_n,
       input start,             // 启动信号
       input [7:0] syndrome1,   //
       input [7:0] syndrome2,
       input [7:0] syndrome3,
       input [7:0] syndrome4,
       output reg [7:0] elp0,   // elp0至elp4: 输出的纠错向量（Error Locator Polynomial）
       output reg [7:0] elp1,
       output reg [7:0] elp2,
       output reg [7:0] elp3,
       output reg [7:0] evp0,   // evp0至evp4: 输出的错误值向量（Error Value Polynomial）
       output reg [7:0] evp1,
       output reg [7:0] evp2,
       output reg [7:0] evp3,
       output reg [1:0] error_num,  // 输出的实际纠正的错误数量。
       output reg done,         // 完成信号, 高电平表示纠错过程已经完成，无论是成功纠正还是因无法纠正而终止
       output reg fail          // 失败信号，高电平表示纠错过程中未能成功找到并纠正所有的错误。
       );

parameter T = 3'h2;     // 代表的是纠错能力或设计指定的最大可纠正错误数量，或者是与编码长度相关的参数

reg dec_en;                         // 解码使能信号，控制纠错过程的启动。
reg div_ok, div_en;                 // div_ok: 除法完成标志,表明当前的除法步骤已经完成且找到了合适的误差位置; div_en: 除法器使能信号，开启基于Berlekamp-Massey算法或其他相关算法的除法操作以求得误差位置多项式。
reg div_shift_en, div_remainder_en; // div_shift_en: 除法移位使能，用于在除法过程中逐位移位。div_remainder_en: 除法余数检查使能，当余数为零时表明当前的误差位置可能正确。
reg mul_ok;                         // 乘法完成标志，表示GF(256)域内的多项式乘法已完成。
reg [2:0] div_cnt;                  // 除法计数器，记录除法迭代的次数。
reg [2:0] devp_2, devp_1, devp;     // devp、devp_1、devp_2: 这些变量用来跟踪和更新潜在的 最大错误位置数
reg [2:0] delp_2, delp_1, delp;     // delp、delp_1、delp_2: 这些变量可能与最终纠错时纠正的 错误位置数 有关。
reg [3:0] dqp;                      // 好像没有使用；
reg [7:0] evp   [3:0];              // 错误值多项式
reg [7:0] evp_1 [3:0];              
reg [7:0] evp_2 [4:0];              
reg [7:0] qp   [4:0];               // qp、qp_1: 可能与生成多项式或者其他中间计算相关的变量。
reg [7:0] qp_1 [4:0];               
reg [7:0] elp   [3:0];              // elp、elp_1、elp_2: 错误定位多项式 。
reg [7:0] elp_1 [3:0];              
reg [7:0] elp_2 [3:0];              
wire done_flag;                     // 
wire fail_flag;                     // 

// # 整体代码 第一感觉是状态机



always @(posedge clk or negedge rst_n)
if (!rst_n)
  devp <= 0;
else if (start)
  devp <= 0;
else if (div_ok)
  if (devp_1 == 4)
    if (evp[3] != 0)
      devp <= 3;
    else if (evp[2] != 0)
      devp <= 2;
    else if (evp[1] != 0)
      devp <= 1;
    else
      devp <= 0;
  else if (devp_1 == 3)
    if (evp[2] != 0)
      devp <= 2;
    else if (evp[1] != 0)
      devp <= 1;
    else
      devp <= 0;
  else if (devp_1 == 2)
    if (evp[1] != 0)
      devp <= 1;
    else
      devp <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  devp_1 <= 0;
end
else if (start)
  if (syndrome4 != 0)
    devp_1 <= 3;
  else if (syndrome3 != 0)
    devp_1 <= 2;
  else if (syndrome2 != 0)
    devp_1 <= 1;
  else if (syndrome1 != 0)
    devp_1 <= 0;
  else
    devp_1 <= 0;
else if (div_ok)
  if (devp_1 == 3)
    if (evp[2] != 0)
      devp_1 <= 2;
    else if (evp[1] != 0)
      devp_1 <= 1;
    else
      devp_1 <= 0;
  else if (devp_1 == 2)
    if (evp[1] != 0)
      devp_1 <= 1;
    else
      devp_1 <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  devp_2 <= 0;
else if (start)
  devp_2 <= T << 1;
else if (div_ok)
  devp_2 <= devp_1;

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  evp_2[0] <= 0;
  evp_2[1] <= 0;
  evp_2[2] <= 0;
  evp_2[3] <= 0;
  evp_2[4] <= 0;
end
else if (start)
begin
  evp_2[0] <= 0;
  evp_2[1] <= 0;
  evp_2[2] <= 0;
  evp_2[3] <= 0;
  evp_2[4] <= 1;
end
else if (mul_ok)
begin
  evp_2[0] <= evp_1[0];
  evp_2[1] <= evp_1[1];
  evp_2[2] <= evp_1[2];
  evp_2[3] <= evp_1[3];
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  evp_1[0] <= 0;
  evp_1[1] <= 0;
  evp_1[2] <= 0;
  evp_1[3] <= 0;
end
else if (start)
begin
  evp_1[0] <= syndrome1;
  evp_1[1] <= syndrome2;
  evp_1[2] <= syndrome3;
  evp_1[3] <= syndrome4;
end
else if (mul_ok)
begin
  evp_1[0] <= evp[0];
  evp_1[1] <= evp[1];
  evp_1[2] <= evp[2];
  evp_1[3] <= evp[3];
end

wire [7:0] evp_p0, evp_p1, evp_p2, evp_p3 ;
wire [7:0] qp_p0;
wire [7:0] inv_evp_1;
gf256inv inv1(.a(evp_1[devp_1]), .z(inv_evp_1));
gf256mul mul8(.a(inv_evp_1), .b(evp[devp_1-1] ^ evp_2[devp_2-div_cnt]), .z(qp_p0));

gf256mul mul0(.a(evp_1[0]), .b(qp_p0), .z(evp_p0));
gf256mul mul1(.a(evp_1[1]), .b(qp_p0), .z(evp_p1));
gf256mul mul2(.a(evp_1[2]), .b(qp_p0), .z(evp_p2));


//gf256mul mul7(.a(evp_1[devp_1]), .b(evp[devp_1-1] ^ evp_2[div_cnt]), .z(evp_p0));

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  evp[0] <= 0;
  evp[1] <= 0;
  evp[2] <= 0;
  evp[3] <= 0;
end
else if (start | (mul_ok & ~done_flag))
begin
  evp[0] <= 0;
  evp[1] <= 0;
  evp[2] <= 0;
  evp[3] <= 0;
end
else if (div_en)  // # 可能这里是除法电路
  if (div_remainder_en)
  begin
    evp[0] <= evp[0] ^ evp_2[0];
    evp[1] <= evp[1] ^ evp_2[1];
    evp[2] <= evp[2] ^ evp_2[2];
  end
  else if (div_shift_en)
  begin
    evp[0] <= evp_p0 ;
    evp[1] <= evp_p1 ^ evp[0];
    evp[2] <= evp_p2 ^ evp[1];
  end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  qp[0] <= 0;
  qp[1] <= 0;
  qp[2] <= 0;
  qp[3] <= 0;
end
else if (start | div_ok)
begin
  qp[0] <= 0;
  qp[1] <= 0;
  qp[2] <= 0;
  qp[3] <= 0;

end
else if (div_shift_en)
begin
  qp[0] <= qp_p0;
  qp[1] <= qp[0];
  qp[2] <= qp[1];
  qp[3] <= qp[2];

end

always @(posedge clk or negedge rst_n)
if (!rst_n)
  delp <= 0;
else if (start)
  delp <= 0;
else if (div_ok)
  delp <= (T << 1) - devp_1; // 按照左移规则，高位会被丢弃，低位补0

always @(posedge clk or negedge rst_n)
if (!rst_n)
  delp_1 <= 0;
else if (start)
  delp_1 <= 0;
else if (div_ok)
  delp_1 <= delp;


wire [7:0] elp_p00, elp_p10, elp_p11, elp_p20, elp_p21, elp_p22, elp_p30 ;
wire [7:0] elp_p31, elp_p32, elp_p33 ;


gf256mul mul9 (.a(qp[0]), .b(elp_1[0]), .z(elp_p00));
gf256mul mul10(.a(qp[0]), .b(elp_1[1]), .z(elp_p10));
gf256mul mul14(.a(qp[1]), .b(elp_1[0]), .z(elp_p11));
gf256mul mul11(.a(qp[0]), .b(elp_1[2]), .z(elp_p20));
gf256mul mul16(.a(qp[2]), .b(elp_1[0]), .z(elp_p21));
gf256mul mul19(.a(qp[1]), .b(elp_1[1]), .z(elp_p22));
gf256mul mul12(.a(qp[0]), .b(elp_1[3]), .z(elp_p30));
gf256mul mul17(.a(qp[3]), .b(elp_1[0]), .z(elp_p31));
gf256mul mul20(.a(qp[1]), .b(elp_1[2]), .z(elp_p32));
gf256mul mul22(.a(qp[2]), .b(elp_1[1]), .z(elp_p33));
//gf256mul mul13(.a(qp[0]), .b(elp_1[4]), .z(elp_p40));
//gf256mul mul18(.a(qp[4]), .b(elp_1[0]), .z(elp_p41));
//gf256mul mul21(.a(qp[1]), .b(elp_1[3]), .z(elp_p42));
//gf256mul mul23(.a(qp[3]), .b(elp_1[1]), .z(elp_p43));
//gf256mul mul24(.a(qp[2]), .b(elp_1[2]), .z(elp_p44));

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  elp[0] <= 0;
  elp[1] <= 0;
  elp[2] <= 0;
  elp[3] <= 0;

end
else if (start)
begin
  elp[0] <= 0;
  elp[1] <= 0;
  elp[2] <= 0;
  elp[3] <= 0;

end
else if (div_ok)
begin
  elp[0] <= elp_2[0] ^ elp_p00 ;
  elp[1] <= elp_2[1] ^ elp_p10 ^ elp_p11;
  elp[2] <= elp_2[2] ^ elp_p20 ^ elp_p21 ^ elp_p22 ;
  elp[3] <= elp_2[3] ^ elp_p30 ^ elp_p31 ^ elp_p32 ^ elp_p33 ;
  // elp[4] <= elp_2[4] ^ elp_p40 ^ elp_p41 ^ elp_p42 ^ elp_p43 ^ elp_p44 ;
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  elp_1[0] <= 0;
  elp_1[1] <= 0;
  elp_1[2] <= 0;
  elp_1[3] <= 0;

end
else if (start)
begin
  elp_1[0] <= 1; // # 第一位置为 1
  elp_1[1] <= 0;
  elp_1[2] <= 0;
  elp_1[3] <= 0;

end
else if (mul_ok)
begin
  elp_1[0] <= elp[0];
  elp_1[1] <= elp[1];
  elp_1[2] <= elp[2];
  elp_1[3] <= elp[3];
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  elp_2[0] <= 0;
  elp_2[1] <= 0;
  elp_2[2] <= 0;
  elp_2[3] <= 0;
end
else if (start)
begin
  elp_2[0] <= 0;
  elp_2[1] <= 0;
  elp_2[2] <= 0;
  elp_2[3] <= 0;
end
else if (mul_ok)
begin
  elp_2[0] <= elp_1[0];
  elp_2[1] <= elp_1[1];
  elp_2[2] <= elp_1[2];
  elp_2[3] <= elp_1[3];
end





/****************************************** Controller *********************************************/

assign done_flag = (T >= delp) && (delp > devp);
assign fail_flag = T < delp;
wire syndrome_zero = |(syndrome1 | syndrome2 | syndrome3 | syndrome4 );


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dec_en <= 0;
else if (start & syndrome_zero)
  dec_en <= 1;
else if (done)
  dec_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  div_en <= 0;
else if (start | (mul_ok && ~(done_flag | fail_flag)))
  div_en <= 1;
else if (div_cnt == (devp_2 - devp_1 + 1))
  div_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  div_shift_en <= 0;
else if (start | (mul_ok & ~done_flag))
  div_shift_en <= 1;
else if (div_en && (div_cnt == (devp_2 - devp_1)))
  div_shift_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  div_remainder_en <= 0;
else if (div_en && (div_cnt == (devp_2 - devp_1)))
  div_remainder_en <= 1;
else
  div_remainder_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  div_ok <= 0;
else
  div_ok <= div_remainder_en;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  div_cnt <= 0;
else if (start | (mul_ok & ~done_flag))
  div_cnt <= 0;
else if (div_en)
  div_cnt <= div_cnt + 1;


always @(posedge clk or negedge rst_n)
if (!rst_n)
  mul_ok <= 0;
else
  mul_ok <= div_ok;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  done <= 0;
else if ((start & ~syndrome_zero) | (mul_ok & (done_flag | fail_flag)))  // # 解码结束的条件：1、开启信号和s无0信号  2、乘法ok 和 （XXXX）
  done <= 1;
else
  done <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  fail <= 0;
else if (start)
  fail <= 0;
else if (mul_ok & fail_flag)
  fail <= 1;
else
  fail <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  error_num <= 0;
else if (start)
  error_num <= 0;
else if (mul_ok)
  error_num <= delp;


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  elp0 <= 0;
  elp1 <= 0;
  elp2 <= 0;
  elp3 <= 0;

  evp0 <= 0;
  evp1 <= 0;
  evp2 <= 0;
  evp3 <= 0;
end
else if (mul_ok)
begin
  elp0 <= elp[0];
  elp1 <= elp[1];
  elp2 <= elp[2];
  elp3 <= elp[3];

  evp0 <= evp[0];
  evp1 <= evp[1];
  evp2 <= evp[2];
  evp3 <= evp[3];
end


/****************************************** Chien *********************************************/


endmodule