#!/bin/bash

# Function to recursively copy files
copy_files() {
    local src="$1"
    local dest="$2"
    local exclude=("${@:3}") # Store the exclude patterns in an array
    # echo "2 -> ${exclude[@]}"

    # Loop through each item in the source directory
    for item in "$src"/* "$src"/.*; do
        if [[ "$item" == "$src/." || "$item" == "$src/.." ]]; then
            continue # Skip current and parent directory
        fi
        if [[ -d "$item" ]]; then
            # If it's a directory

            local basename=$(basename "$item")
            local exclude_match=0

            # Check if the basename matches any of the exclude patterns
            for pattern in "${exclude[@]}"; do
                if [[ $basename == "$pattern" ]]; then
                    exclude_match=1
                    break
                fi
            done

            if [[ $exclude_match -eq 0 ]]; then
                # Copy the directory recursively if it doesn't match any exclude pattern
                cp -fr "$item" "$dest/"
            fi
        elif [[ -f "$item" ]]; then
            # If it's a file, just copy it
            cp "$item" "$dest/"
        fi
    done
}

# Check for correct number of arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 source_directory destination_directory [--exclude=pattern1,pattern2,...]"
    exit 1
fi

source_dir="$1"
dest_dir="$2"

# Parse optional exclude argument
exclude=()
for arg in "$@"; do
    if [[ $arg == "--exclude="* ]]; then
        exclude_string="${arg#--exclude=}"
        IFS=',' read -ra exclude <<<"$exclude_string"
    fi
done

# Check if source directory exists
if [[ ! -d "$source_dir" ]]; then
    echo "Source directory does not exist."
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Copy files from source directory to destination directory
copy_files "$source_dir" "$dest_dir" "${exclude[@]}"

echo "Files copied successfully."
