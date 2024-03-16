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
      
      .din_val  (din_val),    // �������ݵ���Ч��
      .din_sop  (din_sop),    // ��������Ŀ�ʼ �ź�
      .din_eop  (din_eop),    // ��������Ľ��� �ź�
      .din      (din),
      
      .dout_val (dout_val),  // �������Ч�źţ����� ����λ���� + У��λ���ݣ�
      .dout_sop (dout_sop),  // ��������Ŀ�ʼ ��־
      .dout_eop (dout_eop),  // ��������Ľ��� ��־       dout_eop ��ʾ RS ��������������ݵĽ���λ�ñ�־
      .dout     (dout),
      .busy     (busy)
      
      );
      
      
      // --------------------------
      
      
      
   
    reg d_din_val;
    reg d_din_sop;
    reg d_din_eop;
    reg [7:0] d_din;
      
    wire [7:0] el1;   // el1/el2/el3/el4: ��������������λ��������������ݵ��ĸ����֡�
    wire [7:0] el2;
    wire [7:0] el3;
    wire [7:0] el4;
    wire [7:0] ev1;     // ev1/ev2/ev3/ev4: ������ľ������ֵ���ֱ��Ӧ�ھ������el1��el4�еĴ���
    wire [7:0] ev2;
    wire [7:0] ev3;
    wire [7:0] ev4;
    wire [2:0] error_num;  // ���������������ʾ�������м�⵽�������˶��ٸ�����
    
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
      
      .din_val      (d_din_val),        // ������Ч�źš�ָʾ����������Ч�������ź�Ϊ��ʱ����ʾdin�˿��ϵ����ݿ����������н��봦��
      .din_sop      (d_din_sop),        // ���ݿ�ʼ�źš������������������ʼ��ͷ������һ���µ����ݿ鿪ʼ���䡣
      .din_eop      (d_din_eop),        // ���ݽ����źš���������������Ľ�����β��������ǰ���ݿ鴫�������
      .din    (d_din),      // ���������źš����Ǵ������ʵ�������ֽ�����
      
      .el1    (el1),     // el1/el2/el3/el4: ��������������λ��������������ݵ��ĸ����֡�
      .el2    (el2),
      .el3    (el3),
      .el4    (el4),
      .ev1    (ev1),     // ev1/ev2/ev3/ev4: ������ľ������ֵ���ֱ��Ӧ�ھ������el1��el4�еĴ���
      .ev2    (ev2),
      .ev3    (ev3),
      .ev4    (ev4),
      .error_num  (error_num),   // ���������������ʾ�������м�⵽�������˶��ٸ�����
      .dec_done     (dec_done),      // ��������źš����������ȫ��������û�з�������ʧ��ʱ�����źű�ߡ� ��dec_done2�������źţ���euclid_ok����ͬ����
      .dec_fail     (dec_fail),      // ����ʧ���źš�������������޷���ȷ�ҳ���������󣬴��źű�ߡ�
      .busy         (busy)  // æµ״̬�źš��ߵ�ƽͨ����ʾ���������ڴ������ݣ��͵�ƽ���ʾ���Խ����µ��������ݡ�

      );
      
      
endmodule
