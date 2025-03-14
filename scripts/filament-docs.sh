#!/usr/bin/env bash

function docs:get() {
    git clone -b $1 --single-branch --depth 1 https://github.com/filamentphp/filament.git "filament-src-$1"
}

function concatenate:packages {
    src_path="filament-src-$1"
    target_path="filament-$1"
    
    rm -rf $target_path
    
    mkdir -p $target_path
    
    # Iterate through each directory in filament-docs
    for package_dir in "$src_path"/packages/*/; do
        # Extract package name from path
        package_name=$(basename "$package_dir")
        
        # Define the output file path
        output_file="$target_path/${package_name}.md"
        
        # Check if the docs directory exists
        if [ -d "${package_dir}docs" ]; then
            # Create a temporary file for content
            temp_file=$(mktemp)
            
            # Find all markdown files in docs directory, sorted by name
            find "${package_dir}docs" -type f -name "*.md" 2>/dev/null | sort | while read -r file; do
                # Get the relative path from the package/docs directory
                rel_path=$(echo "$file" | sed "s|${package_dir}docs/||g")
                
                # Write file header to temp file
                echo "# Documentation for ${package_name}. File: $rel_path" >> "$temp_file"
                
                # Write file content
                cat "$file" >> "$temp_file"
                
                # Add a newline for separation
                echo "" >> "$temp_file"
            done
            
            # Check if any content was written to the temp file
            if [ -s "$temp_file" ]; then
                # Copy temp file to output
                cp "$temp_file" "$output_file"
                echo "Created $output_file"
            else
                echo "No content found for ${package_name}, skipping file creation"
            fi
            
            # Remove temp file
            rm "$temp_file"
        else
            echo "No docs directory found for ${package_name}, skipping file creation"
        fi
    done
}

function concatenate:all {
    version="$1"
    target_path="filament-${version}"
    docs_dir="docs-for-ai"
    
    # Create docs-for-ai directory if it doesn't exist
    mkdir -p "$docs_dir"
    
    all_output="${docs_dir}/filament-${version}-all.md"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Add a header
    echo "# Filament ${version} Documentation" > "$temp_file"
    echo "Generated on $(date)" >> "$temp_file"
    echo "" >> "$temp_file"
    
    # Find all non-empty markdown files in the target directory
    find "$target_path" -type f -name "*.md" -not -empty | sort | while read -r file; do
        # Extract file name without extension
        filename=$(basename "$file" .md)
        
        # Add file content
        cat "$file" >> "$temp_file"
        
        # Add section separator
        echo "" >> "$temp_file"
        echo "---" >> "$temp_file"
        echo "" >> "$temp_file"
    done
    
    # Check if any content was added beyond the header
    if [ $(wc -l < "$temp_file") -gt 3 ]; then
        # Copy temp file to output
        cp "$temp_file" "$all_output"
        echo "Created $all_output with all documentation"
    else
        echo "No content found to create combined documentation file"
    fi
    
    # Remove temp file
    rm "$temp_file"
}

function zip:package-docs {
    version="$1"
    target_path="filament-${version}"
    docs_dir="docs-for-ai"
    
    # Create docs-for-ai directory if it doesn't exist
    mkdir -p "$docs_dir"
    
    zip_file="${docs_dir}/${target_path}-packages-$1.zip"
    
    # Check if the target directory exists
    if [ -d "$target_path" ]; then
        # Create zip file of the directory
        zip -r "$zip_file" "$target_path"
        echo "Created $zip_file"
    else
        echo "Error: Directory $target_path does not exist"
    fi
}

function llm:3.x() {
    rm -rf filament-src-3.x
    docs:get 3.x
    concatenate:packages 3.x
    concatenate:all 3.x
    zip:package-docs 3.x
}