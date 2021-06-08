`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2021 10:40:59
// Design Name: 
// Module Name: top
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


module top
#(
    parameter speed = 1,
    
    parameter newclkc = 10000005,
    parameter std_score = 5,
    
    parameter error_str_count = 10000000
)
(
    input                   clk,
    input                   resetn,
    input       [15:0]      SW,
    input       [4:0]       BTN,
    output      [15:0]      LED,
    output                  DP,
    output      [7:0]       AN,
    output      [6:0]       C
    );
    
    reg         [7:0]       cnt1 = 8'b00000000;
    reg         [7:0]       cnt2 = 8'b00000000;
    
    reg         [7:0]       score = std_score;
    
    reg                     isearlier = 'b0;
    reg                     realisearlier = 'b0;
    
    reg                     side = 'b0;
    
    reg         [15:0]      tempLED = 'd128;
    reg         [7:0]       tempAN = 'b11111101;
    reg         [6:0]       tempC = {7'b0};
    
    reg         [1:0]       switch_delay_btn1;
    reg         [1:0]       switch_delay_btn2;
    
    reg         [1:0]       delay_isearlier;
    
    reg         [1:0]       state = STATE_START_MENU;
    reg         [1:0]       nextstate = STATE_START_MENU;
    
    reg         [1:0]           flag_left;
     reg         [1:0]          flag_right;
    reg         [15:0]          flag_counter;
    reg         [15:0]          flag_counter1;   
    
   
    localparam STATE_START_MENU = 'd0;
    localparam STATE_GAME = 'd1;
    localparam STATE_ERROR = 'd2;
  
    
    //11111101
    
    reg [4:0] x;
        
    assign DP = 'b1;
    
    
    wire newClk;
    
    wire switch_start_press_btn1;
    wire switch_start_press_btn2;
    
    wire isearlier_w;
    
    assign isearlier_w = delay_isearlier[1] & !delay_isearlier[0];
    
    assign switch_start_press_btn1 = switch_delay_btn1[1] & !switch_delay_btn1[0];
    assign switch_start_press_btn2 = switch_delay_btn2[1] & !switch_delay_btn2[0];
    
    //Работа с кнопками
    always @(posedge clk) begin
        if(!resetn) switch_delay_btn1 <= 'b0;
        else begin
            switch_delay_btn1[1] <= BTN[2]; 
            switch_delay_btn1[0] <= switch_delay_btn1[1];
        end
    end
    always @(posedge clk) begin
        if(!resetn) switch_delay_btn2 <= 'b0;
        else begin
            switch_delay_btn2[1] <= BTN[3]; 
            switch_delay_btn2[0] <= switch_delay_btn2[1];
        end
    end
    
//задержка
    always @(posedge clk) begin
        if(!resetn) delay_isearlier <= 'b0;
        else begin
            delay_isearlier[1] <= isearlier; 
            delay_isearlier[0] <= delay_isearlier[1];
        end
    end
    
    always @(posedge clk) begin
        state <= nextstate;
    end
    
    //тут ограничение по очкам
    always @(posedge clk) begin
        if(!resetn) score <= std_score;
        else if(BTN[2] && state == STATE_START_MENU && switch_start_press_btn1 && score < 20) begin 
            score <= score + 1;
        end
        else if(BTN[3] && score > 0 && state == STATE_START_MENU && switch_start_press_btn2) score <= score - 1;
        else if(BTN[4] && state == STATE_ERROR) score <= std_score;
    end
    
    //меню
    always @(*) begin
        case(state)
            STATE_START_MENU: begin
               //if()
                if(!resetn) nextstate <= STATE_START_MENU;
                else if(BTN[1]) begin
                    if(score == 0) nextstate <= STATE_ERROR;
                    else nextstate <= STATE_GAME;
                end
                else nextstate <= STATE_START_MENU;
            end
            STATE_GAME: begin
                if(!resetn) nextstate <= STATE_START_MENU;
                else if(cnt1 == score || cnt2 == score) nextstate <= STATE_START_MENU;
                else nextstate <= STATE_GAME;
            end
            STATE_ERROR: begin
                if(!resetn) nextstate <= STATE_START_MENU;
                else if(BTN[4]) begin
                    nextstate <= STATE_START_MENU;
                end
                else nextstate <= STATE_ERROR;
            end
        endcase
    end
    
    
    //подсчет
    always @(posedge clk) begin
        if(~resetn) begin
            cnt1 <= 8'd0;
            cnt2 <= 8'd0;
        end 
        else if(newClk) begin
        if(cnt1 == score || cnt2 == score) begin
            cnt1 = 8'd0;
            cnt2 = 8'd0;
        end
        
        if(state == STATE_GAME) begin
                if (SW[0]) flag_counter <= flag_counter +1'd1;
                if (flag_counter > 'd20) flag_right <=  1'd1;
                if (SW[0] == 0) begin  
                    flag_right <= 0;
                    flag_counter <= 0;
                end
                 if (SW[15]) flag_counter1 <= flag_counter1 +1'd1;
                if (flag_counter1 > 'd20) flag_left <=  1'd1;
                if (SW[15] == 0) begin  
                    flag_left <= 0;
                    flag_counter1 <= 0;
                end
                
                if(tempLED == {1'b1, 15'b0} || flag_left == 1) begin
                    cnt1 <= cnt1 + 1'b1;
                end
                if(tempLED == {15'b0, 1'b1} || flag_right == 1) begin
                    cnt2 <= cnt2 + 1'b1;
                end
            end
        end
    end
    
//выбор состояния    
    always @(posedge clk) begin
        if(!resetn) realisearlier = 'b0;
        else begin
            if(isearlier_w) realisearlier = 'b1;
            else if(tempLED == {1'b1, 15'b0} || tempLED == {15'b0, 1'b1}) realisearlier = 'b0;
        end
    end
    
    always @(side) begin
        isearlier <= 1'b0;
    end
    
    always @(posedge clk) begin
        if(~resetn) isearlier <= 1'b0;
        
        
        else begin
            if(state == STATE_GAME) begin
                if((SW[0] && tempLED != 16'd2) || (SW[15] && tempLED != {1'b0, 1'b1, 14'b0})) isearlier <= 1'b1;
                if(tempLED == {1'b1, 15'b0} || tempLED == {15'b0, 1'b1}) isearlier <= 1'b0;
            end
        end
        
    end
    
    //Движение светодиодов
    always @(posedge clk) begin
    
    
    
        if(~resetn) begin
            tempLED = 'd32;
            side = 'b0;
        end 
        else if(newClk) begin
            if(state == STATE_GAME) begin
                if(tempLED == {14'b0, 1'b1, 1'b0} && SW[0] && !realisearlier) side = ~side;
                if(tempLED == {1'b0, 1'b1, 14'b0} && SW[15] && !realisearlier) side = ~side;
                if(tempLED == {15'b0, 1'b1} || tempLED == {1'b1, 15'b0}) begin
                    tempLED <= {8'b0, 1'b1, 7'b0}; 
                    side = ~side;
                end
                else begin
                    case(side)
                        'b0: tempLED = {tempLED[14:0], tempLED[15]}; // влево двигает
                        'b1: tempLED = {tempLED[0], tempLED[15:1]}; 
                    endcase
                end
            end
        end
    end
    
    reg [28:0] prescale_an = 29'b0;
    //Сообщение об ошибке
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin 
            prescale_an <= 29'b0;
            //newClk <= 1'b0;
        end
        else if (prescale_an >= error_str_count) begin
            //newClk <= ~newClk;
            prescale_an <= 29'b0;
        end
        else prescale_an <= prescale_an + 1'b1;
    end
    
    reg [28:0] prescale = 29'b0;
    
    //Скорость
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin 
            prescale <= 29'b0;
            //newClk <= 1'b0;
        end
        else if (prescale >= newclkc) begin
            //newClk <= ~newClk;
            prescale <= 29'b0;
        end
        else prescale <= prescale + speed;
    end
    
    reg [9:0] tic_an = 10'd0;
    
    //Вывод на семисегментники сообщения об ошибке
    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            tempAN <= 'b11111101;
            tic_an <= 10'd0;
        end
        else if(tic_an == 10'd1000) begin
            if(state == STATE_GAME) begin
                if(tempAN == 'b11111101) tempAN <= 8'b10111111;//{1'b1, 1'b0, 6'b1};
                else tempAN <= {tempAN[6:0], tempAN[7]}; // двигает влево
                tic_an <= 10'd0;
            end
            else if(state == STATE_START_MENU) begin
                if(tempAN == 'b11111101) tempAN <= 8'b11110111;
                else tempAN <= {tempAN[6:0], tempAN[7]};
                tic_an <= 10'd0;
            end
            else if(state == STATE_ERROR) begin
                if(tempAN == 'b01111111) tempAN <= 8'b11110111;
                else tempAN <= {tempAN[6:0], tempAN[7]};
                tic_an <= 10'd0;
            end
        end
        else tic_an <= tic_an + 1'b1;
    end

//Decode
    always @(posedge clk) begin
        if(state == STATE_GAME) begin
            case(tempAN)
                'b11111110: x <= cnt1 % 10;
                'b11111101: x <= cnt1 / 10;
                'b01111111: x <= cnt2 / 10;
                'b10111111: x <= cnt2 % 10;
            endcase
        end
        else if(state == STATE_START_MENU) begin
            case(tempAN)
                'b01111111: x <= 5'd5;  // S
                'b10111111: x <= 5'd12; // C
                'b11011111: x <= 5'd0; //  O
                'b11101111: x <= 5'd16; // R
                'b11110111: x <= 5'd14; // E
                'b11111110: x <= score % 10;
                'b11111101: x <= score / 10;
            endcase
        end
        else if(state == STATE_ERROR) begin
            case(tempAN)
                'b01111111: x <= 5'd14;  // E
                'b10111111: x <= 5'd16; //  R
                'b11011111: x <= 5'd16; //  R
                'b11101111: x <= 5'd0; //   O
                'b11110111: x <= 5'd16; //  R
            endcase
        end
    end
    
    wire [4:0] wire_x = x;
    
    decoder dc(.x(wire_x), .y(C));
    
    //assign C = tempC;
    assign AN = tempAN;
    assign newClk = (prescale >= newclkc);
    wire newClkAn;
    assign newClkAn = (prescale_an >= error_str_count);
    assign LED[15:0] = tempLED[15:0];
endmodule
