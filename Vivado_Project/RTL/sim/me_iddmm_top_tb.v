`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 22:03:08
// Design Name: 
// Module Name: me_iddmm_top_tb
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


module me_iddmm_top_tb();
integer                 i                   ;
parameter               K           = 128   ;
parameter               N           = 16    ;

reg     [K*N-1  : 0]    big_x       = 
2048'h22b9488b532b70043ed0116220ef1c91f03830dcb5aa255c18484dae2ce4cecc8d2ac76151d7d63ce985a13be321ae1f53c33dd2565b46b5088fb1404ca4f4f6c00a21fc4068148cdc1a69a535175244ce0bd94257080365bcc7a5c6bed0f259897930aa8e4c75428ef16f770d4e01a15a9d2ca9cb1948989992a669155c108502a5c88b0a895715edc45226c9d5ba6d293c88c3aaa2bc414ec01841a9589234e68d80f5588fbf366684e32e516092385bd202b0b2fe2a23bd088d47dcd9d956f74506cbe2c28457abec5e600b8cca286f2ca5ba6265d50d8b6429791613ad97c872f0349151830a0c41bd1d786bf68cbf721d374d2520f1dc76a11ced37b118;
reg     [K*N-1  : 0]    result      =   0   ;
parameter               PERIOD      =   10  ;
reg                     clk         =   0   ;
reg                     rst_n       =   0   ;
reg                     me_start    =   0   ;
reg     [K-1    : 0]    me_x        =   0   ;
reg                     me_x_valid  =   0   ;
wire    [K-1    : 0]    me_result           ;
wire                    me_valid            ;

initial begin
    forever #(PERIOD/2)  clk=~clk;
end
initial begin
    #(PERIOD*2) rst_n  =  1;
end

me_iddmm_top u_me_iddmm_top(
        .clk            (clk            )
    ,   .rst_n          (rst_n          )

    ,   .me_start       (me_start       )

    ,   .me_x           (me_x           )
    ,   .me_x_valid     (me_x_valid     )

    ,   .me_result      (me_result      )
    ,   .me_valid       (me_valid       )
);

task rsa2048test; begin
    #(PERIOD*100)
    me_start = 1;
    #(PERIOD)
    me_start = 0;
    #(PERIOD*10)
    for (i = 0; i <= N; i = i + 1) begin
        @(posedge clk)
        me_x        =   big_x >> (K*i);
        me_x_valid  =   1;
    end
    me_x        =   0;
    me_x_valid  =   0;
    wait(me_valid);
    result      = {result[(K*N-128-1):0],me_result};
    for (i = 0; i <= N-1; i = i + 1) begin
        @(posedge clk)
        result      = {me_result,result[(K*N-1):128]};
    end
    $display("[mmp_iddmm_sp_tb.v]result_iddmm: \n0x%x\n",result);
    $stop;
end
endtask


initial begin
    rsa2048test;
end


endmodule
