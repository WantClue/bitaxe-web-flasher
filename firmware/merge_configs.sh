#!/bin/bash

# Check if esptool.py is installed and accessible
if ! command -v esptool.py &> /dev/null; then
    echo "esptool.py is not installed or not in PATH. Please install it first."
    echo "pip install esptool"
    exit 1
fi

# Base name for output files
base_output_file="output"

# Check if the required bin files exist
common_required_files=("build/bootloader/bootloader.bin" "build/partition_table/partition-table.bin" "build/esp-miner.bin" "build/www.bin" "build/ota_data_initial.bin")
config_files=("config_201.bin" "config_202.bin" "config_203.bin" "config_204.bin")

for config_file in "${config_files[@]}"; do
    if [ ! -f "$config_file" ]; then
        echo "Required config file $config_file does not exist. Make sure to build first."
        exit 1
    fi
done

for file in "${common_required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Required file $file does not exist. Make sure to build first."
        exit 1
    fi
done

# Loop through each config file and generate a corresponding output file
for config_file in "${config_files[@]}"; do
    output_file="${base_output_file}_${config_file%.bin}.bin" # Remove .bin from config_file for naming
    echo "Generating $output_file with $config_file..."
    
    # Call esptool.py with the specified arguments for each config file
    esptool.py --chip esp32s3 merge_bin --flash_mode dio --flash_size 8MB --flash_freq 80m 0x0 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0x9000 "$config_file" 0x10000 build/esp-miner.bin 0x410000 build/www.bin 0xf10000 build/ota_data_initial.bin -o "$output_file"
    
    # Check if esptool.py command was successful
    if [ $? -eq 0 ]; then
        echo "Successfully created $output_file"
    else
        echo "Failed to create $output_file"
        exit 1
    fi
done
