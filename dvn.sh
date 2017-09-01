#!/bin/bash
set -e

#      FILENAME: dvn.sh
#       VERSION: 00.90
#         BUILD: 170901
#   DESCRIPTION: Used to setup a dvn environment in Linux
#       AUTHORS: Christopher Banwarth (development@aprettycoolprogram.com)
#     COPYRIGHT: 2017 A Pretty Cool Program
#       LICENSE: Apache License, Version 2.0 [http://www.apache.org/licenses/LICENSE-2.0]
#     MORE INFO: http://aprettycoolprogram.com/dvn

AddAptGetRepository() {
    case "$1" in
        "code")
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            curl -k https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
            ;;
        *) echo "Cannot add repository for $1"
            ,,
    esac
}

BuildPackage() {
    case "$1" in
        "abc")
            wget -P $dvnTemp http://homepages.cwi.nl/~steven/abc/implementations/abc.tar.gz
            sudo tar -C /usr/local -xzf $dvnTemp/abc.tar.gz
            echo "PATH=$PATH:/usr/local/ABC" >> .profile
            ;;
        "go")
            wget -P $dvnTemp https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz
            sudo tar -C /usr/local -xzf $dvnTemp/go1.9.linux-amd64.tar.gz
            mkdir $HOME/go
            echo "PATH=$PATH:/usr/local/go/bin" >> .profile
            echo "export GOPATH=$HOME/go" >> .bash_profile
            ;;
        "lua")
            InstallAptGetPackage libreadline-dev
            curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
            mv lua-5.3.4.tar.gz $dvnTemp
            cd $dvnTemp
            tar zxf lua-5.3.4.tar.gz
            cd lua-5.3.4
            make linux test
            make install
            ;;
        "rust")
            curl https://sh.rustup.rs -sSf | sh
            ;;
        "swift")
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
}

InstallAptGetPackage() {
    for package in "$@"; do
        sudo apt-get -y install $package | tee $dvnLogs/$package-install.log
    done
}

InstallAptGetPackageMinimal() {
    for package in "$@"; do
        sudo apt-get -y install $package --no-install-recommends | tee $dvnLogs/$package-install.log
    done
}

InstallPipPackage() {
    for package in "$@"; do
        sudo pip3 install $package | tee $dvnLogs/$package-install.log
    done
}

InstallVirtualMachineTools() {
    case "$1" in
        "virtualbox")
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

if [[ "$dvnArgs" =~ "--standard" ]]; then
    touch $HOME/.bash_profile
    InstallAptGetPackage localepurge curl apt-transport-https
    AddAptGetRepository code | tee $dvnLogs/code-add-repository.log
    UpdateAptGet
    InstallAptGetPackage build-essential linux-headers-$(uname -r) htop xorg
    InstallAptGetPackageMinimal xfce4
    InstallAptGetPackage tango-icon-theme xfce4-terminal code filezilla iceweasel pidgin nginx openjdk-8-jdk python python3 \
                        python3-pip python3-matplotlib python3-scipy ruby rails
    InstallPipPackage jupyter
    BuildPackagePackage go | tee $dvnLogs/go-install.log
    BuildPackagePackage lua | tee $dvnLogs/lua-install.log
    BuildPackagePackage rust | tee $dvnLogs/rust-install.log
    StartupItem nginx | tee $dvnLogs/configure-nginx.log
fi

# VirtualBox Guest Additions (optional).
if [[ "$dvnArgs" =~ "--virtualbox" ]]; then
    InstallVirtualMachineTools virtualbox | tee $dvnLogs/vboxguestadditions-install.log
fi

# Tested packages not included in the standard build (optional).
if [[ "$dvnArgs" =~ "--kitchensink" ]]; then
    # Ada
    InstallAptGetPackage gnat
    # Agda
    InstallAptGetPackage agda
    # Erlang
    InstallAptGetPackage erlang
    # Swift
    BuildPackagePackage swift | tee $dvnLogs/rust-install.log
fi

# Experimental packages, use at your own risk (optional).
if [[ "$dvnArgs" =~ "--experimental" ]]; then 
    desc="code-goes-here"
    #BuildPackage abc | tee $dvnLogs/abc-install.log ## [170901] This will install, but doesn't seem to work correctly.
fi

# Upgrade the system, cleanup apt-get, archive logfiles, and remove temporary files.
UpgradeAptGet
CleanAptGet
gzip $dvnLogs/*.log
rm -rf $dvnTemp/*

sudo reboot