#!/bin/bash

# Check if esptool.py is installed and accessible
if ! command -v esptool.py &> /dev/null; then
    echo "esptool.py is not installed or not in PATH. Please install it first."
    echo "pip install esptool"
    exit 1
fi

# Base directory for required files
base_dir="/esp-miner"

# Base name for output files
base_output_file="${base_dir}/output"

# Check if the required bin files exist
common_required_files=("bootloader/bootloader.bin" "partition_table/partition-table.bin" "esp-miner.bin" "www.bin" "ota_data_initial.bin")
config_files=("config_201.bin" "config_202.bin" "config_203.bin" "config_204.bin")

# Validate existence of common required files
for file in "${common_required_files[@]}"; do
    if [ ! -f "${base_dir}/build/${file}" ]; then
        echo "Required file ${base_dir}/build/${file} does not exist. Make sure to build first."
        exit 1
    fi
done

# Validate existence of config files
for config_file in "${config_files[@]}"; do
    if [ ! -f "${base_dir}/${config_file}" ]; then
        echo "Required config file ${base_dir}/${config_file} does not exist. Make sure to build it first."
        exit 1
    fi
done

# Loop through each config file and generate a corresponding output file
for config_file in "${config_files[@]}"; do
    # Construct the output file name
    output_file="${base_output_file}_${config_file%.bin}.bin"
    echo "Generating $output_file with $config_file..."
    
    # Call esptool.py with the specified arguments for each config file
    esptool.py --chip esp32s3 merge_bin --flash_mode dio --flash_size 8MB --flash_freq 80m \
    0x0 "${base_dir}/build/bootloader/bootloader.bin" \
    0x8000 "${base_dir}/build/partition_table/partition-table.bin" \
    0x9000 "${base_dir}/${config_file}" \
    0x10000 "${base_dir}/build/esp-miner.bin" \
    0x410000 "${base_dir}/build/www.bin" \
    0xf10000 "${base_dir}/build/ota_data_initial.bin" -o "$output_file"
    
    # Check if esptool.py command was successful
    if [ $? -eq 0 ]; then
        echo "Successfully created $output_file"
    else
        echo "Failed to create $output_file"
        exit 1
    fi
done
