#!/bin/bash

# This script generates the project documentation and fails if issues are detected in the output
if ! output=$(swift package generate-documentation 2> /dev/null); then
   echo "Documentation generation failed."
   exit 1
fi

if echo "$output" | grep -E 'warning|error'; then
    echo "Issues were found when generating the documentation."
    exit 1
else
   echo "The documentation was generated successfully."
   exit 0
fi
