//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/13 16:00:54
// Design Name: 
// Module Name: gf256inv
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


// inverse
// a*z = 1. z is an inverse of a.
// �������򣨱���GF(2^n)���������У�Ҳ�����Ƶ���Ԫ��������Ǽ򵥵س���һ�������ܵõ�
// ��GF(2^n)�У����Ǳ���ͨ���ض����㷨������չŷ������㷨��LOG/ANTLOG�����ң��ҵ�һ��Ԫ�� z��ʹ�� a * z �� 1 (mod p(x))������ p(x) �Ƕ���������ɶ���ʽ��
// gf256inv inv1(.a(evp_1[devp_1]), .z(inv_evp_1));
// ���inv_evp_1 ��������Ϊ evp_1[devp_1] ����Ԫ

`timescale 1ns/100ps
module gf256inv(
       input [7:0] a,
       output reg [7:0] z
       );
                                                                             
always @( * ) begin
  case (a) 
	8'h00: z = 8'h00;   //actually, there are no inverse for 0.
	8'h02: z = 8'h8e;   //a^1
	8'h04: z = 8'h47;   //a^2
	8'h08: z = 8'had;
	8'h10: z = 8'hd8;
	8'h20: z = 8'h6c;
	8'h40: z = 8'h36;
	8'h80: z = 8'h1b;
	8'h1d: z = 8'h83;
	8'h3a: z = 8'hcf;
	8'h74: z = 8'he9;
	8'he8: z = 8'hfa;
	8'hcd: z = 8'h7d;
	8'h87: z = 8'hb0;
	8'h13: z = 8'h58;
	8'h26: z = 8'h2c;
	8'h4c: z = 8'h16;
	8'h98: z = 8'h0b;
	8'h2d: z = 8'h8b;
	8'h5a: z = 8'hcb;
	8'hb4: z = 8'heb;
	8'h75: z = 8'hfb;
	8'hea: z = 8'hf3;
	8'hc9: z = 8'hf7;
	8'h8f: z = 8'hf5;
	8'h03: z = 8'hf4;
	8'h06: z = 8'h7a;
	8'h0c: z = 8'h3d;
	8'h18: z = 8'h90;
	8'h30: z = 8'h48;
	8'h60: z = 8'h24;
	8'hc0: z = 8'h12;
	8'h9d: z = 8'h09;
	8'h27: z = 8'h8a;
	8'h4e: z = 8'h45;
	8'h9c: z = 8'hac;
	8'h25: z = 8'h56;
	8'h4a: z = 8'h2b;
	8'h94: z = 8'h9b;
	8'h35: z = 8'hc3;
	8'h6a: z = 8'hef;
	8'hd4: z = 8'hf9;
	8'hb5: z = 8'hf2;
	8'h77: z = 8'h79;
	8'hee: z = 8'hb2;
	8'hc1: z = 8'h59;
	8'h9f: z = 8'ha2;
	8'h23: z = 8'h51;
	8'h46: z = 8'ha6;
	8'h8c: z = 8'h53;
	8'h05: z = 8'ha7;
	8'h0a: z = 8'hdd;
	8'h14: z = 8'he0;
	8'h28: z = 8'h70;
	8'h50: z = 8'h38;
	8'ha0: z = 8'h1c;
	8'h5d: z = 8'h0e;
	8'hba: z = 8'h07;
	8'h69: z = 8'h8d;
	8'hd2: z = 8'hc8;
	8'hb9: z = 8'h64;
	8'h6f: z = 8'h32;
	8'hde: z = 8'h19;
	8'ha1: z = 8'h82;
	8'h5f: z = 8'h41;
	8'hbe: z = 8'hae;
	8'h61: z = 8'h57;
	8'hc2: z = 8'ha5;
	8'h99: z = 8'hdc;
	8'h2f: z = 8'h6e;
	8'h5e: z = 8'h37;
	8'hbc: z = 8'h95;
	8'h65: z = 8'hc4;
	8'hca: z = 8'h62;
	8'h89: z = 8'h31;
	8'h0f: z = 8'h96;
	8'h1e: z = 8'h4b;
	8'h3c: z = 8'hab;
	8'h78: z = 8'hdb;
	8'hf0: z = 8'he3;
	8'hfd: z = 8'hff;
	8'he7: z = 8'hf1;
	8'hd3: z = 8'hf6;
	8'hbb: z = 8'h7b;
	8'h6b: z = 8'hb3;
	8'hd6: z = 8'hd7;
	8'hb1: z = 8'he5;
	8'h7f: z = 8'hfc;
	8'hfe: z = 8'h7e;
	8'he1: z = 8'h3f;
	8'hdf: z = 8'h91;
	8'ha3: z = 8'hc6;
	8'h5b: z = 8'h63;
	8'hb6: z = 8'hbf;
	8'h71: z = 8'hd1;
	8'he2: z = 8'he6;
	8'hd9: z = 8'h73;
	8'haf: z = 8'hb7;
	8'h43: z = 8'hd5;
	8'h86: z = 8'he4;
	8'h11: z = 8'h72;
	8'h22: z = 8'h39;
	8'h44: z = 8'h92;
	8'h88: z = 8'h49;
	8'h0d: z = 8'haa;
	8'h1a: z = 8'h55;
	8'h34: z = 8'ha4;
	8'h68: z = 8'h52;
	8'hd0: z = 8'h29;
	8'hbd: z = 8'h9a;
	8'h67: z = 8'h4d;
	8'hce: z = 8'ha8;
	8'h81: z = 8'h54;
	8'h1f: z = 8'h2a;
	8'h3e: z = 8'h15;
	8'h7c: z = 8'h84;
	8'hf8: z = 8'h42;
	8'hed: z = 8'h21;
	8'hc7: z = 8'h9e;
	8'h93: z = 8'h4f;
	8'h3b: z = 8'ha9;
	8'h76: z = 8'hda;
	8'hec: z = 8'h6d;
	8'hc5: z = 8'hb8;
	8'h97: z = 8'h5c;
	8'h33: z = 8'h2e;
	8'h66: z = 8'h17;
	8'hcc: z = 8'h85;
	8'h85: z = 8'hcc;
	8'h17: z = 8'h66;
	8'h2e: z = 8'h33;
	8'h5c: z = 8'h97;
	8'hb8: z = 8'hc5;
	8'h6d: z = 8'hec;
	8'hda: z = 8'h76;
	8'ha9: z = 8'h3b;
	8'h4f: z = 8'h93;
	8'h9e: z = 8'hc7;
	8'h21: z = 8'hed;
	8'h42: z = 8'hf8;
	8'h84: z = 8'h7c;
	8'h15: z = 8'h3e;
	8'h2a: z = 8'h1f;
	8'h54: z = 8'h81;
	8'ha8: z = 8'hce;
	8'h4d: z = 8'h67;
	8'h9a: z = 8'hbd;
	8'h29: z = 8'hd0;
	8'h52: z = 8'h68;
	8'ha4: z = 8'h34;
	8'h55: z = 8'h1a;
	8'haa: z = 8'h0d;
	8'h49: z = 8'h88;
	8'h92: z = 8'h44;
	8'h39: z = 8'h22;
	8'h72: z = 8'h11;
	8'he4: z = 8'h86;
	8'hd5: z = 8'h43;
	8'hb7: z = 8'haf;
	8'h73: z = 8'hd9;
	8'he6: z = 8'he2;
	8'hd1: z = 8'h71;
	8'hbf: z = 8'hb6;
	8'h63: z = 8'h5b;
	8'hc6: z = 8'ha3;
	8'h91: z = 8'hdf;
	8'h3f: z = 8'he1;
	8'h7e: z = 8'hfe;
	8'hfc: z = 8'h7f;
	8'he5: z = 8'hb1;
	8'hd7: z = 8'hd6;
	8'hb3: z = 8'h6b;
	8'h7b: z = 8'hbb;
	8'hf6: z = 8'hd3;
	8'hf1: z = 8'he7;
	8'hff: z = 8'hfd;
	8'he3: z = 8'hf0;
	8'hdb: z = 8'h78;
	8'hab: z = 8'h3c;
	8'h4b: z = 8'h1e;
	8'h96: z = 8'h0f;
	8'h31: z = 8'h89;
	8'h62: z = 8'hca;
	8'hc4: z = 8'h65;
	8'h95: z = 8'hbc;
	8'h37: z = 8'h5e;
	8'h6e: z = 8'h2f;
	8'hdc: z = 8'h99;
	8'ha5: z = 8'hc2;
	8'h57: z = 8'h61;
	8'hae: z = 8'hbe;
	8'h41: z = 8'h5f;
	8'h82: z = 8'ha1;
	8'h19: z = 8'hde;
	8'h32: z = 8'h6f;
	8'h64: z = 8'hb9;
	8'hc8: z = 8'hd2;
	8'h8d: z = 8'h69;
	8'h07: z = 8'hba;
	8'h0e: z = 8'h5d;
	8'h1c: z = 8'ha0;
	8'h38: z = 8'h50;
	8'h70: z = 8'h28;
	8'he0: z = 8'h14;
	8'hdd: z = 8'h0a;
	8'ha7: z = 8'h05;
	8'h53: z = 8'h8c;
	8'ha6: z = 8'h46;
	8'h51: z = 8'h23;
	8'ha2: z = 8'h9f;
	8'h59: z = 8'hc1;
	8'hb2: z = 8'hee;
	8'h79: z = 8'h77;
	8'hf2: z = 8'hb5;
	8'hf9: z = 8'hd4;
	8'hef: z = 8'h6a;
	8'hc3: z = 8'h35;
	8'h9b: z = 8'h94;
	8'h2b: z = 8'h4a;
	8'h56: z = 8'h25;
	8'hac: z = 8'h9c;
	8'h45: z = 8'h4e;
	8'h8a: z = 8'h27;
	8'h09: z = 8'h9d;
	8'h12: z = 8'hc0;
	8'h24: z = 8'h60;
	8'h48: z = 8'h30;
	8'h90: z = 8'h18;
	8'h3d: z = 8'h0c;
	8'h7a: z = 8'h06;
	8'hf4: z = 8'h03;
	8'hf5: z = 8'h8f;
	8'hf7: z = 8'hc9;
	8'hf3: z = 8'hea;
	8'hfb: z = 8'h75;
	8'heb: z = 8'hb4;
	8'hcb: z = 8'h5a;
	8'h8b: z = 8'h2d;
	8'h0b: z = 8'h98;
	8'h16: z = 8'h4c;
	8'h2c: z = 8'h26;
	8'h58: z = 8'h13;
	8'hb0: z = 8'h87;
	8'h7d: z = 8'hcd;
	8'hfa: z = 8'he8;
	8'he9: z = 8'h74;
	8'hcf: z = 8'h3a;
	8'h83: z = 8'h1d;
	8'h1b: z = 8'h80;
	8'h36: z = 8'h40;
	8'h6c: z = 8'h20;
	8'hd8: z = 8'h10;
	8'had: z = 8'h08;
	8'h47: z = 8'h04;
	8'h8e: z = 8'h02;
	8'h01: z = 8'h01;
endcase
end


endmodule

