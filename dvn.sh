#!/bin/bash
set -e

#      FILENAME: dvn.sh
#       VERSION: 00.89.00
#         BUILD: 170831
#   DESCRIPTION: Used to setup a dvn environment in Linux
#       AUTHORS: Christopher Banwarth (development@aprettycoolprogram.com)
#     COPYRIGHT: 2017 A Pretty Cool Program
#       LICENSE: Apache License, Version 2.0 [http://www.apache.org/licenses/LICENSE-2.0]
#     MORE INFO: http://aprettycoolprogram.com/dvn

## This script will build a software development environment for a Debian linux based distribution. I recommend using
## this script on a clean environment. For the most part everything will be automatic, but there are some spots that
## will need user interaction.

dvnTemp="$HOME/.dvn/temp"

InstallPackage()
{
    for package in "$@"; do
        sudo apt-get -y install $package | tee $dvnTemp/install-$package.log
    done
}

InstallPackageMinimal()
{
    for package in "$@"; do
        sudo apt-get -y install $package --no-install-recommends | tee $dvnTemp/install-$package.log
    done
}

InstallBackportPackage()
{
    for package in "$@"; do
        sudo apt-get -y install -t jessie-backports $package --no-install-recommends | tee $dvnTemp/install-$package.log
    done
}

PurgePackage()
{
    ## Purge package(s) via apt-get, and drop a history file.
    for package in "$@"; do
        if [[ ! -f $HOME/.crispy/history/PurgePackage.$package ]]; then
            sudo apt-get -y purge $package | tee $dvnTemp/purge-$package.log
        fi
    done
}

Update()
{
    sudo apt-get update | tee -a $dvnTemp/update-aptget.log
}

Upgrade()
{
    sudo apt-get upgrade | tee -a $dvnTemp/upgrade-aptget.log
    sudo apt-get dist-upgrade | tee -a $dvnTemp/dist-upgrade-aptget.log
}

Clean()
{    
    if [[ $1 == "deborphan" ]]; then
        sudo deborphan | xargs sudo apt-get -y remove --purge | tee -a $dvnTemp/deborphan-01.log
        sudo deborphan --guess-data | xargs sudo apt-get -y remove --purge | tee -a $dvnTemp/deborphan-02.log
    fi

    if [[ $1 == "directories" ]]; then
        sudo rm -rf /usr/share/man/* | tee -a $dvnTemp/remove-manpages.log
        sudo rm -rf /usr/share/doc/* | tee -a $dvnTemp/remove-docfiles.log
    fi

    if [[ $1 == "bleachbit" ]]; then
        sudo bleachbit --clean apt.* \
                               bash.* \
                               deepscan.* \
                               system.* | tee -a $dvnTemp/bleachbit.log
    fi

    if [[ $1 == "aptget" ]]; then
        sudo apt-get autoremove | tee -a $dvnTemp/autoremove-aptget.log
        sudo apt-get autoclean | tee -a $dvnTemp/autoclean-aptget.log
        sudo apt-get clean | tee -a $dvnTemp/clean-aptget.log
    fi
}

# MAIN

mkdir -p $dvnTemp

if [[ "#@" =~ "minimal" ]]; then
    PurgePackage dictionaries-common \
                 eject \
                 gettext-base \
                 gnupg \
                 ispell \
                 laptop-detect \
                 vim-common \
                 wamerican
fi

# Prerequistes
Update
InstallPackageMinimal localepurge \
                      build-essential \
                      linux-headers-$(uname -r) \
                      curl \
                      apt-transport-https

if [[ "#@" =~ "minimal" ]]; then
    InstallPackageMinimal python \
                          deborphan \
                          bleachbit
fi

# 816MB

# Window managers
InstallPackage xorg
InstallPackageMinimal xfce4
InstallPackage tango-icon-theme \
               xfce4-terminal

# GUI applications
InstallPackage filezilla
InstallPackageMinimal pidgin

# Oracle VirtalBox Guest Additions
if [[ "#@" =~ "virtualbox" ]]; then
    wget -P $dvnTemp http://download.virtualbox.org/virtualbox/5.1.26/VBoxGuestAdditions_5.1.26.iso
    sudo mount $dvnTemp/VBoxGuestAdditions_5.1.26.iso /media/cdrom
    sudo cp /media/cdrom/VBoxLinuxAdditions.run $dvnTemp
    sudo $dvnTemp/VBoxLinuxAdditions.run
    sudo usermod -a -G vboxsf crispy
    sudo umount /media/cdrom
fi

# Microsoft Visual Studio Code
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
curl -k https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
Update
InstallPackageMinimal "code"

# Nginx
InstallPackageMinimal nginx
sudo systemctl enable nginx

# OpenJava JDK
sudo sh -c 'echo "deb http://http.debian.net/debian jessie-backports main non-free contrib" >> /etc/apt/sources.list'
InstallBackportPackage openjdk-8-jdk

# Python3, pip, and Jupyter notebooks - minimal?
InstallPackage python3 \
               python3-pip \
               python3-matplotlib \
               python3-scipy
sudo pip3 install --upgrade pip # need?
sudo pip3 install jupyter

if [[ "#@" =~ "kitchensink" ]]; then
    # ABC
    wget $HOME/Downloads/ABC http://homepages.cwi.nl/~steven/abc/implementations/abc.tar.gz | tee $dvnTemp/install-abc.log
    sudo tar -C /usr/local -xzf $HOME/Downloads/ABC/abc.tar.gz | tee -a $dvnTemp/install-abc.log

    # Ada
    InstallPackage gnat

    # Erlang
    InstallPackage erlang

    # Go
    wget -P $dvnTemp https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz | tee $dvnTemp/install-go.log
    sudo tar -C /usr/local -xzf $dvnTemp/go1.8.3.linux-amd64.tar.gz | tee -a $dvnTemp/install-go.log
    echo "PATH=$PATH:/usr/local/go/bin" >> .profile | tee -a $dvnTemp/install-go.log

    # Lua
    curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz > $dvnTemp/lua-5.3.4.tar.gz | tee $dvnTemp/install-lua.log
    tar $dvnTemp/lua-5.3.4.tar.gz zxf lua-5.3.4.tar.gz | tee -a $dvnTemp/install-lua.log
    cd $dvnTemp/lua-5.3.4.tar.gz/lua-5.3.4
    make linux test | tee -a $dvnTemp/install-lua.log

    # Perl - installed w/build-essentials

    # Python2
    InstallPackageMinimal python2

    # Rust
    curl https://sh.rustup.rs -sSf | sh | tee $dvnTemp/install-rust.log
fi

PurgePackage "orage"

if [[ "#@" =~ "minimal" ]]; then
    Clean deborphan
    Clean directories
    Clean bleachbit
fi

Clean aptget

#clean logs
