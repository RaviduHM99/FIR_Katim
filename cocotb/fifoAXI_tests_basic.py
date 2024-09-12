import numpy as np

import cocotb
from cocotbext.axi import AxiStreamSource, AxiStreamBus, AxiStreamSink
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

CLK_CYCLES = 5000
CLK_PERIOD_FAST = 7.81
CLK_PERIOD_SLOW = 31.25
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

def twos_complement(hexstr, bits):
    value = int(hexstr, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value

async def generate_clock_slow(dut):
    """Generate slow clock pulses."""

    for cycle in range(CLK_CYCLES):
        dut.s_aclk_0.value = 0
        await Timer(CLK_PERIOD_SLOW//2, units="ns")
        dut.s_aclk_0.value = 1
        await Timer(CLK_PERIOD_SLOW//2, units="ns")

async def generate_clock_fast(dut):
    """Generate fast clock pulses."""

    for cycle in range(CLK_CYCLES):
        dut.dest_clk_0.value = 0
        await Timer(CLK_PERIOD_FAST//2, units="ns")
        dut.dest_clk_0.value = 1
        await Timer(CLK_PERIOD_FAST//2, units="ns")

@cocotb.test()
async def fifoAXI_test_impulse(dut): 
    """Impluse Resopnse of the filter"""

    #Load Reference Output Data
    refData = np.loadtxt("../packages/filter_coefficients.txt", dtype=float)
    inData = [0x7FFF]
    for i in range(49):
        inData.append(0x0000)

    #Generate Clocks and Initialize the Device (Reset)
    dut.src_rst_0.value = 0
    # await cocotb.start(generate_clock_slow(dut))
    # await cocotb.start(generate_clock_fast(dut))
    slow_clock = Clock(dut.s_aclk_0, CLK_PERIOD_SLOW, units="ns")
    fast_clock = Clock(dut.dest_clk_0, CLK_PERIOD_FAST, units="ns")
    cocotb.start_soon(slow_clock.start(start_high=False))
    cocotb.start_soon(fast_clock.start(start_high=False))
    await RisingEdge(dut.s_aclk_0)
    await Timer(CLK_PERIOD_SLOW*2, units="ns")

    #Enable the device
    dut.src_rst_0.value = 1

    await RisingEdge(dut.fir_wrapper_0.rstn)
    await RisingEdge(dut.s_aclk_0)
    await Timer(CLK_PERIOD_SLOW*4, units="ns")
    #Enable FIR Filter
    axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "S_AXIS_0"), dut.s_aclk_0, byte_size=32)
    axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "M_AXIS_0"), dut.s_aclk_0, byte_size=32)
    dut._log.info("axis_source wait for data")
    await axis_source.send(inData)
    await axis_source.wait()
    dut._log.info("axis_source sent data")
    #Check Expected Data vs Output Data
    axis_out_hex_data = await axis_sink.recv()
    dut._log.info("axis_sink recieved data")
    axis_out_data = [twos_complement(hex(i)[2:], 8) for i in axis_out_hex_data]
    #dut._log.info("%s", axis_out_data)
    #dut._log.info("%s", len(axis_out_data))
    
    error_nums = 0
    outData = np.zeros(len(axis_out_data))
    for cycle in range(len(axis_out_data)):
        #dut._log.info("%s", format(axis_out_data[cycle] % (1 << BIT_WIDTH), "016b"))
        outData[cycle] = fixed_to_float_manual(format(axis_out_data[cycle] % (1 << BIT_WIDTH), "016b"), BIT_WIDTH-FRACTIONAL_BITS, FRACTIONAL_BITS)
        #assert (abs(refData[cycle]-outData[cycle]) < 0.001), f"[{cycle}] Impulse Response is incorrect: {outData[cycle]} but correct value: {refData[cycle]}"
        if abs(refData[cycle]-outData[cycle]) >= 0.001:
            error_nums += 1
            dut._log.info("[%s] Impulse Response is incorrect: %s but correct value: %s", cycle, outData[cycle], refData[cycle])
    dut._log.info("Errors count: %s", error_nums)
    np.savetxt("../cocotb/impulse_response.txt", outData, fmt='%.20f')