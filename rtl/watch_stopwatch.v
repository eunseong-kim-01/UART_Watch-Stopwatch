`timescale 1ns / 1ps

module watch_stopwatch (
    input        clk,
    input        rst,
    input        i_sec_plus,
    input        i_min_plus,
    input        i_hour_plus,
    input        i_run,
    input        i_stop,
    input        i_clear,
    input  [1:0] i_mode_sel,    // sw[1]=watch/stopwatch, sw[0]=fnd mode
    output       o_is_running,  // stopwatch out
    output [3:0] led,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [23:0] w_watch, w_stopwatch, w_watch_stopwatch;
    wire [6:0] w_msec_w, w_msec_s;
    wire [5:0] w_sec_w, w_sec_s;
    wire [5:0] w_min_w, w_min_s;
    wire [4:0] w_hour_w, w_hour_s;
    wire watch_rst, stopwatch_rst;

    assign watch_rst = (i_mode_sel[1] == 1'b0) ? rst : 1'b0;
    assign stopwatch_rst = (i_mode_sel[1] == 1'b1) ? rst : 1'b0;

    decoder_led_2x4 U_DECODER_LED (
        .sel(i_mode_sel),
        .led(led)
    );

    watch_top U_WATCH (
        .clk(clk),
        .rst(watch_rst),
        .i_sec_plus(i_sec_plus),
        .i_min_plus(i_min_plus),
        .i_hour_plus(i_hour_plus),
        .msec(w_msec_w),
        .sec(w_sec_w),
        .min(w_min_w),
        .hour(w_hour_w)
    );
    stopwatch_top U_STOPWATCH (
        .clk(clk),
        .rst(stopwatch_rst),
        .i_run(i_run),
        .i_stop(i_stop),
        .i_clear(i_clear),
        .o_is_running(o_is_running),
        .msec(w_msec_s),
        .sec(w_sec_s),
        .min(w_min_s),
        .hour(w_hour_s)
    );
    mux_watch_stopwatch_2x1 U_MUX_WATCH_STOPWATCH (
        .watch({w_hour_w, w_min_w, w_sec_w, w_msec_w}),
        .stopwatch({w_hour_s, w_min_s, w_sec_s, w_msec_s}),
        .sel(i_mode_sel[1]),
        .bcd(w_watch_stopwatch)
    );
    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(rst),
        .i_time(w_watch_stopwatch),
        .mode(i_mode_sel[0]),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );
endmodule

module decoder_led_2x4 (
    input  [1:0] sel,
    output [3:0] led
);
    assign led = (sel == 2'b00) ? 4'b0001 :
                 (sel == 2'b01) ? 4'b0010 :
                 (sel == 2'b10) ? 4'b0100 :
                 (sel == 2'b11) ? 4'b1000 : 4'b1111;
endmodule

module mux_watch_stopwatch_2x1 (
    input [23:0] watch,
    input [23:0] stopwatch,
    input sel,
    output [23:0] bcd
);
    assign bcd = (sel == 1'b0) ? watch : stopwatch;
endmodule
