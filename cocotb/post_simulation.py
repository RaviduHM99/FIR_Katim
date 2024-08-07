import numpy as np
import matplotlib.pyplot as plt

def plot_signals(output, reference_output):
    #Plot Output and Reference waveforms 
    plt.figure(figsize=(20,20))
    plt.plot(output, marker='o', linestyle='-', color='b', label='Output Waveform')
    plt.plot(reference_output, marker='s', linestyle='--', color='r', label='Reference Waveform')

    plt.xlabel("Sample Number")
    plt.ylabel("Sample Magnitude")
    plt.title("Output Filter Data vs Expected Filter Data")
    plt.legend()

    plt.savefig("../cocotb/Fixed_Impluse_Response.png", dpi=300, bbox_inches='tight')

def post_simulation():
    refData = np.loadtxt("../packages/filter_coefficients.txt", dtype=float)
    outData = np.loadtxt("../cocotb/impulse_response.txt", dtype=float)
    plot_signals(refData, outData)

if __name__ == "__main__":
    post_simulation()