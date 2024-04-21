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

//function:result = x^^y mod m

module me_iddmm_top#(
        parameter K       = 128
    ,   parameter N       = 16
    ,   parameter ADDR_W  = $clog2(N)
)(
        input                   clk         
    ,   input                   rst_n       

    ,   input                   me_start

    ,   input       [K-1:0]     me_x
    ,   input                   me_x_valid

    ,   output      [K-1:0]     me_result   
    ,   output                  me_valid
);
localparam data_test    =   1;

wire    [K*N-1  : 0]    me_y                    ;
wire    [K-1    : 0]    me_m1                   ;
reg     [K-1    : 0]    rou [N-1:0]             ;
reg     [K-1    : 0]    result [N-1:0]          ;
reg     [K-1    : 0]    result_backup [N-1:0]   ;


assign   me_y       =   2048'h010001;
assign   me_m1      =   128'ha83c91fe83adee77f2b721fabf7087cf;//m1=(-1*(mod_inv(m,2**K)))%2**K

initial begin
    rou = '{
    128'h3b3636ddb77b46770293953c94d38c7f, //high
    128'ha989cab7674f8bc029f672ed4bc1e407, 
    128'h8da0a9833396589a2be50f3c0257f7d8, 
    128'h525494873a726189c85e35da41c5fe05, 
    128'h371f55c4d3b471d84fc357113be8ac1b, 
    128'h2ddde970a2a0875b3605cdd55b1e7290, 
    128'h3e20225580b2cf51563ac90e479b9e53, 
    128'ha74c4c130e45d5d2779fe0190392362f, 
    128'h7efc07819a449874a894cc94a57836fe, 
    128'h60fc3316cf5a9fe92db2d3d41e07b99f, 
    128'hd86c994a5e3feb778afe4c626b467f0f, 
    128'h9ff0efa078a154c27b7e898852a701cf, 
    128'h52c2e6f009a7ba570f27f5c69a0462b8, 
    128'h7ebcf4fa614fde607e0701e3c7e7f553, 
    128'h4bd36ae80c5edd6b360f354fbd446411,
    128'hf94fd24132d8bd2b4475933c32178b17 //low
    };//2^(2*K) mod m
end

initial begin
    result = '{
    128'h23e4a90c916cc13dcbaba3b8eac8f4eb,
    128'h351ff156c891609a21d3ec9e0ee90fa5,
    128'hb3d00aa900ffad071d2cbcb00a17bc59,
    128'h4db9bb6219370fb38357de100455e243,
    128'h385e46fc5fa4898e4492f0279c62b6d3,
    128'ha48b3d36eaef1c4ff94dd8340eb596b3,
    128'hde5675b4e5db8b9ec132d6bfa79c8e93,
    128'hc20a2ce9f12f466d5da4ca9d919800e,
    128'h556dbd12c5e08152839c74d9241c9db4,
    128'h98edfaa1efe3f889e059101c726eaff9,
    128'had44b2891ad0ec15282fb4fb904b530,
    128'h3fd5a81fd30d733e503c2dd4a8d99656,
    128'h61182ca847bf437405b14e4452d787db,
    128'h26c53da62a61445586712f0fd91a5f1f,
    128'hac6d97c5974e969be9f206c9950864f5,
    128'h5726a0566919c9fdd1a7b79c5c0b1f2f
    };//1*2^(K) mod m
end

initial begin
    result_backup = '{
    128'h23e4a90c916cc13dcbaba3b8eac8f4eb,
    128'h351ff156c891609a21d3ec9e0ee90fa5,
    128'hb3d00aa900ffad071d2cbcb00a17bc59,
    128'h4db9bb6219370fb38357de100455e243,
    128'h385e46fc5fa4898e4492f0279c62b6d3,
    128'ha48b3d36eaef1c4ff94dd8340eb596b3,
    128'hde5675b4e5db8b9ec132d6bfa79c8e93,
    128'hc20a2ce9f12f466d5da4ca9d919800e,
    128'h556dbd12c5e08152839c74d9241c9db4,
    128'h98edfaa1efe3f889e059101c726eaff9,
    128'had44b2891ad0ec15282fb4fb904b530,
    128'h3fd5a81fd30d733e503c2dd4a8d99656,
    128'h61182ca847bf437405b14e4452d787db,
    128'h26c53da62a61445586712f0fd91a5f1f,
    128'hac6d97c5974e969be9f206c9950864f5,
    128'h5726a0566919c9fdd1a7b79c5c0b1f2f
    };//1*2^(K) mod m
