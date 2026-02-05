#!/bin/bash

# Process JSONL files script
# Usage: ./process_jsonl.sh <input_dir> <output_dir>

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir>"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"

# Validate input directory
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required but not installed. Please install jq to parse JSON files."
    exit 1
fi

# Counter for processed files
processed_count=0
error_count=0

# Process each jsonl file in the input directory
for jsonl_file in "$INPUT_DIR"/*.jsonl; do
    # Check if the file exists (no match case)
    if [ ! -f "$jsonl_file" ]; then
        echo "Warning: No .jsonl files found in '$INPUT_DIR'"
        continue
    fi
    
    echo "Processing: $jsonl_file"
    
    # Get the base name of the file (without path and extension)
    base_name=$(basename "$jsonl_file" .jsonl)
    
    # Line counter for this file
    line_num=0
    
    # Read each line from the jsonl file
    while IFS= read -r line || [ -n "$line" ]; do
        line_num=$((line_num + 1))
        
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        
        # Try to parse the JSON line
        if ! echo "$line" | jq empty 2>/dev/null; then
            echo "Warning: Invalid JSON on line $line_num of $jsonl_file, skipping..."
            error_count=$((error_count + 1))
            continue
        fi
        
        # Check if instance_id exists in the JSON
        instance_id=$(echo "$line" | jq -r '.instance_id // empty')
        
        if [ -n "$instance_id" ] && [ "$instance_id" != "null" ]; then
            # Use instance_id as filename
            output_file="${OUTPUT_DIR}/${instance_id}.json"
        else
            # Extract org, repo, and number for filename
            org=$(echo "$line" | jq -r '.org // empty')
            repo=$(echo "$line" | jq -r '.repo // empty')
            number=$(echo "$line" | jq -r '.number // empty')
            
            # Validate required fields
            if [ -n "$org" ] && [ -n "$repo" ] && [ -n "$number" ] && \
               [ "$org" != "null" ] && [ "$repo" != "null" ] && [ "$number" != "null" ]; then
                output_file="${OUTPUT_DIR}/${org}_${repo}-${number}.json"
            else
                # Fallback to line-based naming if required fields are missing
                output_file="${OUTPUT_DIR}/${base_name}_line${line_num}.json"
                echo "Warning: Missing required fields for standard naming in line $line_num of $jsonl_file, using fallback name"
                error_count=$((error_count + 1))
            fi
        fi
        
        # Write the JSON content to the output file
        echo "$line" > "$output_file"
        
        if [ $? -eq 0 ]; then
            echo "  Created: $(basename "$output_file")"
            processed_count=$((processed_count + 1))
        else
            echo "  Error: Failed to write $(basename "$output_file")"
            error_count=$((error_count + 1))
        fi
        
    done < "$jsonl_file"
    
    echo "Finished processing: $jsonl_file"
    echo "---"
done

# Summary
echo "Processing complete!"
echo "Files processed successfully: $processed_count"
echo "Errors encountered: $error_count"

if [ $error_count -gt 0 ]; then
    echo "Some files had issues. Please check the warnings above."
    exit 1
else
    exit 0
fi
