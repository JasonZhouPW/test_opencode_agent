#!/bin/bash

# Accept a json file path as parameter
file=$1

if [ -z "$file" ]; then
    echo "Usage: $0 <json_file_path>"
    exit 1
fi

# Run the opencode command
opencode run --model doubao/doubao-seed-1-8-251228 "process ${file} , read the tasks.md and follow the instructions"
