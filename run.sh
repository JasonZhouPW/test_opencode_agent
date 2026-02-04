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

if [ -d "$path" ]; then
    echo "Processing directory: $path"
    for f in "$path"/*; do
        if [ -f "$f" ]; then
            process_file "$f"
        fi
    done
elif [ -f "$path" ]; then
    process_file "$path"
else
    echo "Error: $path is not a valid file or directory."
    exit 1
fi
