module me_top#(
    parameter K = 8 //K%2==0 AND K<8191
)(
    input                   clk         ,
    input                   rst_n       ,

    input                   me_start    ,
    input       [K-1:0]     me_x        ,
    input       [K-1:0]     me_y        ,
    input       [K-1:0]     me_m        ,

    output      [K-1:0]     me_result   ,
    output                  me_valid    
);

assign big_m    = 8 'he1;
assign big_x    = 8 'h10;
assign big_y    = 8 'h81;
assign rou      = 16'd61;//2^(2*K) mod m

parameter   IDLE        = 0,
            stage_0     = 1,
            stage_1_0   = 2,
            stage_1_1   = 3,
            stage_2     = 4;

reg                     current_stage;   
reg                     mm_req;
wire                    mm_val;
wire        [K-1 : 0]   mm_res;

reg         [K-1 : 0]   mm_x;
reg         [K-1 : 0]   mm_y;
reg         [K-1 : 0]   mm_m;

mm_r2mm_2n#(
    .K ( K )
)mm_r2mm_2n(
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            ),
    .x                       ( mm_x             ),
    .y                       ( mm_y             ),
    .m                       ( mm_m             ),
    .req                     ( mm_req           ),
    .res                     ( mm_res           ),
    .val                     ( mm_val           )
); 

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


reg     [K-1 : 0]   loop_counter;
reg     [K-1 : 0]   result;
reg     [K-1 : 0]   result2;
reg     [K-1 : 0]   yy;
reg                 skip_flag;
reg                 result_valid;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        mm_req          <=  0;
        current_stage   <=  IDLE;
        mm_m            <=  me_m;
        loop_counter    <=  0;
        result          <=  8 'd31;//1*2^(K) mod m
        result2         <=  0;
        yy              <=  me_y;
        skip_flag       <=  0;
        result_valid    <=  0;
    end
    else begin
        case (current_stage)
            IDLE:begin
                result_valid    <=  0;
                if(me_start)begin
                    mm_req          <=  1;
                    mm_x            <=  me_x;
                    mm_y            <=  rou;
                    current_stage   <=  stage_0;
                end
            end
            stage_0:begin
                mm_req          <=  0;
                if(mm_val)begin
                    result2         <=  mm_res;
                    mm_req          <=  1;
                    mm_x            <=  result;
                    mm_y            <=  result;
                    current_stage   <=  stage_1_1;
                end
            end
            stage_1_0:begin
                mm_req          <=  0;
                if(mm_val | skip_flag)begin
                    if(loop_counter == K -1)begin
                        mm_req          <=  1;
                        mm_x            <=  mm_res;
                        mm_y            <=  1;
                        current_stage   <=  stage_2;
                    end
                    else begin
                        skip_flag       <=  0;
                        mm_req          <=  1;
                        mm_x            <=  mm_res;
                        mm_y            <=  mm_res;
                        current_stage   <=  stage_1_1;
                    end
                end
            end
            stage_1_1:begin
                mm_req          <=  0;
                if(mm_val)begin
                    if(yy[0])begin
                        mm_req          <=  1;
                        mm_x            <=  mm_res;
                        mm_y            <=  result2;
                    end
                    else begin
                        skip_flag       <=  1;
                    end
                    current_stage   <=  stage_1_0;
                    yy              <=  yy >> 1;
                    loop_counter    <=  loop_counter + 1;
                end
            end
            stage_2:begin
                mm_req          <=  0;
                if(mm_val)begin
                    result          <=  mm_res;
                    result_valid    <=  1;
                    current_stage   <=  IDLE;
                end
            end
        endcase
    end
end




assign me_result    = result;
assign me_valid     = result_valid;






























endmodule