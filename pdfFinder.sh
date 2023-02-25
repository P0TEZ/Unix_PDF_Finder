#!/bin/bash

# Configuration file path
config_file="$HOME/.config/pdf_search/config.txt"

# Check if configuration file exists
if [ -f "$config_file" ]; then
    echo "Configuration file found."
else
    echo "Configuration file not found. Exiting script."
    exit 1
fi

#display the content of the configuration file
echo "Configuration file content:"
cat "$config_file"

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

echo "Searching for PDF files..."
pdf_files=$(get_pdf_files)
echo "PDF files found: $pdf_files"

# Function to search keyword in PDF files and dump the results in a text file
search_pdfs() {
    keyword="$1"
    results_file="results.txt"
    pdf_files=$(get_pdf_files)
    for pdf_file in "${pdf_files[@]}"; do
        if pdfgrep -iH "$keyword" "$pdf_file" >> "$results_file"; then
            : # do nothing
        else
            echo "Error searching in $pdf_file" >> error.log
        fi
    done
}

# Rofi prompt to ask for keyword
keyword=$(rofi -dmenu -p "Enter keyword:")

# Search keyword in PDF files and dump the results in a text file
search_pdfs "$keyword"

# Rofi prompt to present the results
result=$(rofi -dmenu -p "Results:" -file "$results_file")

# Open the selected PDF
if [ -n "$result" ]; then
    xdg-open "$result"
fi
