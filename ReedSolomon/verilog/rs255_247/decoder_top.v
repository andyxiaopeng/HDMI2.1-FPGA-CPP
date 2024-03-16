`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 20:35:25
// Design Name: 
// Module Name: decoder_top
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


module decoder_top(

    );
    parameter nn = 255;
    parameter kk = 247;
    parameter tt = 4;
    
    
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
      
      
      // --------------------------
      
      
      
   
    reg d_din_val;
    reg d_din_sop;
    reg d_din_eop;
    reg [7:0] d_din;
      
    wire [7:0] el1;   // el1/el2/el3/el4: 输出纠正后的数据位，代表纠正后数据的四个部分。
    wire [7:0] el2;
    wire [7:0] el3;
    wire [7:0] el4;
    wire [7:0] ev1;     // ev1/ev2/ev3/ev4: 计算出的具体错误值，分别对应于纠正后的el1至el4中的错误。
    wire [7:0] ev2;
    wire [7:0] ev3;
    wire [7:0] ev4;
    wire [2:0] error_num;  // 输出错误数量，表示在数据中检测到并纠正了多少个错误。
    
    wire dec_done;
    wire dec_fail;
    //wire busy;
    
    // ------------------ control ----------------
    reg [8:0] dout_cnt;
    
    reg [8:0] dout_reg [3:0];
    
    initial begin
         dout_cnt = 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(dout_val) begin
            if(dout_cnt == 0) begin
                dout_cnt <= dout_cnt + 1;
                d_din_val <= 1'b1;
                d_din_sop <= 1'b1;
                d_din_eop <= 1'b0;
            end
            else begin
                 dout_cnt <= dout_cnt + 1;
                 if(dout_eop) begin
                    //d_din_val <= 1'b1;
                    d_din_sop <= 1'b0;
                    d_din_eop <= 1'b1;
                 end
                 else begin
                    d_din_sop <= 1'b0;
                 end
            end
            
            if(dout_cnt == 5) begin
                dout_reg[0] <= d_din;
                d_din <= 0;
            end
            else if(dout_cnt == 25) begin
                dout_reg[1] <= d_din;
                d_din <= 10;
            end
            else if(dout_cnt == 35) begin
                dout_reg[2] <= d_din;
                d_din <= 11;
            end
            else if(dout_cnt == 55) begin
                dout_reg[3] <= d_din;
                d_din <= 32;
            end
//            else if(dout_cnt == 65) begin
//                d_din <= 22;
//            end
            else begin
                d_din <= dout;
            end

        end
        
        if(d_din_eop) begin
            d_din_val <= 1'b0;
            d_din_sop <= 1'b0;
            d_din_eop <= 1'b0;
        end
    end
    // -------------
    
      
    rs_decoder u_rs_decoder(
      .clk          (clk),
      .rst_n        (rst_n),
      
      .din_val      (d_din_val),        // 数据有效信号。指示输入数据有效，当此信号为高时，表示din端口上的数据可以用来进行解码处理。
      .din_sop      (d_din_sop),        // 数据开始信号。标记输入数据流的起始包头，表明一个新的数据块开始传输。
      .din_eop      (d_din_eop),        // 数据结束信号。标记输入数据流的结束包尾，表明当前数据块传输结束。
      .din    (d_din),      // 输入数据信号。这是待解码的实际数据字节流。
      
      .el1    (el1),     // el1/el2/el3/el4: 输出纠正后的数据位，代表纠正后数据的四个部分。
      .el2    (el2),
      .el3    (el3),
      .el4    (el4),
      .ev1    (ev1),     // ev1/ev2/ev3/ev4: 计算出的具体错误值，分别对应于纠正后的el1至el4中的错误。
      .ev2    (ev2),
      .ev3    (ev3),
      .ev4    (ev4),
      .error_num  (error_num),   // 输出错误数量，表示在数据中检测到并纠正了多少个错误。
      .dec_done     (dec_done),      // 解码完成信号。当解码过程全部结束且没有发生解码失败时，此信号变高。 由dec_done2和其他信号（如euclid_ok）共同决定
      .dec_fail     (dec_fail),      // 解码失败信号。若解码过程中无法正确找出或纠正错误，此信号变高。
      .busy         (busy)  // 忙碌状态信号。高电平通常表示解码器正在处理数据，低电平则表示可以接收新的输入数据。

      );
      
      
endmodule
