`timescale 1ns / 1ps

module uart_top (
    input        clk,
    input        rst,
    input        rx,
    input        i_rx_pop,
    output       tx,
    output [7:0] o_rx_data,
    output       o_rx_empty
);
    wire w_b_tick;
    wire rx_done;
    wire [7:0] w_rx_data, w_tx_fifo_popdata;
    wire w_tx_fifo_full, w_tx_empty, w_tx_busy;
    wire [7:0] w_rx_fifo_popdata;
    wire  w_rx_empty_internal;

    assign o_rx_data  = w_rx_fifo_popdata;
    assign o_rx_empty = w_rx_empty_internal;

    uart_tx U_UART_TX (
        .clk          (clk),
        .rst          (rst),
        .start_trigger(~w_tx_empty),
        .tx_data      (w_tx_fifo_popdata),
        .b_tick       (w_b_tick),
        .tx           (tx),
        .tx_busy      (w_tx_busy)
    );

    fifo U_TX_FIFO (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_fifo_popdata),
        .push     (~w_rx_empty_internal),
        .pop      (~w_tx_busy),
        .pop_data (w_tx_fifo_popdata),
        .full     (w_tx_fifo_full),
        .empty    (w_tx_empty)
    );

    fifo U_RX_FIFO (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_data),
        .push     (rx_done),
        .pop      (i_rx_pop),
        .pop_data (w_rx_fifo_popdata),
        .full     (),
        .empty    (w_rx_empty_internal)
    );

    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .rx     (rx),
        .b_tick (w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(rx_done)
    );

    baud_tick_gen U_BAUD_TICK_GEN (
        .clk   (clk),
        .rst   (rst),
        .b_tick(w_b_tick)
    );
endmodule

module baud_tick_gen (
    input  clk,
    input  rst,
    output b_tick
);
    // baudrate 
    parameter BAUDRATE = 9600 * 16;
    // rx over sampling
    localparam BAUD_COUNT = 100_000_000 / BAUDRATE;
    reg [$clog2(BAUD_COUNT)-1 : 0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    // output
    assign b_tick = tick_reg;
    // SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg    <= 0;
        end else begin
            counter_reg <= counter_next;
            tick_reg    <= tick_next;
        end
    end

    // next CL
    always @(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        if (counter_reg == BAUD_COUNT - 1) begin
            counter_next = 0;
            tick_next = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end

endmodule
