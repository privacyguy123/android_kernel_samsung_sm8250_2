# Automatically resolve conflicts by combining both changes:
git diff --name-only --diff-filter=U | while read -r file; do
    git checkout --ours "$file"
    git checkout --theirs "$file"
    git add "$file"
done

# Finalize the merge or rebase:
git commit -m "Resolved conflicts by combining changes"
