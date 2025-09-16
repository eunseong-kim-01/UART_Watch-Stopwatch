`timescale 1ns / 1ps

module stopwatch_top (
    input        clk,
    input        rst,
    input        i_run,
    input        i_stop,
    input        i_clear,
    output       o_is_running,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_clear_cu;

    stopwatch_dp U_STOPWATCH_DP (
        .clk(clk),
        .rst(rst),
        .i_runstop(o_is_running), 
        .i_clear(w_clear_cu),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );
    stopwatch_cu U_STOPWATCH_CU (
        .clk(clk),
        .rst(rst),
        .i_run(i_run),
        .i_stop(i_stop),
        .i_clear(i_clear),
        .o_run(o_is_running),
        .o_clear(w_clear_cu)
    );
endmodule
