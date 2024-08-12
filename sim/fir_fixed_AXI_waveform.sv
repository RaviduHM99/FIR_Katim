// Copyright


module firFixedAXI_wv #(
    parameter AXI_BITWIDTH = 32
)
( 
    input logic clk, 
    input logic rstn,

    input logic signed [AXI_BITWIDTH - 1:0] s_axis_tdata,
    output logic s_axis_tready,
    input logic s_axis_tvalid,
    input logic s_axis_tlast,

    output logic signed [AXI_BITWIDTH - 1:0] m_axis_tdata,
    input logic m_axis_tready,
    output logic m_axis_tvalid,
    output logic m_axis_tlast

);
    firFixedAXI dut (
        .clk(clk),
        .rstn(rstn),

        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
    
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tlast(m_axis_tlast)
    );

    initial begin
        $dumpfile ("FIR_Fixed_AXI.vcd");
        $dumpvars ();
    end
endmodule