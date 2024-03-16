`timescale 1ns/100ps
module chien(
       input clk,
       input rst_n,
       input start,
       input [2:0] error_num,            // number of errors
       input [7:0] elp0,
       input [7:0] elp1,
       input [7:0] elp2,
       input [7:0] elp3,
       input [7:0] elp4,
       output reg [7:0] el1,
       output reg [7:0] el2,
       output reg [7:0] el3,
       output reg [7:0] el4,
       output reg [7:0] gf_el1,
       output reg [7:0] gf_el2,
       output reg [7:0] gf_el3,
       output reg [7:0] gf_el4,
       output reg done
       );

reg dec_en;
reg [2:0] error_cnt;
reg [7:0] byte_cnt;
reg [7:0] alpha1, alpha2, alpha3, alpha4;
wire [7:0] palpha1, palpha2, palpha3, palpha4;
wire [7:0] term1, term2, term3, term4;
wire [7:0] elp_result;

gf256mul mul1(.a(alpha1), .b(8'h02), .z(palpha1));
gf256mul mul2(.a(alpha2), .b(8'h04), .z(palpha2));
gf256mul mul3(.a(alpha3), .b(8'h08), .z(palpha3));
gf256mul mul4(.a(alpha4), .b(8'h10), .z(palpha4));


gf256mul mul5(.a(alpha1), .b(elp1), .z(term1));
gf256mul mul6(.a(alpha2), .b(elp2), .z(term2));
gf256mul mul7(.a(alpha3), .b(elp3), .z(term3));
gf256mul mul8(.a(alpha4), .b(elp4), .z(term4));

assign elp_result = elp0 ^ term1 ^ term2 ^ term3 ^ term4;

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  alpha1 <= 0;
  alpha2 <= 0;
  alpha3 <= 0;
  alpha4 <= 0;
end
else if (start)
begin
  alpha1 <= 8'h02;  // a^1
  alpha2 <= 8'h04;  // a^2
  alpha3 <= 8'h08;  // a^3
  alpha4 <= 8'h10;  // a^4
end
else if (dec_en)
begin
  alpha1 <= palpha1;
  alpha2 <= palpha2;
  alpha3 <= palpha3;
  alpha4 <= palpha4;
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  el1 <= 0;
  el2 <= 0;
  el3 <= 0;
  el4 <= 0;
  gf_el1 <= 0;
  gf_el2 <= 0;
  gf_el3 <= 0;
  gf_el4 <= 0;
end
else if (start)
begin
  el1 <= 0;
  el2 <= 0;
  el3 <= 0;
  el4 <= 0;
  gf_el1 <= 0;
  gf_el2 <= 0;
  gf_el3 <= 0;
  gf_el4 <= 0;
end
else if ((elp_result == 0) && dec_en)
  case(error_cnt)
    0: begin el1 <= byte_cnt;  gf_el1 <= alpha1; end
    1: begin el2 <= byte_cnt;  gf_el2 <= alpha1; end
    2: begin el3 <= byte_cnt;  gf_el3 <= alpha1; end
    3: begin el4 <= byte_cnt;  gf_el4 <= alpha1; end
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