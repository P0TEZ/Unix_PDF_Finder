#!/bin/bash

# Configuration file path
config_file="$HOME/.config/pdf_search/config.txt"
# History file path
history_file="$HOME/.config/pdf_search/history.txt"

# Check if configuration file exists
if [ -f "$config_file" ]; then
    echo "Configuration file found."
else
    echo "Configuration file not found. Creating it."
    echo "Configuration file not found. Creating it." >> error.log
    mkdir -p "$HOME/.config/pdf_search"
    touch "$config_file"
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

#check if nofi and ripgrep are installed
if ! command -v nofi &> /dev/null
then
    echo "nofi could not be found. Please install it."
    echo "nofi could not be found. Please install it." >> error.log
    exit 1
fi

if ! command -v rg &> /dev/null
then
    echo "ripgrep could not be found. Please install it."
    echo "ripgrep could not be found. Please install it." >> error.log
    exit 1
fi

#if the the parameter "-resetConfig" is passed, we reset the configuration file
if [ "$1" = "-resetConfig" ]; then
    echo "Resetting configuration file."
    echo "Resetting configuration file." >> error.log
    > "$config_file"
    exit 0
fi

#if the the parameter "-resetHistory" is passed, we reset the history file
if [ "$1" = "-resetHistory" ]; then
    echo "Resetting history file."
    echo "Resetting history file." >> error.log
    > "$history_file"
    exit 0
fi

#if the parameter "-history" is passed, we display the content of the history file
if [ "$1" = "-history" ]; then
    echo "Displaying history file content."
    echo "Displaying history file content." >> error.log
    cat "$history_file"
    exit 0
fi

#if the parameter "-addDir" is passed, we add the folder to the configuration file
if [ "$1" = "-addDir" ]; then
    #if the parameter "-addDir" is passed, we check if the second parameter is not empty
    if [ -n "$2" ]; then
        #if the second parameter is not empty, we check if the folder exists
        if [ -d "$2" ]; then
            #if the folder exists, we add it to the configuration file
            echo "Adding folder $2 to the configuration file."
            echo "Adding folder $2 to the configuration file." >> error.log
            echo "$2" >> "$config_file"
            exit 0
        else
            #if the folder does not exist, we display an error message
            echo "Folder $2 does not exist. Exiting script."
            echo "Folder $2 does not exist. Exiting script." >> error.log
            exit 1
        fi
    else
        #if the second parameter is empty, we display an error message
        echo "No folder specified. Exiting script."
        echo "No folder specified. Exiting script." >> error.log
        exit 1
    fi
fi

#if the parameter "-removeDir" is passed, we remove the folder from the configuration file
if [ "$1" = "-removeDir" ]; then
    #if the parameter "-removeDir" is passed, we check if the second parameter is not empty
    if [ -n "$2" ]; then
        #if the second parameter is not empty, we check if the folder exists
        if [ -d "$2" ]; then
            #if the folder exists, we remove it from the configuration file
            echo "Removing folder $2 from the configuration file."
            echo "Removing folder $2 from the configuration file." >> error.log

            #escape every / with a \ to avoid sed errors
            toRemove=$(echo "$2" | sed 's/\//\\\//g') 2>> error.log

            #remove the folder from the configuration file only if the line starts with the folder name and ends with \n 
            sed -i "/^$toRemove\$/d" "$config_file" 2>> error.log


            exit 0
        else
            #if the folder does not exist, we display an error message
            echo "Folder $2 does not exist. Exiting script."
            echo "Folder $2 does not exist. Exiting script." >> error.log
            exit 1
        fi
    else
        #if the second parameter is empty, we display an error message
        echo "No folder specified. Exiting script."
        echo "No folder specified. Exiting script." >> error.log
        exit 1
    fi
fi

#if the parameter "-listDir" is passed, we display the content of the configuration file
if [ "$1" = "-listDir" ]; then
    echo "Displaying configuration file content."
    echo "Displaying configuration file content." >> error.log
    cat "$config_file"
    exit 0
fi

#if the parameter "-help" is passed, we display the help message
if [ "$1" = "-help" ]; then
    echo "Usage: pdfFinder.sh [OPTION] [FOLDER]"
    echo "Search for a keyword in PDF files in the folders specified in the configuration file."
    echo ""
    echo "Options:"
    echo "  -addDir [FOLDER]      Add a folder to the configuration file."
    echo "  -removeDir [FOLDER]   Remove a folder from the configuration file."
    echo "  -listDir              Display the content of the configuration file."
    echo "  -resetConfig          Reset the configuration file."
    echo "  -resetHistory         Reset the history file."
    echo "  -history              Display the content of the history file."
    echo "  -help                 Display this help message."
    echo ""
    echo "Examples:"
    echo "  pdfFinder.sh -addDir /home/user/Documents"
    echo "  pdfFinder.sh -removeDir /home/user/Documents"
    echo "  pdfFinder.sh -resetConfig"
    echo "  pdfFinder.sh -resetHistory"
    echo "  pdfFinder.sh -history"
    echo "  pdfFinder.sh -help"
    echo ""
    echo "Code by P0THESE"
    exit 0
fi

#The main script part start here ----------------------------------------------

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