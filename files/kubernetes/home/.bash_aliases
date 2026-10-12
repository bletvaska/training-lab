# syntax highlighting for less and cat
alias cat='batcat --style=plain --paging=never'
alias less='batcat --style=plain --paging=always'

# for kubernetes
alias kubectl='kubecolor --force-colors=true'
alias k='kubectl'
complete -o default -F __start_kubectl k

