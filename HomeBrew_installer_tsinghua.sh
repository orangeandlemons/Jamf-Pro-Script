#!/bin/bash

# Script to install Homebrew on a Mac.
# Author: richard at richard - purves dot com
# Version: 1.0 - 21st May 2017

# Heavily hacked by Tony Williams (honestpuck@gmail.com)
# Latest version at https://github.com/Honestpuck/homebrew.sh
# v2.0 - 19th Sept 2019
# v2.0.1 Fixed global cache error
# v2.0.2 Fixed brew location error
# v2.0.3 Added more directories to handle

# v3.0 Catalina version 2020-02-17
# v3.1 | 2020-03-24 | Fix permissions for /private/tmp
# v3.2 2020-07-18 Added Caskroom to directories created and added check for binary
# update if it exists then exit

# 2021-01-11 | Support for osx arm64 added by Shawn Smith (https://github.com/HelixSpiral)
# 2021-04-11 | Some Big Sur cleanup. Posting as 3.3

export HOMEBREW_INSTALL_FROM_API=1
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

# Set up variables and functions here
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

if [[ -e "${HOMEBREW_PREFIX}/bin/brew" ]]; then
    su -l "$consoleuser" -c "${HOMEBREW_PREFIX}/bin/brew update"
    exit 0
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

# Check and start logging
logme "Homebrew Installation"
#############################
# debug - commented out     #
# remove comments if needed #
############################# 
# logme "user is $consoleuser"
# logme "is user in dev group? $check_grp"

# Have the xcode command line tools been installed?
logme "Checking for Xcode Command Line Tools installation"
check=$( pkgutil --pkgs | grep -c "CLTools_Executables" )

if [[ "$check" != 1 ]]; then
    logme "Installing Xcode Command Tools"
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    clt=$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)
    # the above don't work in Catalina so ...
    if [[ -z $clt ]]; then
    	clt=$(softwareupdate -l | grep  "Label: Command" | tail -1 | sed 's#\* Label: \(.*\)#\1#')
    fi
    softwareupdate -i "$clt"
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi

# Is homebrew already installed?
if [[ ! -e "${HOMEBREW_PREFIX}/bin/brew" ]]; then
    # Install Homebrew. This doesn't like being run as root so we must do this manually.
    logme "Installing Homebrew"

    mkdir -p "${HOMEBREW_PREFIX}/Homebrew"
    # Curl down the latest tarball and install to ${HOMEBREW_PREFIX}/Homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "${HOMEBREW_PREFIX}/Homebrew"

    # Manually make all the appropriate directories and set permissions
    mkdir -p "${HOMEBREW_PREFIX}/Cellar" "${HOMEBREW_PREFIX}/Homebrew"
    mkdir -p "${HOMEBREW_PREFIX}/Caskroom" "${HOMEBREW_PREFIX}/Frameworks" "${HOMEBREW_PREFIX}/bin"
    mkdir -p "${HOMEBREW_PREFIX}/include" "${HOMEBREW_PREFIX}/lib" "${HOMEBREW_PREFIX}/opt" "${HOMEBREW_PREFIX}/etc" "${HOMEBREW_PREFIX}/sbin"
    mkdir -p "${HOMEBREW_PREFIX}/share/zsh/site-functions" "${HOMEBREW_PREFIX}/var"
    mkdir -p "${HOMEBREW_PREFIX}/share/doc" "${HOMEBREW_PREFIX}/man/man1" "${HOMEBREW_PREFIX}/share/man/man1"
    #chown -R "${consoleuser}":_developer "${HOMEBREW_PREFIX}/*"
    ##################################################################
    ### M Lamont changed to not overwrite existing folders, e.g jamf # 
    ###  also took th ebrackets out as this was stopping it working  #
    ###  and No I don't know why                                     #
    ##################################################################
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Cellar"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Homebrew"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Caskroom"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Frameworks"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/bin"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/include"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/lib"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/opt"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/etc"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/sbin"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/share"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/var"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/man"

    chmod -R g+rwx "${HOMEBREW_PREFIX}/*"
    chmod 755 "${HOMEBREW_PREFIX}/share/zsh" "${HOMEBREW_PREFIX}/share/zsh/site-functions"

    # Create a system wide cache folder  
    mkdir -p /Library/Caches/Homebrew
    chmod g+rwx /Library/Caches/Homebrew
    chown "${consoleuser}:_developer" /Library/Caches/Homebrew

    # put brew where we can find it
    ln -s "${HOMEBREW_PREFIX}/Homebrew/bin/brew" "${HOMEBREW_PREFIX}/bin/brew"

    # Install the MD5 checker or the recipes will fail
    su -l "$consoleuser" -c "${HOMEBREW_PREFIX}/bin/brew install md5sha1sum"
    echo 'export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"' | \
	tee -a /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
    chown ${consoleuser} /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
    
    # clean some directory stuff for Catalina
    chown -R root:wheel /private/tmp
    chmod 777 /private/tmp
    chmod +t /private/tmp

    ############################
    ## M Lamont Add to paths.d #
    ############################
    touch /etc/paths.d/brew
    echo "${HOMEBREW_PREFIX}/bin" > /etc/paths.d/brew
fi

# Make sure everything is up to date
logme "Updating Homebrew"
su -l "$consoleuser" -c "${HOMEBREW_PREFIX}/bin/brew update" 2>&1 | tee -a ${LOG}

# set shellenv for M1 users
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/${consoleuser}/.profile
    test -r ~/.bash_profile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    test -r ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi

# logme user that all is completed
logme "Installation complete"

export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"

# 手动设置
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

# 注：自 brew 4.0 起，大部分 Homebrew 用户无需设置 homebrew/core 和 homebrew/cask 镜像，只需设置 HOMEBREW_API_DOMAIN 即可。
# 如果需要使用 Homebrew 的开发命令 (如 `brew cat <formula>`)，则仍然需要设置 homebrew/core 和 homebrew/cask 镜像。
# 请按需执行如下两行命令：
brew tap --custom-remote --force-auto-update homebrew/core https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
brew tap --custom-remote --force-auto-update homebrew/cask https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git

# 除 homebrew/core 和 homebrew/cask 仓库外的 tap 仓库仍然需要设置镜像
brew tap --custom-remote --force-auto-update homebrew/cask-fonts https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
brew tap --custom-remote --force-auto-update homebrew/cask-versions https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-versions.git
brew tap --custom-remote --force-auto-update homebrew/command-not-found https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-command-not-found.git
brew tap --custom-remote --force-auto-update homebrew/services https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-services.git
brew update


test -r ~/.bash_profile && echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"' >> ~/.bash_profile  # bash
test -r ~/.bash_profile && echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> ~/.bash_profile  # bash
test -r ~/.bash_profile && echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> ~/.bash_profile
test -r ~/.profile && echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"' >> ~/.profile
test -r ~/.profile && echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> ~/.profile
test -r ~/.profile && echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> ~/.profile

test -r ~/.zprofile && echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"' >> ~/.zprofile  # zsh
test -r ~/.zprofile && echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> ~/.zprofile  # zsh
test -r ~/.zprofile && echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> ~/.zprofile
exit 0
