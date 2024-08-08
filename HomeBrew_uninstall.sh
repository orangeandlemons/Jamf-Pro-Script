#!/bin/bash

# Script to uninstall Homebrew installed by the previous script
# Author: Orales
# Date: 2024-1-5

# Set up variables and functions here
consoleuser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
UNAME_MACHINE="$(uname -m)"
HOMEBREW_PREFIX=""

# Set the prefix based on the machine type
HOMEBREW_PREFIX="/opt/homebrew"


# Logging stuff starts here
LOGFOLDER="/private/var/log/"
LOG="${LOGFOLDER}Homebrew_Uninstall.log"

if [ ! -d "$LOGFOLDER" ]; then
    mkdir $LOGFOLDER
fi

function logme()
{
    if [ -z "$1" ] ; then
        echo "$(date) - logme function call error: no text passed to function! Please recheck code!" | tee -a $LOG
        exit 1
    fi

    echo -e "$(date) - $1" | tee -a $LOG
}

logme "Homebrew Uninstallation"


# Uninstall Homebrew
logme "Uninstalling Homebrew"

# Remove symlinks and directories
rm -rf "${HOMEBREW_PREFIX}/bin/brew"
rm -rf "${HOMEBREW_PREFIX}/Homebrew"
rm -rf "${HOMEBREW_PREFIX}/Cellar"
rm -rf "${HOMEBREW_PREFIX}/Caskroom"
rm -rf "${HOMEBREW_PREFIX}/Frameworks"
rm -rf "${HOMEBREW_PREFIX}/include"
rm -rf "${HOMEBREW_PREFIX}/lib"
rm -rf "${HOMEBREW_PREFIX}/opt"
rm -rf "${HOMEBREW_PREFIX}/etc"
rm -rf "${HOMEBREW_PREFIX}/sbin"
rm -rf "${HOMEBREW_PREFIX}/share"
rm -rf "${HOMEBREW_PREFIX}/var"
rm -rf "${HOMEBREW_PREFIX}/man"
rm -rf /Library/Caches/Homebrew
rm -rf /opt/homebrew

# Remove paths.d entry
rm -f /etc/paths.d/brew

# Remove environment variable entries
sed -i '' '/HOMEBREW_BREW_GIT_REMOTE/d' ~/.bash_profile ~/.profile ~/.zprofile
sed -i '' '/HOMEBREW_CORE_GIT_REMOTE/d' ~/.bash_profile ~/.profile ~/.zprofile
unset HOMEBREW_BOTTLE_DOMAIN
unset HOMEBREW_API_DOMAIN
unset HOMEBREW_BREW_GIT_REMOTE
unset HOMEBREW_CORE_GIT_REMOTE

logme "Homebrew has been uninstalled successfully."

exit 0
