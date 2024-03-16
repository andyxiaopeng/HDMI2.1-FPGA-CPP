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
      input din_val,        // ������Ч�źš�ָʾ����������Ч�������ź�Ϊ��ʱ����ʾdin�˿��ϵ����ݿ����������н��봦��
      input din_sop,        // ���ݿ�ʼ�źš������������������ʼ��ͷ������һ���µ����ݿ鿪ʼ���䡣
      input din_eop,        // ���ݽ����źš���������������Ľ�����β��������ǰ���ݿ鴫�������
      input [7:0] din,      // ���������źš����Ǵ������ʵ�������ֽ�����
      output [7:0] el1,     // el1/el2/el3/el4: ��������������λ��������������ݵ��ĸ����֡�
      output [7:0] el2,

      output [7:0] ev1,     // ev1/ev2/ev3/ev4: ������ľ������ֵ���ֱ��Ӧ�ھ������el1��el4�еĴ���
      output [7:0] ev2,

      output [1:0] error_num,   // ���������������ʾ�������м�⵽�������˶��ٸ�����
      output dec_done,      // ��������źš����������ȫ��������û�з�������ʧ��ʱ�����źű�ߡ� ��dec_done2�������źţ���euclid_ok����ͬ����
      output dec_fail,      // ����ʧ���źš�������������޷���ȷ�ҳ���������󣬴��źű�ߡ�
      output busy           // æµ״̬�źš��ߵ�ƽͨ����ʾ���������ڴ������ݣ��͵�ƽ���ʾ���Խ����µ��������ݡ�

      );

wire syndrome_val;          // ��ʾ����ʽ��������ɣ����ҽ�����á�
wire dec_done2;             // ��ʾ������̵ĵڶ��׶���ɣ�Ҳ������Forney�㷨��Ԫ��u_forney����ɾ���֮�������ź�
wire euclid_ok;             // ��ʾŷ������㷨��Ԫ��u_euclid��ִ�гɹ�,���Ѿ��ɹ����ҵ��˴���λ�úʹ���ֵ����ʽ
wire [7:0] syndrome1, syndrome2, syndrome3, syndrome4, syndrome5, syndrome6, syndrome7, syndrome8 ; // ����ʽ���飬�洢ÿһ������õ��İ���ʽֵ��
wire [7:0] elp0, elp1, elp2, elp3, elp4 ;   // ��ʾ ����λ�ö���ʽ ��ϵ����
wire [7:0] evp0, evp1, evp2, evp3, evp4 ;   // ��ʾ ����ֵ����ʽ ��ϵ����
wire [7:0] gf_el1, gf_el2, gf_el3, gf_el4 ; // ����λ�ö�Ӧ��٤�޻���Ԫ�أ��������մ���ֵ���㡣

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
// ����ע��δ����ȷ���Ƿ���ȷ������˼��
// Syndrome Calculator (u_syndrome): ��������������ֽڣ�din���������-��������İ���ʽ��syndrome����
//  ����ʽ�ļ�����ͨ�������ɶ���ʽ g(x) ����ģ2�����õ��ġ��������ʽȫΪ0��������������󣻷��򣬴��ڴ���

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
// ����ע��δ����ȷ���Ƿ���ȷ������˼��
// Euclidean Algorithm Unit (u_euclid): ʹ��ŷ������㷨�������ʽ�����ԭʼ����λ�úʹ���ֵ����ʽ��elp0-elp4��evp0-evp4������ȷ������������error_num����
//  ������ɹ�ʱ���� euclid_ok �źţ�ʧ��ʱ���� dec_fail �źš�


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
// ����ע��δ����ȷ���Ƿ���ȷ������˼��
// Chien Search Module (u_chien): �������� GF(256) �Ͻ���Chien���������ҵ��Ĵ���λ�ö���ʽת����ʵ�ʵĴ���λ�ã�el1-el4����ͬʱ�������Ӧ��٤�޻���Ԫ�أ�gf_el1-gf_el4����
//  ������������� chien_ok �źš�

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
       
// ����ע��δ����ȷ���Ƿ���ȷ������˼��       
// Forney Syndrome Decoding (u_forney): ʹ��Forney�㷨����ϴ���λ�úʹ���ֵ����ʽ�����������Ĵ���ֵ��ev1-ev4�����Ӷ������������ݡ�
//   �����о���������ɺ����� dec_done2 �ź�

endmodule
