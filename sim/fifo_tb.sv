module fifo_tb();
    localparam CLK_PERIOD = 7.8125;
    localparam PLL_CLK_PERIOD = 31.25;
    logic [31:0]M_AXIS_0_tdata;
    logic M_AXIS_0_tlast;
    logic M_AXIS_0_tready;
    logic M_AXIS_0_tvalid;
    logic [31:0]S_AXIS_0_tdata;
    logic S_AXIS_0_tlast;
    logic S_AXIS_0_tready;
    logic S_AXIS_0_tvalid;
    logic dest_clk_0 = 0;
    logic s_aclk_0 = 0;
    logic src_rst_0 = 0;

    design_2_wrapper dut (
        .M_AXIS_0_tdata(M_AXIS_0_tdata),
        .M_AXIS_0_tlast(M_AXIS_0_tlast),
        .M_AXIS_0_tready(M_AXIS_0_tready),
        .M_AXIS_0_tvalid(M_AXIS_0_tvalid),
        .S_AXIS_0_tdata(S_AXIS_0_tdata),
        .S_AXIS_0_tlast(S_AXIS_0_tlast),
        .S_AXIS_0_tready(S_AXIS_0_tready),
        .S_AXIS_0_tvalid(S_AXIS_0_tvalid),
        .dest_clk_0(dest_clk_0),
        .s_aclk_0(s_aclk_0),
        .src_rst_0(src_rst_0));
    
    initial forever #(CLK_PERIOD/2) dest_clk_0 <= ~dest_clk_0;
    initial forever #(PLL_CLK_PERIOD/2) s_aclk_0 <= ~s_aclk_0;

    localparam n = 1; //how many cycles need to capture data by fifo input stream
    initial begin
      @(posedge s_aclk_0);
      #(PLL_CLK_PERIOD*2)
      src_rst_0 <= 1;

      M_AXIS_0_tready <= 1;
      wait (dut.design_2_i.fir_wrapper_0.rstn == 1'b1);

      @(posedge s_aclk_0);
      #(PLL_CLK_PERIOD*4)
      S_AXIS_0_tdata <= 'd32767;
      S_AXIS_0_tlast <= 0;
      S_AXIS_0_tvalid <= 1;

      #(PLL_CLK_PERIOD*n)
      S_AXIS_0_tdata <= 'd0;

      #(PLL_CLK_PERIOD*49)
      S_AXIS_0_tlast <= 1;
      #(PLL_CLK_PERIOD)
      S_AXIS_0_tvalid <= 0;
      S_AXIS_0_tlast <= 0;
      #(PLL_CLK_PERIOD*500)
      $finish();
    end
endmodule