import numpy as np

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge

CLK_CYCLES = 100
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
async def fixed_test_impulse(dut): 
    """Impluse Resopnse of the filter"""

    #Load Reference Output Data
    refData = np.loadtxt("../packages/filter_coefficients.txt", dtype=float)
    outData = np.zeros(len(refData))

    #Generate Clock and Initialize Inputs to zero
    dut.rstn.value = 0
    dut.enable.value = 0
    dut.inX.value = 0
    await cocotb.start(generate_clock(dut))

    #Reset the device
    dut.rstn.value = 1
    await RisingEdge(dut.clk)
    await Timer(CLK_PERIOD*2, units="ns")

    #Enable FIR Filter
    dut.rstn.value = 0
    dut.enable.value = 1
    dut.inX.value = 1
    await Timer(CLK_PERIOD, units="ns")
    dut.inX.value = 0

    #Check Expected Data vs Output Data
    await Timer(CLK_PERIOD*(ORDER//2 + PIPE_DELAY), units="ns")
    for cycle in range(0, ORDER+1):
        floated_outY = fixed_to_float_manual(str(dut.outY.value), BIT_WIDTH-FRACTIONAL_BITS, FRACTIONAL_BITS)
        outData[cycle] = floated_outY
        assert (abs(refData[cycle]-floated_outY) < 0.001), f"[{cycle}] Impulse Response is incorrect: {floated_outY} but correct value: {refData[cycle]}"
        await Timer(CLK_PERIOD, units="ns")
    
    np.savetxt("../cocotb/impulse_response.txt", outData, fmt='%.20f')

# @cocotb.test()
# async def fixed_test_stress(dut): 
#     """Filter Resopnse of the filter to check overflow/underflow issues"""

#     #Load Reference Output Data
#     refData = np.loadtxt("../sim/filter_reference.txt", dtype=float)
#     outData = np.zeros(len(refData))

#     #Generate Clock and Initialize Inputs to zero
#     dut.rstn.value = 0
#     dut.enable.value = 0
#     dut.inX.value = 0
#     await cocotb.start(generate_clock(dut))

#     #Reset the device
#     dut.rstn.value = 1
#     await RisingEdge(dut.clk)
#     await Timer(CLK_PERIOD*2, units="ns")

#     #Enable FIR Filter
#     dut.rstn.value = 0
#     dut.enable.value = 1
#     
#     for cycle in range(1, CLK_CYCLES//2): ####################### to DO output data sync ##################################################
    #     dut.inX.value = 1
    #     await Timer(CLK_PERIOD, units="ns")
    #     dut.inX.value = -1
    #     await Timer(CLK_PERIOD, units="ns")


#     #Check Expected Data vs Output Data
#     if (ORDER%2==0):
#         await Timer(CLK_PERIOD*(ORDER//2), units="ns")
        
#         for cycle in range(1, ORDER+1):
#             dut.__log.info("Filter Output: %s", dut.outY.value)
#             assert (abs(refData[cycle]-dut.outY.value) < 0.1), f"Impulse Response is incorrect: {dut.outY.value} but correct value: {refData[cycle]}"
#             await Timer(CLK_PERIOD, units="ns")
#     else:
#         await Timer(CLK_PERIOD*((ORDER-1)//2), units="ns")
        
#         for cycle in range(1, ORDER+1):
#             dut.__log.info("Filter Output: %s", dut.outY.value)
#             outData[cycle] = dut.outY.value
#             assert (abs(refData[cycle]-dut.outY.value) < 0.1), f"Impulse Response is incorrect: {dut.outY.value} but correct value: {refData[cycle]}"
#             await Timer(CLK_PERIOD, units="ns")
    
#     #Plot Output and Reference waveforms 
#     plt.figure(figsize=(20,20))
#     plt.plot(outData, marker='o', linestyle='-', color='b', label='Output Waveform')
#     plt.plot(refData, marker='s', linestyle='--', color='r', label='Reference Waveform')

#     plt.xlabel("Sample Number")
#     plt.ylabel("Sample Magnitude")
#     plt.title("Output Filter Data vs Expected Filter Data")

#     plt.savefig("Fixed_Stress_Test.png", dpi=300, bbox_inches='tight')

#     plt.show()

