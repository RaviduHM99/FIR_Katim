module axis_vip_tb();
    localparam CLK_PERIOD = 7.8125;

    logic aclk_0 = 0;
    logic aresetn_0 = 0;

    design_3_wrapper dut (
        .aclk_0(aclk_0),
        .aresetn_0(aresetn_0));
    
    initial forever #(CLK_PERIOD/2) aclk_0 <= ~aclk_0;

    initial begin
        @(posedge aclk_0);
        aresetn_0 <= 0;
        #(CLK_PERIOD*3)
        aresetn_0 <= 1;
    end
endmodule