//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/12 21:10:43
// Design Name: 
// Module Name: dec_ctrl
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
module dec_ctrl(
       input clk,
       input rst_n,
       input din_sop,
       input din_eop,
       input syndrome_ok,
       input euclid_ok,
       input chien_ok,
       input forney_ok,
       input [2:0] error_num,
       output reg euclid_start,
       output reg chien_start,
       output reg forney_start,
       output reg dec_fail,
       output reg dec_done
       );
 







endmodule
