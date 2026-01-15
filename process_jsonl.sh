#!/bin/bash

# Ensure tmp directory exists
mkdir -p ./tmp

# Loop through all jsonl files in raw_datasets
for file in raw_datasets/*.jsonl; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    echo "Processing file: $file"
    
    # Read each line of the jsonl file using file descriptor 3
    # This avoids conflicts with commands inside the loop that might read from stdin
    while IFS= read -r line <&3; do
        if [ -z "$line" ]; then
            continue
        fi
        
        # Use python3 to parse the line and extract org, repo, and number
        # We output a filename and the content to be written, or SKIP if patch exists
        result=$(echo "$line" | python3 -c "
import json, sys, os
try:
    data = json.load(sys.stdin)
    org = data.get('org', 'unknown')
    repo = data.get('repo', 'unknown')
    number = data.get('number', 'unknown')
    
    # Check if patch already exists
    p1 = f'patches/{org}_{repo}_{number}.diff'
    p2 = f'patches/{org}__{repo}__{number}.diff'
    if os.path.exists(p1) or os.path.exists(p2):
        print('SKIP')
    else:
        print(f'{org}_{repo}_{number}.json')
except Exception as e:
    sys.exit(1)
" 2>/dev/null)
        
        exit_code=$?
        
        if [ $exit_code -ne 0 ] || [ -z "$result" ]; then
            echo "Failed to parse line: $line"
            continue
        fi
        
        if [ "$result" == "SKIP" ]; then
            echo "Patch already exists, skipping."
            continue
        fi
        
        tmp_file="./tmp/$result"
        echo "$line" > "$tmp_file"
        echo "Created $tmp_file, calling ./run.sh"
        ./run.sh "$tmp_file"
        
    done 3< "$file"
done
