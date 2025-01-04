# Loop through all conflicting files and accept both changes
git diff --name-only --diff-filter=U | while read -r file; do
    echo "Resolving conflict for $file..."
    # Combine both changes
    sed -e '/^<<<<<<< /d' -e '/^=======/d' -e '/^>>>>>>> /d' -e 's/^<<<<<<< HEAD//' "$file" > "${file}.resolved"
    mv "${file}.resolved" "$file"
    git add "$file"
done

# Finalize the merge
git commit -m "Resolved all conflicts by accepting both changes"