end

reg     [4              : 0]    current_state           ;  
localparam  IDLE        = 0,
            state_0_0   = 1,
            state_0_1   = 2,
            state_1_0   = 3,
            state_1_1   = 4,
            state_2_0   = 5,
            state_2_1   = 6,
            state_3     = 7,
            state_4     = 8;

reg     [$clog2(K*N)-1  : 0]    loop_counter            ; 
reg     [K-1            : 0]    result2       [N-1 : 0] ;
reg     [K*N-1          : 0]    yy                      ;
reg                             result_valid            ;
reg     [K-1            : 0]    result_out              ; 
reg     [ADDR_W         : 0]    wr_x_cnt                ;

wire    [1              : 0]    wr_ena                  ;
reg                             wr_ena_x                ;
reg                             wr_ena_y                ;
reg     [ADDR_W-1       : 0]    wr_addr                 ;
reg     [K-1            : 0]    wr_x                    ;
reg     [K-1            : 0]    wr_y                    ;

reg                             task_req                ;

wire                            task_end                ;
wire                            task_grant              ;
wire    [K-1            : 0]    task_res                ;

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//algorithm achievement:
//---------------------------------------------------------------------
//---------------------------------------------------------------------
// rou = fastExpMod(2,2*nbit,p)
// result = mont_r2mm(rou,1,p,nbit)

//step0
// result2 = mont_r2mm(xx,rou,p,nbit) 

//step1
// for(i) in range(nbit-1,-1,-1):
//     result = mont_r2mm(result,result,p,nbit)
//     if((yy>>i)&1==1):
//         result = mont_r2mm(result,result2,p,nbit)

