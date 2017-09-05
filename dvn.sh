#!/bin/bash
set -e

#      FILENAME: dvn.sh
#       VERSION: 00.92.00
#         BUILD: 170905
#   DESCRIPTION: Used to setup a dvn environment in Linux
#       AUTHORS: Christopher Banwarth (development@aprettycoolprogram.com)
#     COPYRIGHT: 2017 A Pretty Cool Program
#       LICENSE: Apache License, Version 2.0 [http://www.apache.org/licenses/LICENSE-2.0]
#     MORE INFO: http://aprettycoolprogram.com/dvn

## As packages are installed, they are added to this array. This is used to build the post-install report.
declare -a installedPackages

AddAptGetRepository() {
    case "$1" in
        "code") # Microsoft Visual Studio Code IDE
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            curl -k https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
            ;;
        "dart") # Dart language
            $ sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
            $ sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
            ;;
        "nodejs") # Node.js runtime
            curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
            ;;
        *) echo "Cannot add repository for $1"
            ,,
    esac
}

BuildPackage() {
    case "$1" in
        "abc") # ABC language -- BROKEN -- http://homepages.cwi.nl/~steven/abc/implementations.html
            wget -P $dvnTemp http://homepages.cwi.nl/~steven/abc/implementations/abc.tar.gz
            sudo tar -C /usr/local -xzf $dvnTemp/abc.tar.gz
            echo "PATH=$PATH:/usr/local/ABC" >> .profile
            ;;
        "dart") # Dart language -- https://www.dartlang.org/install/linux  
            echo "PATH=$PATH:/usr/lib/dart/bin" >> .profile
            sudo apt-get install dart
            ;;
        "go") # Go language -- https://golang.org/doc/install
            wget -P $dvnTemp https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz
            sudo tar -C /usr/local -xzf $dvnTemp/go1.9.linux-amd64.tar.gz
            mkdir $HOME/go
            echo "PATH=$PATH:/usr/local/go/bin" >> .profile
            echo "export GOPATH=$HOME/go" >> .bash_profile
            ;;
        "lua") # Lua language -- https://www.lua.org/download.html
            InstallAptGetPackage libreadline-dev
            curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
            mv lua-5.3.4.tar.gz $dvnTemp
            cd $dvnTemp
            tar zxf lua-5.3.4.tar.gz
            cd lua-5.3.4
            make linux test
            make install
            ;;
        "rust") # Rust language -- https://www.rust-lang.org/en-US/other-installers.html
            curl https://sh.rustup.rs -sSf | sh
            ;;
        "swift") # Swift language -- https://swift.org/download/#using-downloads
            InstallAptGetPackage clang libicu-dev
            wget -P $dvnTemp https://swift.org/builds/swift-3.1.1-release/ubuntu1610/swift-3.1.1-RELEASE/swift-3.1.1-RELEASE-ubuntu16.10.tar.gz
            tar xzf $dvnTemp/swift-3.1.1-RELEASE-ubuntu16.10.tar.gz -C $dvnTemp
            mkdir $dvnLanguages/Swift
            mv $dvnTemp/swift-3.1.1-RELEASE-ubuntu16.10/* $dvnLanguages/Swift/
            echo "PATH=$dvnLanguages/Swift/usr/bin" >> .profile
            ;;
        *)
            echo "Cannot add Virtual Machine tools for $1"
            ,,
    esac
    installedPackages+=($1)
}

InstallAptGetPackage() {
    for package in "$@"; do
        sudo apt-get -y install $package | tee $dvnLogs/$package-install.log
    installedPackages+=($1)
    done
}

InstallAptGetPackageMinimal() {
    for package in "$@"; do
        sudo apt-get -y install $package --no-install-recommends | tee $dvnLogs/$package-install.log
        installedPackages+=($1)
    done
}

InstallNpmPackage() {
    for package in "$@"; do
        sudo npm install --global $package | tee $dvnLogs/$package-install.log
    done
}

InstallPipPackage() {
    for package in "$@"; do
        sudo pip3 install $package | tee $dvnLogs/$package-install.log
    done
}

InstallVirtualMachineTools() {
    case "$1" in
        "virtualbox") # VirtualBox Guest Additions
            wget -P $dvnTemp http://download.virtualbox.org/virtualbox/5.1.26/VBoxGuestAdditions_5.1.26.iso
            sudo mount $dvnTemp/VBoxGuestAdditions_5.1.26.iso /media/cdrom
            sudo cp /media/cdrom/VBoxLinuxAdditions.run $dvnTemp
            sudo $dvnTemp/VBoxLinuxAdditions.run
            sudo usermod -a -G vboxsf crispy
            sudo umount /media/cdrom
            ;;
        *)
            echo "Cannot add Virtual Machine tools for $1"
            ,,
    esac
}

PurgeAptGetPackage() {
    for package in "$@"; do
        sudo apt-get -y purge $package | tee $dvnLogs/$package-install.log
    done
}

StartupItem() {
    case "$1" in
        "nginx")
            sudo systemctl enable nginx
            ;;
        *)
            echo "Cannot add startup item for $1"
            ;;
    esac
}

UpdateAptGet() {
    sudo apt-get -y update | tee $dvnLogs/aptget-update.log
}

UpgradeAptGet() {
    sudo apt-get -y upgrade | tee $dvnLogs/aptget-upgrade.log
    sudo apt-get -y dist-upgrade | tee $dvnLogs/aptget-dist-upgrade.log
}

CleanAptGet() {
    sudo apt-get autoremove | tee $dvnLogs/aptget-autoremove.log
    sudo apt-get -y autoclean | tee $dvnLogs/aptget-autoclean.log
    sudo apt-get -y clean | tee $dvnLogs/aptget-clean.log
}

# MAIN

# Store passed arguments.
dvnArgs="$@"
# Create required directories and $PATH entries.
dvnTemp="$HOME/.dvn/temp"
mkdir -p $dvnTemp
dvnLogs=$HOME/.dvn/logs/$(date "+%Y%m%d")
mkdir -p $dvnLogs
dvnLanguages=$HOME/Languages
mkdir -p $dvnLanguages

touch $HOME/.bash_profile

if [[ ! "$dvnArgs" =~ "--no-prereqs" ]]; then
    InstallAptGetPackage localepurge software-properties-common curl apt-transport-https
fi

if [[ "$dvnArgs" =~ "--standard" ]]; then
    AddAptGetRepository code | tee $dvnLogs/code-add-repository.log
    AddAptGetRepository nodejs | tee $dvnLogs/node.js-add-repository.log
    AddAptGetRepository dart | tee $dvnLogs/dart-add-repository.log
    UpdateAptGet
    InstallAptGetPackage build-essential linux-headers-$(uname -r) htop openssh-server xorg
    InstallAptGetPackageMinimal xfce4
    InstallAptGetPackage tango-icon-theme xfce4-terminal code filezilla iceweasel chromium pidgin nginx openjdk-8-jdk \
                         python python3 python3-pip python3-matplotlib python3-scipy ruby rails nodejs emacs gimp \
    InstallNpmPackage coffeescript
    InstallPipPackage jupyter
    BuildPackage dart | tee $dvnLogs/dart-install.log
    BuildPackage go | tee $dvnLogs/go-install.log
    BuildPackage lua | tee $dvnLogs/lua-install.log
    BuildPackage rust | tee $dvnLogs/rust-install.log
    StartupItem nginx | tee $dvnLogs/configure-nginx.log
fi

# VirtualBox Guest Additions (optional).
if [[ "$dvnArgs" =~ "--virtualbox" ]]; then
    InstallVirtualMachineTools virtualbox | tee $dvnLogs/vboxguestadditions-install.log
fi

# Tested packages not included in the standard build (optional).
if [[ "$dvnArgs" =~ "--kitchensink" ]]; then
    InstallAptGetPackage gnat                           # Ada
    InstallAptGetPackage agda                           # Agda
    InstallAptGetPackage erlang                         # Erlang
    sudo apt-get install haskell-platform               # Haskell
    BuildPackage swift | tee $dvnLogs/swift-install.log # Swift
fi

# Experimental packages, use at your own risk (optional).
if [[ "$dvnArgs" =~ "--experimental" ]]; then 
    NOTE="EXPERIMENTAL STUFF GOES HERE"
    #BuildPackage abc | tee $dvnLogs/abc-install.log ## [170901] This will install, but doesn't seem to work correctly.
fi

# Removes some things from Debian that you most likely don't need.
if [[ "$dvnArgs" =~ "--power-minimize" ]]; then 
    sudo rm -rf /usr/share/doc/*
    sudo rm -rf /usr/share/man/*
fi

# Upgrade the system, cleanup apt-get, archive logfiles, and remove temporary files.
UpgradeAptGet
CleanAptGet
gzip $dvnLogs/*.log
rm -rf $dvnTemp/*

clear
echo "  ISSUE REPORT"
echo "  ============"
echo
echo "  If a package is listed here, check the log file."
echo

for item in ${installedPackages[@]}; do
    eval test=$( dpkg -l $item | grep status 2>&1 )
done

echo
read -p "That's it! Press any key to reboot..."

sudo reboot
