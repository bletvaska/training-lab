# syntax highlighting for less and cat
alias cat='batcat --style=plain --paging=never'
alias less='batcat --style=plain --paging=always'

# lazy docker
# https://github.com/jesseduffield/lazydocker
alias lazydocker='docker container run --rm -it \
        --name lazydocker \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        lazyteam/lazydocker'

# dive
# https://github.com/wagoodman/dive
#alias dive="docker container run -it --rm \
#        --name dive \
#        --volume /var/run/docker.sock:/var/run/docker.sock \
#        wagoodman/dive"

# dry
# https://moncho.github.io/dry/
#alias dry="docker container run --rm -it \
#        --name dry \
#        --volume /var/run/docker.sock:/var/run/docker.sock \
#        moncho/dry"

