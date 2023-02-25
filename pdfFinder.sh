#!/bin/bash

# Configuration file path
config_file="$HOME/.config/pdf_search/config.txt"

# Check if configuration file exists
if [ -f "$config_file" ]; then
    #echo "Configuration file found."
else
    echo "Configuration file not found. Exiting script."
    exit 1
fi

#display the content of the configuration file (for debugging)
#echo "Configuration file content:"
#cat "$config_file"

# Function to get list of PDF files from the folders specified in the config file
get_pdf_files() {
    pdf_files=()
    while read folder; do
        if [ -d "$folder" ]; then
            while IFS= read -r -d '' file; do
                if [ "${file##*.}" = "pdf" ]; then
                    pdf_files+=("$file")
                fi
            done < <(find "$folder" -name "*.pdf" -print0)
        fi
    done < "$config_file"
    echo "${pdf_files[@]}"
}

# Get list of PDF files from the folders specified in the config file (for debugging)
#echo "Searching for PDF files..."
#pdf_files=$(get_pdf_files)
#echo "PDF files found: $pdf_files"

# Function to search keyword in PDF files and dump the results in a text file
search_pdfs() {
    keyword="$1"
    results_file="results.txt"
    # emply the current results file
    > "$results_file"

    # Search keyword in PDF files
    pdf_files=$(get_pdf_files)
    rg -zli "$keyword" ${pdf_files[@]} >> "$results_file" 2>> error.log
}

# Rofi prompt to ask for keyword
keyword=$(rofi -dmenu -p "Enter keyword:")

# Search keyword in PDF files and dump the results in a text file
search_pdfs "$keyword"

# Get options from text file
options=$(cat "$results_file")

# Prompt user to select an option using Rofi
selected_option=$(echo "$options" | rofi -dmenu -p "Select a pdf to open:")

# Print the selected option to the terminal (for debugging)
#echo "Selected option: $selected_option"

if [ -n "$selected_option" ]; then
    xdg-open "$selected_option"
fi