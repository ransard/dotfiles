git-cleanup() {
    # Fetch and prune remote references
    git fetch -p
    
    # Find and delete branches whose remotes are gone
    local branches=($(git branch -vv | grep ': gone]' | awk '{print $1}'))
    
    if [ ${#branches[@]} -eq 0 ]; then
        echo "No stale branches found."
        return 0
    fi
    
    echo "The following branches will be deleted:"
    printf '%s\n' "${branches[@]}"
    
    echo "\nProceed with deletion? (y/N)"
    read -q response || return 1
    echo
    
    for branch in "${branches[@]}"; do
        git branch -D "$branch"
    done
}

alias gclean='git-cleanup'

