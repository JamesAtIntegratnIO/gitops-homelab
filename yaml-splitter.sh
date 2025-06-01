#!/usr/bin/env bash

# This script takes a single Kubernetes YAML file as input, which may contain multiple
# documents separated by '---'. It splits the file into individual documents, renames
# each document file based on the 'metadata.name' field found within, and then, if a
# 'kustomization.yaml' file exists in the same directory, updates that file to include
# the new files as resources.
#
# Usage:
# ./split_and_update_kustomization.sh <path-to-your-yaml-file>
#
# Requirements:
# - The 'yq' command-line tool (version 3.x), a lightweight and portable command-line YAML processor.
# - The 'jq' command-line tool, a lightweight and flexible command-line JSON processor.
#
# The script performs the following steps:
# 1. Validates that a file path is provided as an argument.
# 2. Checks if 'yq' and 'jq' are installed.
# 3. Splits the input file into separate files for each YAML document.
# 4. For each document, extracts the 'metadata.name' field to use as the file name.
#    If 'metadata.name' is not present, a default name is used.
# 5. If a 'kustomization.yaml' file exists in the same directory as the input file,
#    the script updates this file to include the new files as resources, ensuring no duplicates.
#
# Note:
# - The script is designed to work with 'yq' version 3.x. Syntax may need adjustment for other versions.
# - This script does not handle complex scenarios such as merging with existing resources in 'kustomization.yaml'.

# Ensure a file name is provided as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <yaml-file>"
  exit 1
fi

# Check if yq and jq are installed
if ! command -v yq &> /dev/null || ! command -v jq &> /dev/null; then
    echo "This script requires both yq and jq. Please install them."
    exit 1
fi

FILENAME="$1"
DIRNAME=$(dirname "$FILENAME")
COUNTER=1

# Array to hold all the new resource names
declare -a NEW_RESOURCES=()

# Split the file by the '---' delimiter
# and process each chunk
csplit --quiet --prefix="${DIRNAME}/split_" --suffix-format="%04d.yaml" "$FILENAME" /---/ "{*}"

for file in "${DIRNAME}"/split_*.yaml
do
  if [ -s "$file" ]; then
    # Use yq to transpose YAML to JSON, then jq to extract 'metadata.name'
    NAME=$(yq -r '.' "$file" | jq -r '.metadata.name // empty')
    KIND=$(yq -r '.' "$file" | jq -r '.kind // empty')

    # If 'metadata.name' is empty, use a default name
    if [ -z "$NAME" ]; then
      NAME="unnamed-${COUNTER}"
      COUNTER=$((COUNTER+1))
    fi

    # Form the new file path
    NEW_FILE_PATH="${DIRNAME}/${NAME}-${KIND}.yaml"

    # Rename the file using 'metadata.name'
    mv "$file" "$NEW_FILE_PATH"

    # Add the new file name to the array of resources
    NEW_RESOURCES+=("$NEW_FILE_PATH")
  else
    # Remove empty files
    rm "$file"
  fi
done

# Function to add resources to kustomization.yaml
add_resources_to_kustomization() {
    local kustomization_file=$1
    shift
    local resources=("$@")

    # Check if 'resources:' exists in the kustomization.yaml file
    if yq eval '.resources' "$kustomization_file" >/dev/null 2>&1; then
      # Append the new resources under 'resources:'
      yq eval --inplace '.resources += [$(printf '%s\n' "${resources[@]}")] | .resources' "$kustomization_file"
    else
      # Add 'resources:' and append the new resources
      yq eval --inplace '.resources = [$(printf '%s\n' "${resources[@]}")]' "$kustomization_file"
    fi
}

# Check if kustomization.yaml exists and update it
KUSTOMIZATION_FILE="${DIRNAME}/kustomization.yaml"
if [ -f "$KUSTOMIZATION_FILE" ]; then
    echo "Updating $KUSTOMIZATION_FILE with new resources..."
    add_resources_to_kustomization "$KUSTOMIZATION_FILE" "${NEW_RESOURCES[@]}"
else
    echo "kustomization.yaml does not exist. No updates made to it."
fi

echo "Splitting and updating complete."
