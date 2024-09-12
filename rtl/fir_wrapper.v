module fir_wrapper #(
    parameter  AXI_BITWIDTH = 32,
               BITWIDTH = 16,
               FRACT = 15
) (
    input clk,rstn,

    input [AXI_BITWIDTH-1:0] s_axis_tdata,
    output s_axis_tready,
    input s_axis_tvalid,
    input s_axis_tlast,

    output [AXI_BITWIDTH-1:0] m_axis_tdata,
    output m_axis_tvalid,
    input m_axis_tready,
    output m_axis_tlast
);

    firFixedAXI wrap_dut (
        .clk(clk),
        .rstn(~rstn),

        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
    
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );
endmodule