#!/bin/bash

# Function to get the repository language
get_repo_language() {
    local repo_url="$1"
    local token="<YOUR_GITHUB_TOKEN>"  # Replace <YOUR_GITHUB_TOKEN> with your actual GitHub token
    local api_url="https://api.github.com/repos/${repo_url#github.com/}/languages"

    # Make the API request
    local response=$(curl -sSL -w "%{http_code}" -H "Authorization: token $token" "$api_url")
    local http_code="${response##*$'\n'}"

    # Check if the response code is in the 2xx range
    if [[ "$http_code" =~ ^2 ]]; then
        # Extract languages using sed
        local languages=$(echo "$response" | sed -n 's/^[[:space:]]*"\(.*\)".*$/\1/p' | tr -d '{}"' | tr ',' '\n')
        echo "${languages//[$'\n']/,}"  # Convert newline-separated languages to comma-separated
    else
        echo "Failed to fetch languages for repository: $repo_url (HTTP $http_code)"
        exit 1
    fi
}

# Function to extract Twitter profiles from README.md
get_twitter_profiles() {
    local readme_file="$1"
    grep -oE '(http|https)://twitter\.com/[a-zA-Z0-9_]{1,15}' "$readme_file" | sort -u | tr '\n' ',' | sed 's/,$//'
}

# Excluded repository
excluded_repo="github.com/zanfranceschi/rinha-de-backend-2024-q1"

# Assuming the folder containing subfolders is named "main_folder"
main_folder="./participantes"

# Create CSV file and add headers
echo "Folder,Repository,Languages,Twitter Profiles" > lista-repos-github.csv

# Loop through each subfolder in the main folder
for folder in "$main_folder"/*; do
    if [ -d "$folder" ]; then  # Check if it's a directory
        readme_file="$folder/README.md"
        if [ -f "$readme_file" ]; then  # Check if README.md exists
            # Use grep to extract GitHub links, exclude the specified repository
            grep -o 'github\.com\/[a-zA-Z0-9._-]\+\/[a-zA-Z0-9._-]\+' "$readme_file" | awk -F/ '!seen[$0]++ {print $1"/"$2"/"$3}' | grep -v "$excluded_repo" | while read -r repo_url; do
                # Get languages for the repository
                languages=$(get_repo_language "$repo_url")
                # Get Twitter profiles from README.md
                twitter_profiles=$(get_twitter_profiles "$readme_file")
                # Append to CSV file
                echo "\"$folder\",\"$repo_url\",\"$languages\",\"$twitter_profiles\"" >> lista-repos-github.csv
            done
        else
            echo "README.md not found in $folder"
        fi
    fi
done