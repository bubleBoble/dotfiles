#!/bin/bash

# Get the absolute path of the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/symlinks.conf"

# Check if configuration file with symlinks definitions exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

create_symlinks() {
    echo "Creating symbolic links"

    # Read dotfile links from the CONFIG_FILE
    while IFS=: read -r source target || [ -n "$source" ]; do

        # Skip empty or invalid lines in the config file
        if [[ -z "$source" || -z "$target" || "$source" == \#* ]]; then
            continue
        fi

        # Evaluate variables
        source=$(eval echo "$source")
        target=$(eval echo "$target")

        # Check if the source file exists
        if [ ! -e "$source" ]; then
            echo "Error: Source file '$source' not found. Skipping link creation for '$target'."
            continue
        fi

        # Check if the symbolic link already exists
        if [ -L "$target" ]; then
            echo "Symbolic link already exists: $target"
        elif [ -f "$target" ]; then
            echo "File already exists: $target"
        else
            # Extract the directory portion of the target path
            target_dir=$(dirname "$target")

            # Check if the target directory exists, and if not, create it
            if [ ! -d "$target_dir" ]; then
                mkdir -p "$target_dir"
                echo "Created directory: $target_dir"
            fi

            # Create the symbolic link
            ln -s "$source" "$target"
            echo "Created symbolic link: $target"
        fi
    done <"$CONFIG_FILE"
}

delete_symlinks() {
    echo "Deleting symbolic links..."

    while IFS=: read -r _ target || [ -n "$target" ]; do

        # Skip empty and invalid lines
        if [[ -z "$target" ]]; then
            continue
        fi

        # Evaluate variables
        target=$(eval echo "$target")

        # Check if the symbolic link or file exists
        if [ -L "$target" ] || { [ "$include_files" == true ] && [ -f "$target" ]; }; then
            # Remove the symbolic link or file
            rm -rf "$target"
            echo "Deleted: $target"
        else
            echo "Not found: $target"
        fi
    done <"$CONFIG_FILE"
}

# Parse arguments
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    case "$1" in
    "--create")
        create_symlinks
        ;;
    "--delete")
        if [ "$2" == "--include-files" ]; then
            include_files=true
        fi
        delete_symlinks
        ;;
    "--help")
        # Display usage/help message
        echo "Usage: $0 [--create | --delete [--include-files] | --help]"
        ;;
    *)
        # Display an error message for unknown arguments
        echo "Error: Unknown argument '$1'"
        echo "Usage: $0 [--create | --delete [--include-files] | --help]"
        exit 1
        ;;
    esac
fi