//step2
// result = mont_r2mm(result,1,p,nbit)
//---------------------------------------------------------------------
//---------------------------------------------------------------------
reg  [ADDR_W-1       : 0]    wr_addr_d1              = 0;
always@(posedge clk)begin
  wr_addr_d1 <= wr_addr;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        current_state   <=  IDLE;
        task_req        <=  0;
        wr_addr         <=  0;
        wr_ena_x        <=  0;
        wr_ena_y        <=  0;
        yy              <=  me_y;
        loop_counter    <=  0;
        result_valid    <=  0;
        result_out      <=  0;
        wr_x            <=  0;  
        wr_y            <=  0;
        wr_x_cnt        <=  0;
    end
    else begin
        case (current_state)
            IDLE:begin
                task_req          <=  0;
                yy                <=  me_y;
                loop_counter      <=  0;
                result_valid      <=  0;
                result_out        <=  0;
                wr_x              <=  0;  
                wr_y              <=  0;
                wr_addr           <=  0;
                wr_x_cnt          <=  0;
                if(me_start)begin
                    current_state   <=  state_0_0;
                end
            end
            //write xx & rou
            state_0_0:begin
                if(me_x_valid)begin
                    wr_x_cnt          <=  wr_x_cnt + 1;
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  me_x;
                    wr_ena_y          <=  1;
                    wr_y              <=  rou[wr_addr];
                end 
                else begin
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                end
                if(wr_x_cnt == N)begin
                    wr_x_cnt          <=  0;
                    task_req          <=  1;
                    wr_addr           <=  0;
                    current_state     <=  state_0_1;
                end
            end
            //store result2
            state_0_1:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  state_1_0;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result2[wr_addr]  <=  task_res;
                end
            end
            //result = mont_r2mm(result,result,p,nbit)
            state_1_0:begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                    current_state     <=  state_2_0;
                end
                else begin
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  result[wr_addr];
                    wr_ena_y          <=  1;
                    wr_y              <=  result[wr_addr];
                end
            end
            //result = mont_r2mm(result,result2,p,nbit)
            state_1_1:begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                    current_state     <=  state_2_1;
                end
                else begin
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  result[wr_addr];
                    wr_ena_y          <=  1;
                    wr_y              <=  result2[wr_addr];
                end
            end
            //store result and decide whether to skip state_1_1
            state_2_0:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  yy[K*N-1] ? state_1_1 : ((loop_counter == (K*N-1)) ? state_3 : state_1_0);
                    yy                <=  yy << 1;
                    loop_counter      <=  loop_counter == (K*N-1) ? loop_counter : loop_counter + 1;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result[wr_addr]   <=  task_res;
                end
            end
            //store result and decide whether to skip state_1_1
            state_2_1:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  (loop_counter == (K*N-1)) ? state_3 : state_1_0;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result[wr_addr]   <=  task_res;
                end
            end
            //result = mont_r2mm(result,1,p,nbit)
            state_3:begin
                if((wr_addr_d1 == N-1)&(wr_ena_x | wr_ena_y))begin
                    task_req          <=  1;
                    wr_addr           <=  0;
                    wr_ena_x          <=  0;
                    wr_ena_y          <=  0;
                    current_state     <=  state_4;
                end
                else begin
                    wr_addr           <=  wr_addr + 1;
                    wr_ena_x          <=  1;
                    wr_x              <=  result[wr_addr];
                    wr_ena_y          <=  1;
                    wr_y              <=  wr_addr==0 ? 1 : 0;
                end
            end
            //get final result
            state_4:begin
                if(task_end)begin
                    task_req          <=  0;
                    wr_addr           <=  0;
                    current_state     <=  IDLE;
                end
                if(task_req & task_grant)begin
                    wr_addr           <=  wr_addr + 1;
                    result[wr_addr]   <=  result_backup[wr_addr];
                    result_out        <=  task_res;
                    result_valid      <=  1;  
                end
                else begin
                    result_valid      <=  0;
                end
            end
            //default state
            default:begin
                current_state     <=  IDLE;
            end
        endcase
    end
end


mmp_iddmm_sp #(
        .MULT_METHOD    ("COMMON"       )   // "COMMON"    :use * ,MULT_LATENCY arbitrarily
                                            // "TRADITION" :MULT_LATENCY=9                
                                            // "VEDIC8-8"  :VEDIC MULT, MULT_LATENCY=8 
    ,   .ADD1_METHOD    ("COMMON"       )   // "COMMON"    :use + ,ADD1_LATENCY arbitrarily
                                            // "3-2_PIPE2" :classic pipeline adder,state 2,ADD1_LATENCY=2
                                            // "3-2_PIPE1" :classic pipeline adder,state 1,ADD1_LATENCY=1
                                            // 
    ,   .ADD2_METHOD    ("COMMON"       )   // "COMMON"    :use + ,adder2 has no delay,32*(32+2)=1088 clock
                                            // "3-2_DELAY2":use + ,adder2 has 1  delay,32*(32+2)*2=2176 clock
                                            // 
    ,   .MULT_LATENCY   (0              )
    ,   .ADD1_LATENCY   (0              )
    ,   .K              (K              )   // K bits in every group
    ,   .N              (N              )   // Number of groups
)u_mmp_iddmm_sp(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .wr_ena         (wr_ena         )
    ,   .wr_addr        (wr_addr_d1     )
    ,   .wr_x           (wr_x           )   //low words first
    ,   .wr_y           (wr_y           )   //low words first
    ,   .wr_m           (0              )   //low words first
    ,   .wr_m1          (me_m1          )

    ,   .task_req       (task_req       )
    ,   .task_end       (task_end       )
    ,   .task_grant     (task_grant     )
    ,   .task_res       (task_res       )    
);



assign wr_ena       = {wr_ena_y,wr_ena_x};
assign me_result    = result_out;
assign me_valid     = result_valid;



endmodule
