`timescale 1ns / 1ps

module fpga_top (
    input       clk,
    input       rst,
    input       Btn_U,
    input       Btn_L,
    input       Btn_D,
    input       Btn_R,
    input [1:0] sw,
    input       rx,

    output       tx,
 
    output [3:0] led,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    // --- UART & Command CU Signals ---
    wire [7:0] w_rx_data;
    wire       w_rx_empty;

    // --- Edge Detector for UART RX Data Arrival ---
    reg        r_rx_empty_prev;
    wire       w_rx_not_empty_tick;

    // Detects the moment FIFO goes from empty (prev=1) to not-empty (current=0)
    assign w_rx_not_empty_tick = r_rx_empty_prev && ~w_rx_empty;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_rx_empty_prev <= 1'b1;
        end else begin
            r_rx_empty_prev <= w_rx_empty;
        end
    end

    // Pop signal is now driven by the one-cycle edge detector tick
    wire w_rx_pop = w_rx_not_empty_tick;

    wire w_cmd_run, w_cmd_stop, w_cmd_clear, w_cmd_mode, w_cmd_display_mode;
    wire w_cmd_sec_plus, w_cmd_min_plus, w_cmd_hour_plus;
    // --- Control Logic Signals ---
    wire w_mode_sel, w_fnd_mode;
    wire w_final_run, w_final_stop, w_final_clear;
    wire w_final_sec_plus, w_final_min_plus, w_final_hour_plus;
    // --- Feedback Signal ---
    wire w_is_running;
    // --- Module Instantiations ---
    uart_top U_UART_TOP (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_rx_pop(w_rx_pop),
        .tx(tx),
        .o_rx_data(w_rx_data),
        .o_rx_empty(w_rx_empty)
    );
    interpreter U_INTERPRETER (
        .i_rx_data(w_rx_data),
        .i_rx_not_empty_tick(w_rx_not_empty_tick),
        .o_run(w_cmd_run),
        .o_stop(w_cmd_stop),
        .o_clear(w_cmd_clear),
        .o_mode(w_cmd_mode),
        .o_display_mode(w_cmd_display_mode),
        .o_sec_plus(w_cmd_sec_plus),
        .o_min_plus(w_cmd_min_plus),
        .o_hour_plus(w_cmd_hour_plus)
    );
    control_input U_CONTROL_INPUT (
        .clk(clk),
        .rst(rst),
        .i_btn_U(Btn_U),
        .i_btn_L(Btn_L),
        .i_btn_D(Btn_D),
        .i_btn_R(Btn_R),
        .i_sw(sw),
        // Connect to renamed ports
        .i_run(w_cmd_run),
        .i_stop(w_cmd_stop),
        .i_clear(w_cmd_clear),
        .i_mode(w_cmd_mode),
        .i_display_mode(w_cmd_display_mode),
        .i_sec_plus(w_cmd_sec_plus),
        .i_min_plus(w_cmd_min_plus),
        .i_hour_plus(w_cmd_hour_plus),
        .i_is_running(w_is_running),
        .o_mode_sel(w_mode_sel),
        .o_fnd_mode(w_fnd_mode),
        .o_final_run(w_final_run),
        .o_final_stop(w_final_stop),
        .o_final_clear(w_final_clear),
        .o_final_sec_plus(w_final_sec_plus),
        .o_final_min_plus(w_final_min_plus),
        .o_final_hour_plus(w_final_hour_plus)
    );
    watch_stopwatch U_WATCH_STOPWATCH (
        .clk(clk),
        .rst(rst),
        .i_sec_plus(w_final_sec_plus),
        .i_min_plus(w_final_min_plus),
        .i_hour_plus(w_final_hour_plus),
        .i_run(w_final_run),
        .i_stop(w_final_stop),
        .i_clear(w_final_clear),
        .i_mode_sel({w_mode_sel, w_fnd_mode}),
        .o_is_running(w_is_running),
        .led(led),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule
