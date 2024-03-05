#! /bin/bash

usage() {
    echo "Usage: $0 [-h] [-p <string>] -d <string> <string>...

    where:
    -h Show this help text
    -p Set path additional to default path
    -d Set directory the commands will be executed (mandatory)
    List of commands to be executed

    Note: if the directory contains spaces, either escape the spaces or surround the directory with quotes.

    Example:
    To show home directory content, use
    $0 -d ~ \"ls -l\"
    "
    exit 1;
}

printCommand() {

    echo '$ '$@

# The use of tput triggers errors in NSTask. Disabling for now.
#    local array
#    local i
#    array=("$@")
#
#    printf '\n%s%s' $bold '$ '
#    for i in "${array[@]}" ; do
#        printf '%s ' "$i"
#    done
#    printf '%s\n' $colorReset
}

dflag=false                  # d argument is not set
verbose=0                #
#colorReset="$(tput sgr0)"   # reset
#colorRed="$(tput setaf 1)"  # red
#bold="$(tput bold)"         # bold

while getopts ":p:d:vh" opt; do
    case "$opt" in
        p) p=$OPTARG ;; # Optional path
        d) dflag=true; d=$OPTARG ;; # Project Directory. Mandatory
        v) verbose=1 ;; # if true disables printCommand
        h|*) usage ;;   # help
    esac
done
shift $(( OPTIND - 1 ))

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# 1. Exit when mandatory directory argument is not present
if ! $dflag
then
    printf '%s%s%s\n' $colorRed 'Error:'$colorReset' -d argument missing'
    usage
fi

# 2. Set path if $p is set
if [ -n "$p" ]; then
    export PATH=$PATH:$p
fi
#echo "PATH="$PATH

# 3. cd to directory
((verbose)) && printCommand 'cd '$d
cd "${d}" || exit 1

# 4. Execute the commands
for command in "$@"; do
    ((verbose)) && printCommand $command
    $command || exit 1
done

((verbose)) && printf '\nReady.\n'
