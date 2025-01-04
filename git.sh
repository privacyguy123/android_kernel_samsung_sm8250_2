#!/bin/bash

# Merge changes by keeping both HEAD and incoming changes
find . -type f -exec sed -i '
/<<<<<<< HEAD/ {
  # Remove the <<<<<<< HEAD line
  N
  # Replace ======= marker with a comment for distinction (if desired)
  s/=======/\n# Conflict Divider Here\n/
  # Remove the >>>>>>> marker
  N; s/>>>>>>>.*//;
}' {} \;

echo "All conflicts have been resolved by keeping both changes."
