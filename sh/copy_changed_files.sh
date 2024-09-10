#!/bin/bash

# Author: Dave Seidman | @github.com/bullcitydave 
# Significant assistance provided by: Claude 3.5 Sonnet
#
# This script copies Salesforce metadata files that have changed over a specified number of days to a target directory.
# It uses the output from the sf_git_changes_report.sh script to determine which files to copy.
#
# Usage: ./copy_changed_files.sh <number_of_days> <target_directory> <source_directory>
# Example: ./copy_changed_files.sh 7 /path/to/new/repo /path/to/source/repo

# Check if all required parameters are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <number_of_days> <target_directory> <source_directory>"
    echo "Example: $0 7 /path/to/new/repo /path/to/source/repo"
    exit 1
fi

# Get the parameters
DAYS=$1
TARGET_DIR=$2
SOURCE_DIR=$3

# Set the input file name
INPUT_FILE="salesforce_metadata_changes_${DAYS}days.log"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE not found. Please run gitmdtreport.sh first."
    exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Function to create the directory structure and copy the file
copy_file() {
    local file_path=$1
    local full_source_path="$SOURCE_DIR/$file_path"
    local target_path="$TARGET_DIR/$file_path"
    local target_dir=$(dirname "$target_path")
    
    if [ -f "$full_source_path" ]; then
        mkdir -p "$target_dir"
        cp "$full_source_path" "$target_path"
        echo "Copied: $file_path"
    else
        echo "Warning: File not found - $full_source_path"
    fi
}

# Process the input file and copy the changed files
started_processing=false
while IFS= read -r line; do
    # Skip lines until we find the first metadata type
    if ! $started_processing; then
        if [[ $line == *":"* ]]; then
            started_processing=true
        fi
        continue
    fi

    # Process file paths
    if [[ $line != *":"* ]] && [ -n "$line" ]; then
        # Trim leading whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        copy_file "$line"
    fi
done < "$INPUT_FILE"

echo "Finished copying changed files to $TARGET_DIR"
echo "Files not found are listed as warnings above."