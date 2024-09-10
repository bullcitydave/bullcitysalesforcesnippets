# Author: Dave Seidman | @github.com/bullcitydave 
# Significant assistance provided by: Claude 3.5 Sonnet
#
# This script generates a report of Salesforce metadata changes over a specified number of days.
# It determines the metadata type based on the file path and logs the changes to an output file.
#
# Usage: ./gitmdtreport.sh <number_of_days>
# Example: ./gitmdtreport.sh 7  # This will generate a report of changes over the past 7 days.
#
# The output file will be named "salesforce_metadata_changes_<number_of_days>days.log".
# For example, if you run "./gitmdtreport.sh 7", the output file will be "salesforce_metadata_changes_7days.log".
#
# The script recognizes the following Salesforce metadata types based on the file path:
# - CustomObject
# - ApexClass
# - ApexTrigger
# - ApexPage
# - ApexComponent
# - StaticResource
# - Layout
# - Workflow
# - Profile
# - PermissionSet
# - Report
# - Dashboard
# - EmailTemplate
# - Flow
# - CustomApplication

#!/bin/bash

# Check if a parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <number_of_days>"
    echo "Example: $0 7 (to look back 7 days)"
    exit 1
fi

# Get the number of days from the parameter
DAYS=$1

# Set the output file name
OUTPUT_FILE="salesforce_metadata_changes_${DAYS}days.log"

# Function to determine Salesforce metadata type based on file path
get_metadata_type() {
    local file_path=$1
    case $file_path in
        *"/objects/"*) echo "CustomObject" ;;
        *"/classes/"*) echo "ApexClass" ;;
        *"/triggers/"*) echo "ApexTrigger" ;;
        *"/pages/"*) echo "ApexPage" ;;
        *"/components/"*) echo "ApexComponent" ;;
        *"/staticresources/"*) echo "StaticResource" ;;
        *"/layouts/"*) echo "Layout" ;;
        *"/workflows/"*) echo "Workflow" ;;
        *"/profiles/"*) echo "Profile" ;;
        *"/permissionsets/"*) echo "PermissionSet" ;;
        *"/reports/"*) echo "Report" ;;
        *"/dashboards/"*) echo "Dashboard" ;;
        *"/email/"*) echo "EmailTemplate" ;;
        *"/flows/"*) echo "Flow" ;;
        *"/applications/"*) echo "CustomApplication" ;;
        *"/tabs/"*) echo "CustomTab" ;;
        *"/labels/"*) echo "CustomLabels" ;;
        *"/aura/"*) echo "AuraDefinitionBundle" ;;
        *"/lwc/"*) echo "LightningComponentBundle" ;;
        *) echo "Other" ;;
    esac
}

# Get all files that have been created or modified within the specified number of days
git log --name-status --pretty=format: --since="${DAYS} days ago" | grep -E '^[AM]' | awk '{print $2}' | sort | uniq > all_changes.txt

# Process each file and group by metadata type
{
    echo "Salesforce Metadata Changes in the Last ${DAYS} Days"
    echo "=================================================="
    echo ""
    
    while IFS= read -r file; do
        metadata_type=$(get_metadata_type "$file")
        echo "$metadata_type: $file"
    done < all_changes.txt | sort | awk -F': ' '{
        if ($1 in types) {
            types[$1] = types[$1] "\n    " $2
        } else {
            types[$1] = $2
        }
    }
    END {
        for (type in types) {
            print type ":"
            print types[type]
            print ""
        }
    }'
} > "$OUTPUT_FILE"

# Clean up temporary file
rm all_changes.txt

echo "Metadata changes have been written to $OUTPUT_FILE"