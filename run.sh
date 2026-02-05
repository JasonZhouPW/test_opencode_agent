#!/bin/bash
# Process all JSON files in the specified directory
input_dir=$1

if [ -z "$input_dir" ]; then
    echo "Usage: $0 <input_directory>"
    exit 1
fi

if [ ! -d "$input_dir" ]; then
    echo "Error: Directory '$input_dir' does not exist"
    exit 1
fi

process_file() {
    local file=$1
    echo "Processing file: ${file}"
    # Run the opencode command
    opencode run --model nvidia/z-ai/glm4.7 "process ${file} , read the tasks.md and follow the instructions"
}

# Process all .json files in the specified directory (non-recursive)
process_directory() {
    local dir=$1
    echo "Processing directory: $dir"
    
    # Get count of json files
    file_count=$(find "$dir" -maxdepth 1 -name "*.json" -type f | wc -l)
    
    if [ "$file_count" -eq 0 ]; then
        echo "No .json files found in directory: $dir"
        return
    fi
    
    echo "Found $file_count .json files to process"
    
    # Process each .json file in the directory
    for json_file in "$dir"/*.json; do
        # Check if file exists (handles case where no files match)
        if [ -f "$json_file" ]; then
            process_file "$json_file"
        fi
    done
    
    echo "Completed processing all files in directory: $dir"
}

# Main execution - process directory
process_directory "$input_dir"
else
    echo "Error: $path is not a valid file or directory."
    exit 1
fi
