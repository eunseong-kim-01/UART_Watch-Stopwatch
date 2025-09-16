`timescale 1ns / 1ps

module interpreter (
    input  [7:0] i_rx_data,
    input        i_rx_not_empty_tick, // RENAMED: Port name updated
    output       o_run,          
    output       o_stop,        
    output       o_clear,
    output       o_mode,
    output       o_display_mode, 
    output       o_sec_plus,
    output       o_min_plus,
    output       o_hour_plus
);
    reg r_run, r_stop, r_clear, r_mode, r_display_mode, r_sec_plus, r_min_plus, r_hour_plus;

    assign o_run          = r_run;
    assign o_stop         = r_stop;
    assign o_clear        = r_clear;
    assign o_mode         = r_mode;
    assign o_display_mode = r_display_mode;
    assign o_sec_plus     = r_sec_plus;
    assign o_min_plus     = r_min_plus;
    assign o_hour_plus    = r_hour_plus;

    always @(*) begin
        r_run = 1'b0;
        r_stop = 1'b0; 
        r_clear = 1'b0; 
        r_mode = 1'b0;
        r_display_mode = 1'b0; 
        r_sec_plus = 1'b0; 
        r_min_plus = 1'b0;
        r_hour_plus = 1'b0;

        if (i_rx_not_empty_tick) begin
            case (i_rx_data)
                "r": r_run   = 1'b1;
                "s": r_stop  = 1'b1;
                "c": r_clear = 1'b1;
                "m": r_mode  = 1'b1;
                "d": r_display_mode = 1'b1;
                "S": r_sec_plus = 1'b1;
                "M": r_min_plus = 1'b1;
                "H": r_hour_plus = 1'b1;
            endcase
        end
    end

endmodule
