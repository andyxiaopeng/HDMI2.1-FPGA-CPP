`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 16:31:42
// Design Name: 
// Module Name: encoder_top
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


module encoder_top(
        
    );
    
    parameter nn = 255;
    parameter kk = 251;
    parameter tt = 2;
    
    
    reg rst_n;
    
    reg din_val;
    reg din_sop;
    reg din_eop;
    reg [7:0] din;
    
    wire dout_val;
    wire dout_sop;
    wire dout_eop;
    wire [7:0]dout;
    
    wire busy;
    
    
    // 
    wire clk;
    design_1 u_design_1(
        .clk (clk)
    );
    
    // ----------------------- control --------
    
    reg [2:0]wait_flag;
    reg star_flag;
    
    reg [8:0] din_cnt;
    
    initial begin
        rst_n = 1'b0;
        star_flag = 1'b0;
        
        # 10  rst_n = 1'b1;
    end
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n)
            begin   
                wait_flag <= 0;
                din_cnt <= kk;
                din_eop <= 1'b0;
            end
        else
            begin
                 if(wait_flag < 5) begin
                    wait_flag <= wait_flag + 1;
                 end
                 else if(wait_flag == 5) begin
                 
                    wait_flag <= wait_flag + 1;
                 
                    star_flag <= 1'b1;
                    
                    din_val <= 1'b1;
                    din_sop <= 1'b1;
                    
                    din <= din_cnt;
                    din_cnt <= din_cnt -1;
                 end
                 else begin
                    din_sop <= 1'b0;
                    
                    if(din_cnt != 0) begin
                        din <= din_cnt;
                        din_cnt <= din_cnt -1;
                        
                         if(din_cnt == 1) begin
                            din_eop <= 1'b1;
                        end
                        
                    end
                    else begin 
                        din_eop <= 1'b0;
                        din_val <= 1'b0;
                    end
                 end
                 
            end
    end
    
    // --------------------
    
    rs_encoder u_rs_encoder(
      .clk      (clk),
      .rst_n    (rst_n),
      
      .din_val  (din_val),    // 输入数据的有效性
      .din_sop  (din_sop),    // 数据输入的开始 信号
      .din_eop  (din_eop),    // 数据输入的结束 信号
      .din      (din),
      
      .dout_val (dout_val),  // 输出的有效信号（包括 数据位数据 + 校验位数据）
      .dout_sop (dout_sop),  // 数据输出的开始 标志
      .dout_eop (dout_eop),  // 数据输出的结束 标志       dout_eop 表示 RS 编码器的输出数据的结束位置标志
      .dout     (dout),
      .busy     (busy)
      
      );
    
endmodule
