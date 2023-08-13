`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 12:45:13
// Design Name: 
// Module Name: me_iddmm_top
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


module me_iddmm_top(

);





mmp_iddmm_sp #(
      . MULT_METHOD     ( "TRADITION" )  // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                         // "TRADITION" :MULT_LATENCY=9                
                                         // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
    , . ADD1_METHOD     ( "3-2_PIPE1" )  // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                         // "3-2_PIPE2" :classic pipeline adder,stage 2,ADD1_LATENCY=2
                                         // "3-2_PIPE1" :classic pipeline adder,stage 1,ADD1_LATENCY=1
                                         // 
    , . ADD2_METHOD     ( "3-2_DELAY2")  // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                         // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                         // 
    , . MULT_LATENCY    ( 0           )                       
    , . ADD1_LATENCY    ( 0           )  

    , . K               ( 128         )  // K bits in every group
    , . N               ( 16          )  // Number of groups
)u_mmp_iddmm_sp(
      .clk              ()
    , .rst_n            ()

    , .wr_ena           ()
    , .wr_addr          ()
    , .wr_x             ()//low words first
    , .wr_y             ()//low words first
    , .wr_m             ()//low words first
    , .wr_m1            ()

    , .task_req         ()
    , .task_end         ()
    , .task_grant       ()
    , .task_res         ()    
);















endmodule
