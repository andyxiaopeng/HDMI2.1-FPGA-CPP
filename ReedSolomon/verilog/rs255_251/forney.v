//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 21:07:19
// Design Name: 
// Module Name: forney
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
module forney(
       input clk,
       input rst_n,
       input start,
       input [2:0] error_num,
       input [7:0] elp0,  // 
       input [7:0] el1,   // Inverse of el1 is the first error loaction.
       input [7:0] el2,
       input [7:0] evp0,
       input [7:0] evp1,
       input [7:0] evp2,
       input [7:0] evp3,
       output [7:0] ev1,
       output [7:0] ev2,

       output reg done
       );

reg dec_en;
reg [4:0] cnt;
reg [7:0] inv_a;
wire [7:0] inv_z;
reg [7:0] mul1_a, mul2_a, mul3_a, mul4_a;
reg [7:0] mul1_b, mul2_b, mul3_b, mul4_b;
wire [7:0] mul1_z, mul2_z, mul3_z, mul4_z;
reg [7:0] inv_el1, inv_el2, inv_el3, inv_el4;
reg [7:0] inv_ev1_03, inv_ev2_03, inv_ev3_03, inv_ev4_03;
reg [7:0] el1_p2, el2_p2, el3_p2, el4_p2;
reg [7:0] el1_p3, el2_p3, el3_p3, el4_p3;
reg [7:0] evp1_el1, evp1_el2, evp1_el3, evp1_el4;
reg [7:0] evp2_el1_p2, evp2_el2_p2, evp2_el3_p2, evp2_el4_p2;
reg [7:0] evp3_el1_p3, evp3_el2_p3, evp3_el3_p3, evp3_el4_p3;
reg [7:0] elp0_inv_el1, elp0_inv_el2, elp0_inv_el3, elp0_inv_el4;
reg [7:0] el1_inv_el2, el2_inv_el1, el3_inv_el1, el4_inv_el1;
reg [7:0] el1_inv_el3, el2_inv_el3, el3_inv_el2, el4_inv_el2;
reg [7:0] el1_inv_el4, el2_inv_el4, el3_inv_el4, el4_inv_el3;
reg [7:0] ev1_01, ev2_01, ev3_01, ev4_01;
reg [7:0] ev1_02, ev2_02, ev3_02, ev4_02;
reg [7:0] ev1_03, ev2_03, ev3_03, ev4_03;
reg [7:0] ev1_04, ev2_04, ev3_04, ev4_04;

assign ev1 = ev1_04;
assign ev2 = ev2_04;
assign ev3 = ev3_04;
assign ev4 = ev4_04;

gf256inv u_gf256inv( .a(inv_a), .z(inv_z));

gf256mul mul1(.a(mul1_a), .b(mul1_b), .z(mul1_z));
gf256mul mul2(.a(mul2_a), .b(mul2_b), .z(mul2_z));
gf256mul mul3(.a(mul3_a), .b(mul3_b), .z(mul3_z));
gf256mul mul4(.a(mul4_a), .b(mul4_b), .z(mul4_z));


always @(posedge clk or negedge rst_n)
if (!rst_n)
  dec_en <= 0;
else if (start & (error_num != 0))
  dec_en <= 1;
else if (cnt == 16)
  dec_en <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  cnt <= 0;
else if (dec_en)
  cnt <= cnt + 1;
else
  cnt <= 0;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  done <= 0;
else if (start & (error_num == 0))
  done <= 0;
else if (cnt == 16)
  done <= 1;
else
  done <= 0;


always @( * )
case(cnt)
  0 : inv_a = el1;
  1 : inv_a = el2;

  12: inv_a = ev1_03;
  13: inv_a = ev2_03;
  14: inv_a = ev3_03;
  15: inv_a = ev4_03;
  default: inv_a = 0;
endcase


