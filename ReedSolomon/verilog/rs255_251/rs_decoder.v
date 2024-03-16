//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 21:07:19
// Design Name: 
// Module Name: rs_decoder
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
module rs_decoder(
      input clk,
      input rst_n,
      input din_val,        // 数据有效信号。指示输入数据有效，当此信号为高时，表示din端口上的数据可以用来进行解码处理。
      input din_sop,        // 数据开始信号。标记输入数据流的起始包头，表明一个新的数据块开始传输。
      input din_eop,        // 数据结束信号。标记输入数据流的结束包尾，表明当前数据块传输结束。
      input [7:0] din,      // 输入数据信号。这是待解码的实际数据字节流。
      output [7:0] el1,     // el1/el2/el3/el4: 输出纠正后的数据位，代表纠正后数据的四个部分。
      output [7:0] el2,

      output [7:0] ev1,     // ev1/ev2/ev3/ev4: 计算出的具体错误值，分别对应于纠正后的el1至el4中的错误。
      output [7:0] ev2,

      output [1:0] error_num,   // 输出错误数量，表示在数据中检测到并纠正了多少个错误。
      output dec_done,      // 解码完成信号。当解码过程全部结束且没有发生解码失败时，此信号变高。 由dec_done2和其他信号（如euclid_ok）共同决定
      output dec_fail,      // 解码失败信号。若解码过程中无法正确找出或纠正错误，此信号变高。
      output busy           // 忙碌状态信号。高电平通常表示解码器正在处理数据，低电平则表示可以接收新的输入数据。

      );

wire syndrome_val;          // 表示伴随式计算已完成，并且结果可用。
wire dec_done2;             // 表示解码过程的第二阶段完成，也就是在Forney算法单元（u_forney）完成纠错之后的完成信号
wire euclid_ok;             // 表示欧几里得算法单元（u_euclid）执行成功,即已经成功地找到了错误位置和错误值多项式
wire [7:0] syndrome1, syndrome2, syndrome3, syndrome4, syndrome5, syndrome6, syndrome7, syndrome8 ; // 伴随式数组，存储每一步计算得到的伴随式值。
wire [7:0] elp0, elp1, elp2, elp3, elp4 ;   // 表示 错误位置多项式 的系数。
wire [7:0] evp0, evp1, evp2, evp3, evp4 ;   // 表示 错误值多项式 的系数。
wire [7:0] gf_el1, gf_el2, gf_el3, gf_el4 ; // 错误位置对应的伽罗华域元素，用于最终错误值计算。

assign dec_done = dec_done2 | (dec_fail  & euclid_ok);

syndrome u_syndrome(
       .clk          (clk         ) ,
       .rst_n        (rst_n       ) ,
       .din_val      (din_val     ) ,
       .din_sop      (din_sop     ) ,
       .din_eop      (din_eop     ) ,
       .din          (din         ) ,
       .syndrome_val (syndrome_val) ,
       .syndrome1    (syndrome1   ) ,
       .syndrome2    (syndrome2   ) ,
       .syndrome3    (syndrome3   ) ,
       .syndrome4    (syndrome4   ) 
       );
// 以下注释未经过确认是否正确，谨慎思考
// Syndrome Calculator (u_syndrome): 根据输入的数据字节（din）计算里德-所罗门码的伴随式（syndrome）。
//  伴随式的计算是通过与生成多项式 g(x) 进行模2除法得到的。如果伴随式全为0，则表明数据无误；否则，存在错误。

euclid u_euclid(
       .clk       (clk      ) ,
       .rst_n     (rst_n    ) ,
       .start     (syndrome_val) ,
       .syndrome1 (syndrome1) ,
       .syndrome2 (syndrome2) ,
       .syndrome3 (syndrome3) ,
       .syndrome4 (syndrome4) ,
       .elp0      (elp0     ) ,
       .elp1      (elp1     ) ,
       .elp2      (elp2     ) ,
       .elp3      (elp3     ) ,
       .evp0      (evp0     ) ,
       .evp1      (evp1     ) ,
       .evp2      (evp2     ) ,
       .evp3      (evp3     ) ,
       .error_num (error_num) ,
       .done      (euclid_ok) ,
       .fail      (dec_fail )
       );
// 以下注释未经过确认是否正确，谨慎思考
// Euclidean Algorithm Unit (u_euclid): 使用欧几里得算法处理伴随式，求解原始错误位置和错误值多项式（elp0-elp4，evp0-evp4），并确定错误数量（error_num）。
//  当解码成功时设置 euclid_ok 信号，失败时设置 dec_fail 信号。


chien u_chien(
       .clk       (clk      ) ,
       .rst_n     (rst_n    ) ,
       .start     (euclid_ok & ~dec_fail) ,
       .error_num (error_num) ,
       .elp0      (elp0     ) ,
       .elp1      (elp1     ) ,
       .elp2      (elp2     ) ,
       .elp3      (elp3     ) ,

       .el1       (el1      ) ,
       .el2       (el2      ) ,

       .gf_el1    (gf_el1   ) ,
       .gf_el2    (gf_el2   ) ,

       .done      (chien_ok ) 
       );
// 以下注释未经过确认是否正确，谨慎思考
// Chien Search Module (u_chien): 在有限域 GF(256) 上进行Chien搜索，将找到的错误位置多项式转换成实际的错误位置（el1-el4），同时计算出对应的伽罗华域元素（gf_el1-gf_el4）。
//  完成搜索后设置 chien_ok 信号。

forney u_forney(
       .clk   (clk     ),
       .rst_n (rst_n   ),
       .error_num(error_num),
       .start (chien_ok),
       .elp0  (elp0    ),
       .el1   (gf_el1  ),
       .el2   (gf_el2  ),

       .evp0  (evp0    ),
       .evp1  (evp1    ),
       .evp2  (evp2    ),
       .evp3  (evp3    ),
       .ev1   (ev1     ),
       .ev2   (ev2     ),

       .done  (dec_done2)
       );
       
// 以下注释未经过确认是否正确，谨慎思考       
// Forney Syndrome Decoding (u_forney): 使用Forney算法，结合错误位置和错误值多项式，计算出具体的错误值（ev1-ev4），从而纠正错误数据。
//   当所有纠正过程完成后设置 dec_done2 信号

endmodule
