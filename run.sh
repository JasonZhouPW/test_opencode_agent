# Accept a path as parameter (can be a file or a directory)
path=$1

if [ -z "$path" ]; then
    echo "Usage: $0 <file_or_directory_path>"
    exit 1
fi

process_file() {
    local file=$1
    echo "Processing file: ${file}"
    # Run the opencode command
    opencode run --model nvidia/z-ai/glm4.7 "process ${file} , read the tasks.md and follow the instructions"
}

# Recursively process all .jsonl files in directory
process_directory() {
    local dir=$1
    echo "Processing directory: $dir"

    # Find all .jsonl files recursively
    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(find "$dir" -name "*.jsonl" -type f -print0)
}

if [ -d "$path" ]; then
    process_directory "$path"
elif [ -f "$path" ]; then
    # Check if the single file is a .jsonl file
    if [[ "$path" == *.jsonl ]]; then
        process_file "$path"
    else
        echo "Error: File must have .jsonl extension"
        exit 1
    fi
else
    echo "Error: $path is not a valid file or directory."
    exit 1
fi