always @( * )
case(cnt)
  0 : begin
        mul1_a = el1; mul1_b = el1;
        mul2_a = el2; mul2_b = el2;

      end
  1 : begin
        mul1_a = el1_p2; mul1_b = el1;
        mul2_a = el2_p2; mul2_b = el2;

      end
  2 : begin
        mul1_a = evp1; mul1_b = el1;
        mul2_a = evp1; mul2_b = el2;

      end
  3 : begin
        mul1_a = evp2; mul1_b = el1_p2;
        mul2_a = evp2; mul2_b = el2_p2;
        mul3_a = evp2; mul3_b = el3_p2;
        mul4_a = evp2; mul4_b = el4_p2;
      end
  4 : begin
        mul1_a = evp3; mul1_b = el1_p3;
        mul2_a = evp3; mul2_b = el2_p3;
        mul3_a = evp3; mul3_b = el3_p3;
        mul4_a = evp3; mul4_b = el4_p3;
      end
  5 : begin
        mul1_a = elp0; mul1_b = inv_el1;
        mul2_a = elp0; mul2_b = inv_el2;
        mul3_a = elp0; mul3_b = inv_el3;
        mul4_a = elp0; mul4_b = inv_el4;
      end
  6 : begin
        mul1_a = el1; mul1_b = inv_el2;
        mul2_a = el2; mul2_b = inv_el1;

      end
  7 : begin
        mul1_a = el1; mul1_b = inv_el3;
        mul2_a = el2; mul2_b = inv_el3;

      end
  8 : begin
        mul1_a = el1; mul1_b = inv_el4;
        mul2_a = el2; mul2_b = inv_el4;

      end
  9 : begin
        mul1_a = elp0_inv_el1; mul1_b = 8'h01 ^ el1_inv_el2;
        mul2_a = elp0_inv_el2; mul2_b = 8'h01 ^ el2_inv_el1;
        mul3_a = elp0_inv_el3; mul3_b = 8'h01 ^ el3_inv_el1;
        mul4_a = elp0_inv_el4; mul4_b = 8'h01 ^ el4_inv_el1;
      end
  10: begin
        mul1_a = ev1_01; mul1_b = 8'h01 ^ el1_inv_el3;
        mul2_a = ev2_01; mul2_b = 8'h01 ^ el2_inv_el3;
        mul3_a = ev3_01; mul3_b = 8'h01 ^ el3_inv_el2;
        mul4_a = ev4_01; mul4_b = 8'h01 ^ el4_inv_el2;
      end
  11: begin
        mul1_a = ev1_02; mul1_b = 8'h01 ^ el1_inv_el4;
        mul2_a = ev2_02; mul2_b = 8'h01 ^ el2_inv_el4;
        mul3_a = ev3_02; mul3_b = 8'h01 ^ el3_inv_el4;
        mul4_a = ev4_02; mul4_b = 8'h01 ^ el4_inv_el3;
      end
  16: begin
        mul1_a = inv_ev1_03; mul1_b = evp0 ^ evp1_el1 ^ evp2_el1_p2 ^ evp3_el1_p3;
        mul2_a = inv_ev2_03; mul2_b = evp0 ^ evp1_el2 ^ evp2_el2_p2 ^ evp3_el2_p3;
        mul3_a = inv_ev3_03; mul3_b = evp0 ^ evp1_el3 ^ evp2_el3_p2 ^ evp3_el3_p3;
        mul4_a = inv_ev4_03; mul4_b = evp0 ^ evp1_el4 ^ evp2_el4_p2 ^ evp3_el4_p3;
      end
  default: 
       begin
        mul1_a = 0; mul1_b = 0;
        mul2_a = 0; mul2_b = 0;
        mul3_a = 0; mul3_b = 0;
        mul4_a = 0; mul4_b = 0;
      end
endcase


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  inv_el1    <= 0;
  inv_el2    <= 0;
  inv_el3    <= 0;
  inv_el4    <= 0;
  inv_ev1_03 <= 0;
  inv_ev2_03 <= 0;
  inv_ev3_03 <= 0;
  inv_ev4_03 <= 0;
end
else if (dec_en)
  case(cnt)
    0 : inv_el1    <= inv_z;
    1 : inv_el2    <= inv_z;
    2 : inv_el3    <= inv_z;
    3 : inv_el4    <= inv_z;
    12: inv_ev1_03 <= inv_z;
    13: inv_ev2_03 <= inv_z;
    14: inv_ev3_03 <= inv_z;
    15: inv_ev4_03 <= inv_z;
  endcase

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1_p2 <= 0;
  el2_p2 <= 0;
  el3_p2 <= 0;
  el4_p2 <= 0;
end
else if (dec_en && (cnt == 0))
begin
  el1_p2 <= mul1_z;
  el2_p2 <= mul2_z;
  el3_p2 <= mul3_z;
  el4_p2 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1_p3 <= 0;
  el2_p3 <= 0;
  el3_p3 <= 0;
  el4_p3 <= 0;
