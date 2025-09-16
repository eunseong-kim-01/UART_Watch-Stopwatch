`timescale 1ns / 1ps

module stopwatch_cu (
    input  clk,
    input  rst,
    input  i_run,   
    input  i_stop,  
    input  i_clear,
    output o_run, 
    output o_clear
);
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
    reg [1:0] c_state, n_state;
    reg run_reg, run_next;
    reg clear_reg, clear_next;

    assign o_run = run_reg; 
    assign o_clear = clear_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state   <= STOP;
            run_reg   <= 1'b0;
            clear_reg <= 1'b0;
        end else begin
            c_state   <= n_state;
            run_reg   <= run_next;
            clear_reg <= clear_next;
        end
    end

    always @(*) begin
        n_state    = c_state;
        run_next   = run_reg;
        clear_next = clear_reg;
        case (c_state)
            STOP: begin
                run_next = 1'b0;
                clear_next = 1'b0;
                if (i_run) begin     
                    n_state = RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end
            end
            RUN: begin
                run_next = 1'b1;
                if (i_stop) begin    
                    n_state = STOP;
                end
            end
            CLEAR: begin
                clear_next = 1'b1;
                n_state = STOP;
            end
        endcase
    end
endmodule