import numpy as np

def writeToTextFile(arr, filename):
    """
    Write filter coefficients to a text file.

    Parameters:
    coefficients (np.array): The filter coefficients.
    filename (str): The name of the file to write to.
    """
    np.savetxt(filename, arr, fmt='%.20f')

def sinc_filter(fc, num_taps, fs):
    """
    Generate Sinc filter coefficients.

    Parameters:
    fc (float): Cutoff frequency of the filter in Hz.
    num_taps (int): Number of filter taps (coefficients).
    fs (float): Sampling frequency in Hz.

    Returns:
    np.array: Filter coefficients.
    """
    # Calculate the filter coefficients
    if num_taps%2 == 1 :
        t = np.arange(-(num_taps // 2), (num_taps // 2) + 1)
    else :
        t = np.arange(-(num_taps // 2), (num_taps // 2))
        
    h = np.sinc(2 * fc * t / fs)
    
    # Apply a window function to the filter coefficients
    window = np.hamming(num_taps)
    h = h * window
    
    # Normalize the filter coefficients
    h = h / np.sum(h)
    
    return h

def generate_random_numbers(num_numbers, lower_bound, upper_bound):
    """
    Generate a list of random real numbers within a specified range.

    Parameters:
    num_numbers (int): Number of random numbers to generate.
    lower_bound (float): Lower bound of the range.
    upper_bound (float): Upper bound of the range.

    Returns:
    np.array: Array of random real numbers.
    """
    return np.random.uniform(lower_bound, upper_bound, num_numbers)


if __name__ == "__main__":

    # Generate Coefficients
    fc = 0.1
    order = 50
    num_taps = order + 1
    fs = 1

    coefficients = sinc_filter(fc, num_taps, fs)
    writeToTextFile(coefficients, "../packages/filter_coefficients.txt")

    # Generate Inputs
    num_numbers = 50
    lower_bound = -0.9
    upper_bound = 0.9
    
    input_signal = generate_random_numbers(num_numbers, lower_bound, upper_bound)
    #writeToTextFile(input_signal, "filter_inputs.txt")

    # Reference Filter Outputs 
    output_signal = np.convolve(input_signal, coefficients, mode='same')
    writeToTextFile(output_signal, "filter_reference.txt")