end
else if (dec_en && (cnt == 1))
begin
  el1_p3 <= mul1_z;
  el2_p3 <= mul2_z;
  el3_p3 <= mul3_z;
  el4_p3 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  evp1_el1 <= 0;
  evp1_el2 <= 0;
  evp1_el3 <= 0;
  evp1_el4 <= 0;
end
else if (dec_en && (cnt == 2))
begin
  evp1_el1 <= mul1_z;
  evp1_el2 <= mul2_z;
  evp1_el3 <= mul3_z;
  evp1_el4 <= mul4_z;
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  evp2_el1_p2 <= 0;
  evp2_el2_p2 <= 0;
  evp2_el3_p2 <= 0;
  evp2_el4_p2 <= 0;
end
else if (dec_en && (cnt == 3))
begin
  evp2_el1_p2 <= mul1_z;
  evp2_el2_p2 <= mul2_z;
  evp2_el3_p2 <= mul3_z;
  evp2_el4_p2 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  evp3_el1_p3 <= 0;
  evp3_el2_p3 <= 0;
  evp3_el3_p3 <= 0;
  evp3_el4_p3 <= 0;
end
else if (dec_en && (cnt == 4))
begin
  evp3_el1_p3 <= mul1_z;
  evp3_el2_p3 <= mul2_z;
  evp3_el3_p3 <= mul3_z;
  evp3_el4_p3 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  elp0_inv_el1 <= 0;
  elp0_inv_el2 <= 0;
  elp0_inv_el3 <= 0;
  elp0_inv_el4 <= 0;
end
else if (dec_en && (cnt == 5))
begin
  elp0_inv_el1 <= mul1_z;
  elp0_inv_el2 <= mul2_z;
  elp0_inv_el3 <= mul3_z;
  elp0_inv_el4 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1_inv_el2 <= 0;
  el2_inv_el1 <= 0;
  el3_inv_el1 <= 0;
  el4_inv_el1 <= 0;
end
else if (dec_en && (cnt == 6))
begin
  el1_inv_el2 <= mul1_z;
  el2_inv_el1 <= mul2_z;
  el3_inv_el1 <= mul3_z;
  el4_inv_el1 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1_inv_el3 <= 0;
  el2_inv_el3 <= 0;
  el3_inv_el2 <= 0;
  el4_inv_el2 <= 0;
end
else if (dec_en && (cnt == 7))
begin
  el1_inv_el3 <= mul1_z;
  el2_inv_el3 <= mul2_z;
  el3_inv_el2 <= mul3_z;
  el4_inv_el2 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1_inv_el4 <= 0;
  el2_inv_el4 <= 0;
  el3_inv_el4 <= 0;
  el4_inv_el3 <= 0;
end
else if (dec_en && (cnt == 8))
begin
  el1_inv_el4 <= mul1_z;
  el2_inv_el4 <= mul2_z;
  el3_inv_el4 <= mul3_z;
  el4_inv_el3 <= mul4_z;
end





always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  ev1_01 <= 0;
  ev2_01 <= 0;
  ev3_01 <= 0;
  ev4_01 <= 0;
end
else if (dec_en && (cnt == 9))
begin
  ev1_01 <= mul1_z;
  ev2_01 <= mul2_z;
  ev3_01 <= mul3_z;
  ev4_01 <= mul4_z;
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  ev1_02 <= 0;
  ev2_02 <= 0;
  ev3_02 <= 0;
  ev4_02 <= 0;
end
else if (dec_en && (cnt == 10))
begin
  ev1_02 <= mul1_z;
  ev2_02 <= mul2_z;
  ev3_02 <= mul3_z;
  ev4_02 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  ev1_03 <= 0;
  ev2_03 <= 0;
  ev3_03 <= 0;
  ev4_03 <= 0;
end
else if (dec_en && (cnt == 11))
begin
  ev1_03 <= mul1_z;
  ev2_03 <= mul2_z;
  ev3_03 <= mul3_z;
  ev4_03 <= mul4_z;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  ev1_04 <= 0;
  ev2_04 <= 0;
  ev3_04 <= 0;
  ev4_04 <= 0;
end
else if (dec_en && (cnt == 16))
begin
  ev1_04 <= mul1_z;
  ev2_04 <= mul2_z;
  ev3_04 <= mul3_z;
  ev4_04 <= mul4_z;
end



endmodule
