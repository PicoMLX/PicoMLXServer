#!/bin/sh

#echo '$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

# Second argument found, set $HOME path
# required by brew
HOME=${1}
export HOME

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
