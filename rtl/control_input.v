`timescale 1ns / 1ps

module control_input (
    input       clk,
    input       rst,
    input       i_btn_U,
    input       i_btn_L,
    input       i_btn_D,
    input       i_btn_R,
    input [1:0] i_sw,
    input       i_run,
    input       i_stop,
    input       i_clear,
    input       i_mode,
    input       i_display_mode,
    input       i_sec_plus,
    input       i_min_plus,
    input       i_hour_plus,

    input i_is_running,

    output      o_mode_sel,
    output      o_fnd_mode,
    output      o_final_run,
    output      o_final_stop,
    output      o_final_clear,
    output      o_final_sec_plus,
    output      o_final_min_plus,
    output      o_final_hour_plus
);

    reg o_final_run_reg;
    reg o_final_stop_reg;
    reg o_final_clear_reg;
    reg o_final_sec_plus_reg;
    reg o_final_min_plus_reg;
    reg o_final_hour_plus_reg;

    assign o_final_run       = o_final_run_reg;
    assign o_final_stop      = o_final_stop_reg;
    assign o_final_clear     = o_final_clear_reg;
    assign o_final_sec_plus  = o_final_sec_plus_reg;
    assign o_final_min_plus  = o_final_min_plus_reg;
    assign o_final_hour_plus = o_final_hour_plus_reg;

    wire w_btn_U_d, w_btn_L_d, w_btn_D_d, w_btn_R_d;

    button_debounce U_DEBOUNCE_U (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn_U),
        .o_btn(w_btn_U_d)
    );
    button_debounce U_DEBOUNCE_L (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn_L),
        .o_btn(w_btn_L_d)
    );
    button_debounce U_DEBOUNCE_D (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn_D),
        .o_btn(w_btn_D_d)
    );
    button_debounce U_DEBOUNCE_R (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn_R),
        .o_btn(w_btn_R_d)
    );

    // FSM State Definition
    
    parameter WATCH_MODE = 1'b0, STOPWATCH_MODE = 1'b1;

    reg c_state, n_state;


    // PC Mode Lock Logic
    
    reg pc_mode_lock;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            pc_mode_lock <= 1'b0;
        end else if (i_mode) begin
            pc_mode_lock <= 1'b1;
            // Lock when PC command is received
        end
    end

    // Edge Detection for Switch Changes
    reg  r_sw1_prev;
    wire w_sw1_changed = (i_sw[1] != r_sw1_prev);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= i_sw[1];
            r_sw1_prev <= i_sw[1];
        end else begin
            c_state <= n_state;
            r_sw1_prev <= i_sw[1];
        end
    end

    always @(*) begin
        n_state = c_state;
        if (i_mode || (w_sw1_changed && !pc_mode_lock)) begin
            n_state = ~c_state;
        end
    end


    always @(*) begin
        // Default values for all outputs
        o_final_run_reg       = 1'b0;
        o_final_stop_reg      = 1'b0;
        o_final_clear_reg     = 1'b0;
        o_final_sec_plus_reg  = 1'b0;
        o_final_min_plus_reg  = 1'b0;
        o_final_hour_plus_reg = 1'b0;

        case (c_state)
            WATCH_MODE: begin
                o_final_sec_plus_reg  = w_btn_U_d | i_sec_plus;
                o_final_min_plus_reg  = w_btn_L_d | i_min_plus;
                o_final_hour_plus_reg = w_btn_D_d | i_hour_plus;
            end
            STOPWATCH_MODE: begin
                if (w_btn_R_d || i_run) o_final_run_reg = !i_is_running;
                if (w_btn_R_d || i_stop) o_final_stop_reg = i_is_running;
                o_final_clear_reg = w_btn_L_d | i_clear;
            end
        endcase
    end
    assign o_mode_sel = c_state;




    reg  r_fnd_mode;
    reg  r_sw0_prev;
    wire w_sw0_changed = (i_sw[0] != r_sw0_prev);
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_fnd_mode <= i_sw[0];
            r_sw0_prev <= i_sw[0];
        end else begin
            r_sw0_prev <= i_sw[0];
            if (i_display_mode || w_sw0_changed) begin
                r_fnd_mode <= ~r_fnd_mode;
            end
        end
    end
    assign o_fnd_mode = r_fnd_mode;


endmodule
