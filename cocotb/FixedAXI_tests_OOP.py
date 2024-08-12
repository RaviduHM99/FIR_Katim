import numpy as np

import cocotb
from cocotbext.axi import AxiStreamSource, AxiStreamBus, AxiStreamSink
from cocotb.triggers import Timer, RisingEdge

CLK_CYCLES = 1000
CLK_PERIOD = 10
ORDER = 50
BIT_WIDTH = 16
FRACTIONAL_BITS = 15
PIPE_DELAY = 3

def fixed_to_float_manual(binary_str, integer_bits, fractional_bits):
    # Convert the integer part
    integer_part = int(binary_str[:integer_bits], 2)
    
    # Handle the sign for two's complement
    if binary_str[0] == '1':  # Sign bit is set
        integer_part -= (1 << integer_bits)
    
    # Convert the fractional part
    fractional_part = int(binary_str[integer_bits:], 2) / (1 << fractional_bits)
    
    # Combine the integer and fractional parts
    float_value = integer_part + fractional_part
    
    return float_value

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(CLK_CYCLES):
        dut.clk.value = 0
        await Timer(CLK_PERIOD//2, units="ns")
        dut.clk.value = 1
        await Timer(CLK_PERIOD//2, units="ns")

@cocotb.test()
async def fixedAXI_test_impulse(dut): 
    """Impluse Resopnse of the filter"""

    #Load Reference Output Data
    refData = np.loadtxt("../packages/filter_coefficients.txt", dtype=float)
    outData = np.zeros(len(refData))
    inData = [0x1]
    for i in range(50):
        inData.append(0x0)

    #Generate Clock and Initialize Inputs to zero
    dut.rstn.value = 0
    await cocotb.start(generate_clock(dut))

    #Reset the device
    dut.rstn.value = 1
    await RisingEdge(dut.clk)
    await Timer(CLK_PERIOD*2, units="ns")

    #Enable FIR Filter
    dut.rstn.value = 0
    axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rstn)
    axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rstn)
    dut._log.info("axis_source wait for data")
    await axis_source.send(inData)
    await axis_source.wait()
    dut._log.info("axis_source sent data")
    #Check Expected Data vs Output Data
    axis_out_data = await axis_sink.read()
    dut._log.info("axis_sink recieved data")
    dut._log.info("%s", axis_out_data)
    dut._log.info("%s", len(axis_out_data))
    
    # for cycle in range(len(axis_out_data)):
    #     outData[cycle] = fixed_to_float_manual(bin(axis_out_data[cycle])[2:], BIT_WIDTH-FRACTIONAL_BITS, FRACTIONAL_BITS)
    #     assert (abs(refData[cycle]-outData[cycle]) < 0.001), f"[{cycle}] Impulse Response is incorrect: {outData[cycle]} but correct value: {refData[cycle]}"
    
    np.savetxt("../cocotb/impulse_response.txt", outData, fmt='%.20f')