function stashcheck(){
    while IFS= read -r -d '' Git; do
        mapfile -t Stash < <(GIT_DIR=$Git git stash list)

        if (( ${#Stash[@]} > 0 )); then
            realpath "$Git/.."
        fi
        for StashLine in "${Stash[@]}"; do
            printf "\t%s\n" "$StashLine"
        done
    done < <(find "$HOME/go/src" "$HOME/git" -type d -name ".git" -print0)
}
