# Unix_PDF_Finder

A bash script to search for a keyword in PDF files in the folders specified in the configuration file.

## **Usage**

```bash
./pdf_finder.sh [OPTIONS] [KEYWORD]
```

## **Options**

-   `-help` : Display the help message.
-   `-addDir [FOLDER]` : Add a directory to the configuration file.
-   `-removeDir [FOLDER]` : Remove a directory from the configuration file.
-   `-listDir` : List the directories in the configuration file.
-   `-resetConfig` : Reset the configuration file.
-   `-resetHistory` : Reset the history file.
-   `-history` : Display the history file.

## **Configuration file**

The script reads the configuration file from **~/.config/pdf_search/config.tx**t. If the file does not exist, the script will create it.

The configuration file contains the list of directories to search in. Each directory must be on a separate line.

## **History file**

The script store the history of the search in the file **~/.config/pdf_search/history.txt**. If the file does not exist, the script will create it.

## **Examples**

Add a directory to the configuration file:

```bash
./pdf_finder.sh -addDir /path/to/directory
```

Remove a directory from the configuration file:

```bash
./pdf_finder.sh -removeDir /path/to/directory
```

List the directories in the configuration file:

```bash
./pdf_finder.sh -listDir
```

Reset the configuration file:

```bash
./pdf_finder.sh -resetConfig
```

Reset the history file:

```bash
./pdf_finder.sh -resetHistory
```

Display the history file:

```bash
./pdf_finder.sh -history
```

## **Dependencies**

- `rofi` : Used to display the results.
- `ripgrep` : Used to search for the keyword in the PDF files.

To install the dependencies on Ubuntu:

```bash
sudo apt install rofi
sudo apt install ripgrep
```

> **Note:** The script will check if the dependencies are installed. If not, the script will display an error message and exit.

## **Installation**

To install the script, clone the repository and copy the script to a directory in your PATH.
