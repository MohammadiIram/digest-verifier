#!/bin/bash

REPO_URL="https://github.com/red-hat-data-services/kserve.git"
FILE_PATH="kserve/config/overlays/odh/params.env"
function clone_repo() {
  local BRANCH_NAME=$1
  git clone --depth 1 -b "$BRANCH_NAME" "https://github.com/red-hat-data-services/kserve.git" "kserve"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to access $repo"
    return 1
  fi
}
function get_latest_rhods_version() {
  local rhods_version
  rhods_version=$(git ls-remote --heads https://github.com/red-hat-data-services/rhods-operator | grep 'rhoai' | awk -F'/' '{print $NF}' | sort -V | tail -1)
  echo "$rhods_version"
}
extract_names_with_sbom_extension() {
 local tag="$1"
 local hash="$2"
    json_response=$(curl -s https://quay.io/api/v1/repository/modh/$tag/tag/ | jq -r '.tags | .[:3] | map(select(.name | endswith(".sbom"))) | .[].name')
   # echo "$json_response"
    local names_part=$(echo "$json_response" | sed 's/^sha256-\(.*\)\.sbom$/\1/')
    echo "$names_part"
    if [ "$hash" = "$names_part" ]; then
        # Print in green if equal
        echo "$tag"
        echo -e "\e[32m$hash\e[0m matches \e[32m$names_part\e[0m"
    else
        # Print in red if not equal
        echo "$tag"
        echo -e "\e[31m$hash\e[0m does not match \e[31m$names_part\e[0m"
        exit 1
    fi
}
main(){
    rhods_version=$(get_latest_rhods_version)
    echo "$rhods_version"
    # call function for clone
    clone_repo $rhods_version
    # read from file and store the contetnt in input varial
    if [ -f "$FILE_PATH" ]; then
    echo "File found: $FILE_PATH"
    local input=$(<"$FILE_PATH")
    # Extract names before '=' using cut
    local names=$(echo "$input" | cut -d'=' -f1)
    #echo "$names"
     # for name in $names; do
     #   echo "$name"
        # Perform your operation here
    #    extract_names_with_sbom_extension $name
     # done
 # Loop through each line of input
    while IFS= read -r line; do
        # Extract the name before '='
        local name=$(echo "$line" | cut -d'=' -f1)
        # Extract the text after 'sha256:'
        local hash=$(echo "$line" | awk -F 'sha256:' '{print $2}')
        extract_names_with_sbom_extension $name $hash
       # echo "Name: $name"
       # echo "Hash: $hash"
    done <<< "$input"
    rm -rf kserve
    else
    echo "File not found: $FILE_PATH"
    fi
}
main
