#!/bin/bash

# ai generated lol

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <obj1> <obj2> <out_obj>"
    exit 1
fi

# Assign input and output files from arguments
obj1="$1"
obj2="$2"
out_obj="$3"

# Count the number of vertex lines in obj1
num_vertices=$(grep -c '^v ' "$obj1")

# Adjust the vertex indices in obj2 and merge with obj1
{
    # Print the contents of the first OBJ file
    cat "$obj1"
    
    # Insert a comment to indicate the separation
    echo "# Merging $obj2"
    
    # Print the group and smoothing group lines from the second OBJ file
    # grep -E '^g |^s ' "$obj2"
    
    # Adjust the indices in the second OBJ file
    awk -v offset="$num_vertices" '
    /^v / { print }  # Print vertex lines unmodified
    /^f / {          # Adjust face indices
        for (i = 2; i <= NF; i++) {
            split($i, indices, "/")
            indices[1] = indices[1] + offset
            $i = indices[1]
            if (length(indices) > 1) {
                for (j = 2; j <= length(indices); j++) {
                    $i = $i "/" indices[j]
                }
            }
        }
        print
    }
    !/^v / && !/^f / { print } # Print other lines unmodified
    ' "$obj2"
} > "$out_obj"

echo "Merged $obj1 and $obj2 into $out_obj"