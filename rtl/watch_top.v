`timescale 1ns / 1ps

module watch_top (
    input        clk,
    input        rst,
    // Btn_ U,L,D 입력이 최종 제어 신호로 변경됨
    input        i_sec_plus,
    input        i_min_plus,
    input        i_hour_plus,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    // 최종 제어 신호를 직접 받으므로 더 이상 디바운서가 필요 없음
    
    // CU와 DP를 연결하는 와이어
    wire w_secplus_from_cu;
    wire w_minplus_from_cu;
    wire w_hourplus_from_cu;

    watch_dp U_WATCH_DP (
        .clk(clk),
        .rst(rst),
        .i_sec_plus(w_secplus_from_cu),
        .i_min_plus(w_minplus_from_cu),
        .i_hour_plus(w_hourplus_from_cu),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
    
    watch_cu U_WATCH_CU (
        .clk(clk),
        .rst(rst),
        // CU는 최종 제어 신호를 직접 입력받음
        .i_sec_plus(i_sec_plus),
        .i_min_plus(i_min_plus),
        .i_hour_plus(i_hour_plus),
        .o_sec_plus(w_secplus_from_cu),
        .o_min_plus(w_minplus_from_cu),
        .o_hour_plus(w_hourplus_from_cu)
    );
endmodule
