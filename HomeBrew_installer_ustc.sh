#!/bin/bash

consoleuser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
UNAME_MACHINE="$(uname -m)"


# Logging stuff starts here
LOGFOLDER="/private/var/log/"
LOG="${LOGFOLDER}Homebrew.log"

if [ ! -d "$LOGFOLDER" ]; then
    mkdir $LOGFOLDER
fi

# Set the prefix based on the machine type
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    # M1/arm64 machines
    HOMEBREW_PREFIX="/opt/homebrew"
else
    # Intel machines
    HOMEBREW_PREFIX="/usr/local"
fi

# are we in the right group
check_grp=$(groups ${consoleuser} | grep -c '_developer')

if [[ $check_grp != 1 ]]; then
    /usr/sbin/dseditgroup -o edit -a "${consoleuser}" -t user _developer
fi

function logme()
{
# Check to see if function has been called correctly
    if [ -z "$1" ] ; then
        echo "$(date) - logme function call error: no text passed to function! Please recheck code!" | tee -a $LOG
        exit 1
    fi

# Log the passed details
    echo -e "$(date) - $1" | tee -a $LOG
}

# set shellenv for M1 users
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/${consoleuser}/.profile
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/${consoleuser}/.zprofile
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/${consoleuser}/.bash_profile
fi
eval $(/opt/homebrew/bin/brew shellenv)

# logme user that all is completed
logme "Installation complete"

export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
brew update
brew tap --custom-remote --force-auto-update homebrew/core https://mirrors.ustc.edu.cn/homebrew-core.git
# 对于 bash 用户
echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"' >> ~/.bash_profile
echo 'export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"' >> ~/.bash_profile
echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"' >> ~/.bash_profile
echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"' >> ~/.bash_profile

# 对于 zsh 用户
echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"' >> ~/.zshrc
echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"' >> ~/.zshrc
echo 'export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"' >> ~/.zshrc
echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"' >> ~/.zshrc

brew tap --custom-remote --force-auto-update homebrew/cask https://mirrors.ustc.edu.cn/homebrew-cask.git
brew tap --custom-remote --force-auto-update homebrew/cask-versions https://mirrors.ustc.edu.cn/homebrew-cask-versions.git
brew tap --custom-remote --force-auto-update homebrew/services https://mirrors.ustc.edu.cn/homebrew-services.git

exit 0
