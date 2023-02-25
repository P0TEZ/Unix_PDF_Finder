#!/bin/bash

# Configuration file path
config_file="$HOME/.config/pdf_search/config.txt"
# History file path
history_file="$HOME/.config/pdf_search/history.txt"

# Check if configuration file exists
if [ -f "$config_file" ]; then
    echo "Configuration file found."
else
    echo "Configuration file not found. Exiting script."
    echo "Configuration file not found. Exiting script." >> error.log
    exit 1
fi

# Check if history file exists
if [ -f "$history_file" ]; then
    echo "History file found."
else
    #if not we create it
    echo "History file not found. Creating it."
    echo "History file not found. Creating it." >> error.log
    mkdir -p "$HOME/.config/pdf_search"
    touch "$history_file"
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
#keyword=$(rofi -dmenu -p "Enter keyword:")
# Get history of previous searches
history=$(cat "$history_file")

# Rofi prompt to ask for keyword
keyword=$(echo -e "$history" | rofi -dmenu -p "Enter keyword or select a previous search:")

if [ -n "$keyword" ]; then
    # Add the keyword to the history file if it's not already there
    if ! grep -q "$keyword" "$history_file"; then
        echo "$keyword" >> "$history_file"
    fi

    # Search keyword in PDF files and dump the results in a text file
    search_pdfs "$keyword"

    # Get options from text file
    options=$(cat "$results_file")

    # Prompt user to select an option using Rofi
    #if options is empty, we display a message
    if [ -z "$options" ]; then
        options="No results found."
    fi
    selected_option=$(echo "$options" | rofi -dmenu -p "Select a pdf to open:")

    # Print the selected option to the terminal (for debugging)
    #echo "Selected option: $selected_option"

    #if the selected option is not empty and not equal to "No results found.", we open the pdf file
    if [ -n "$selected_option" ] && [ "$selected_option" != "No results found." ]; then
        #If the file is not found, we display an error message
        if [ ! -f "$selected_option" ]; then
            echo "File not found. Exiting script."
            echo "File not found. Exiting script." >> error.log
            exit 1
        fi
        xdg-open "$selected_option"
    fi
fi