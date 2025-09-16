`timescale 1ns / 1ps

module watch_cu(
    input  clk,
    input  rst,
    input  i_sec_plus,
    input  i_min_plus,
    input  i_hour_plus,
    output o_sec_plus,
    output o_min_plus,
    output o_hour_plus
    );
    // state define
    parameter WATCH = 2'b00, SEC_PLUS = 2'b01, MIN_PLUS = 2'b10, HOUR_PLUS = 2'b11;
    reg [1:0] c_state, n_state;
    reg secplus_reg, secplus_next;
    reg minplus_reg, minplus_next;
    reg hourplus_reg, hourplus_next;

    assign o_sec_plus = secplus_reg;
    assign o_min_plus = minplus_reg;
    assign o_hour_plus = hourplus_reg;


    // state register SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state     <= WATCH;  //sl -> nonblock
            secplus_reg <= 1'b0;
            minplus_reg <= 1'b0;
            hourplus_reg <= 1'b0;
        end else begin
            c_state     <= n_state;
            secplus_reg <= secplus_next;
            minplus_reg <= minplus_next;
            hourplus_reg <= hourplus_next;
        end
    end

    // next combinational logic CL
    always @(*) begin
        n_state      = c_state;
        secplus_next = secplus_reg;
        minplus_next = minplus_reg;
        hourplus_next = hourplus_reg;
        case (c_state)
            WATCH: begin
                // moore output
                secplus_next = 1'b0;
                minplus_next = 1'b0;
                hourplus_next = 1'b0;
                // next state
                if (i_sec_plus) begin
                    n_state = SEC_PLUS;
                end else if (i_min_plus) begin
                    n_state = MIN_PLUS;
                end else if(i_hour_plus) begin
                    n_state = HOUR_PLUS;
                end
            end
            SEC_PLUS: begin
                secplus_next = 1'b1;
                if (i_sec_plus == 0) begin
                    n_state = WATCH;
                end
            end
            MIN_PLUS: begin
                minplus_next = 1'b1;
                if (i_min_plus == 0) begin
                    n_state = WATCH;
                end
            end
            HOUR_PLUS: begin
                hourplus_next = 1'b1;
                if (i_hour_plus == 0) begin
                    n_state = WATCH;
                end
            end
        endcase
    end



endmodule
