`timescale 1ns/100ps
module gf256mul(
      input [7:0] a,
      input [7:0] b,
      output [7:0] z
      );
// ���������ж�Ϊ�����б���ѧ���ĵĳ˷����Ӿ��������Ƶĳ˷��� ��������˶ʿ���ĵ�3.1.3�½��г˷����������

// ���䣬�������Ӧ�û���û�������Ż������տ��Խ���ͬ����ϲ����õ�һ�����յľ��󣬴Ӷ�ʹ������˷���û����ô�� ��λ����� �� ������ 

assign z[0] = a[0]&b[0] ^ a[7]&b[1] ^ a[1]&b[7] ^ a[6]&b[2] ^ a[2]&b[6] ^ a[5]&b[3] ^ a[3]&b[5] ^
              a[4]&b[4] ^ a[7]&b[5] ^ a[5]&b[7] ^ a[6]&b[6] ^ a[7]&b[6] ^ a[6]&b[7] ^ a[7]&b[7] ;

assign z[1] = a[1]&b[0] ^ a[0]&b[1] ^ a[7]&b[2] ^ a[2]&b[7] ^ a[6]&b[3] ^ a[3]&b[6] ^ a[5]&b[4] ^
              a[4]&b[5] ^ a[7]&b[6] ^ a[6]&b[7] ^ a[7]&b[7] ;

assign z[2] = a[2]&b[0] ^ a[0]&b[2] ^ a[1]&b[1] ^ a[7]&b[1] ^ a[1]&b[7] ^ a[6]&b[2] ^ a[2]&b[6] ^
              a[5]&b[3] ^ a[3]&b[5] ^ a[4]&b[4] ^ a[7]&b[3] ^ a[3]&b[7] ^ a[6]&b[4] ^ a[4]&b[6] ^
              a[5]&b[5] ^ a[7]&b[5] ^ a[5]&b[7] ^ a[6]&b[6] ^ a[7]&b[6] ^ a[6]&b[7] ;
 
assign z[3] = a[3]&b[0] ^ a[0]&b[3] ^ a[2]&b[1] ^ a[1]&b[2] ^ a[7]&b[1] ^ a[1]&b[7] ^ a[6]&b[2] ^ a[2]&b[6] ^
              a[5]&b[3] ^ a[3]&b[5] ^ a[4]&b[4] ^ a[7]&b[2] ^ a[2]&b[7] ^ a[6]&b[3] ^ a[3]&b[6] ^ a[5]&b[4] ^
              a[4]&b[5] ^ a[7]&b[4] ^ a[4]&b[7] ^ a[6]&b[5] ^ a[5]&b[6] ^ a[7]&b[5] ^ a[5]&b[7] ^ a[6]&b[6] ;
 
assign z[4] = a[4]&b[0] ^ a[0]&b[4] ^ a[3]&b[1] ^ a[1]&b[3] ^ a[2]&b[2] ^ a[7]&b[1] ^ a[1]&b[7] ^ a[6]&b[2] ^
              a[2]&b[6] ^ a[5]&b[3] ^ a[3]&b[5] ^ a[4]&b[4] ^ a[7]&b[2] ^ a[2]&b[7] ^ a[6]&b[3] ^ a[3]&b[6] ^
              a[5]&b[4] ^ a[4]&b[5] ^ a[7]&b[3] ^ a[3]&b[7] ^ a[6]&b[4] ^ a[4]&b[6] ^ a[5]&b[5] ^ a[7]&b[7] ;
 
assign z[5] = a[5]&b[0] ^ a[0]&b[5] ^ a[4]&b[1] ^ a[1]&b[4] ^ a[3]&b[2] ^ a[2]&b[3] ^ a[7]&b[2] ^
              a[2]&b[7] ^ a[6]&b[3] ^ a[3]&b[6] ^ a[5]&b[4] ^ a[4]&b[5] ^ a[7]&b[3] ^ a[3]&b[7] ^
              a[6]&b[4] ^ a[4]&b[6] ^ a[5]&b[5] ^ a[7]&b[4] ^ a[4]&b[7] ^ a[6]&b[5] ^ a[5]&b[6] ;
 
assign z[6] = a[6]&b[0] ^ a[0]&b[6] ^ a[5]&b[1] ^ a[1]&b[5] ^ a[4]&b[2] ^ a[2]&b[4] ^ a[3]&b[3] ^
              a[7]&b[3] ^ a[3]&b[7] ^ a[6]&b[4] ^ a[4]&b[6] ^ a[5]&b[5] ^ a[7]&b[4] ^ a[4]&b[7] ^
              a[6]&b[5] ^ a[5]&b[6] ^ a[7]&b[5] ^ a[5]&b[7] ^ a[6]&b[6] ;
 
assign z[7] = a[7]&b[0] ^ a[0]&b[7] ^ a[6]&b[1] ^ a[1]&b[6] ^ a[5]&b[2] ^ a[2]&b[5] ^ a[4]&b[3] ^
              a[3]&b[4] ^ a[7]&b[4] ^ a[4]&b[7] ^ a[6]&b[5] ^ a[5]&b[6] ^ a[7]&b[5] ^ a[5]&b[7] ^
              a[6]&b[6] ^ a[7]&b[6] ^ a[6]&b[7] ;

endmodule