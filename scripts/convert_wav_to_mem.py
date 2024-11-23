import os
import numpy as np
from scipy.io import wavfile

def convert_wav_to_mem(input_dir, output_dir):
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Loop through all files in the input directory
    for filename in os.listdir(input_dir):
        if filename.endswith(".wav"):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, f"{os.path.splitext(filename)[0]}.mem")
            
            # Load WAV file
            rate, data = wavfile.read(input_path)
            
            # Handle stereo audio by converting to mono if necessary
            if len(data.shape) > 1:
                data = np.mean(data, axis=1)
            
            # Normalize to 8-bit range
            normalized_data = ((data / np.max(np.abs(data))) * 127 + 128).astype(np.uint8)
            
            # Calculate padding required to make the sample count divisible by 8
            remainder = len(normalized_data) % 8
            if remainder != 0:
                padding = 8 - remainder
                normalized_data = np.pad(normalized_data, (0, padding), 'constant', constant_values=0)
            
            # Save as .mem file
            with open(output_path, 'w') as f:
                for sample in normalized_data:
                    f.write(f"{sample:02x}\n")
            
            # Print sample count for the file (after padding)
            print(f"Processed {filename}: {len(normalized_data)} samples (including padding) saved to {output_path}")

# Define the input and output directories
input_directory = "./assets/"    # Replace with the path to your WAV directory
output_directory = "./rtl/mem/"  # Replace with the path to save MEM files

# Convert all WAV files in the directory
convert_wav_to_mem(input_directory, output_directory)
