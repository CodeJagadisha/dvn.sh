# dvn.sh

#### dvn.sh is a Bash shell script that will automatically build a Debian linux baseed software development environment.

*This project has moved:* https://github.com/APrettyCoolProgram/stackfor)


---
This is the original README text for dvn.sh
---

To get the latest version of dvn.sh:

  > $ wget $HOME http://aprettycoolprogram.com/dvn/dvn.sh
  > $ chmod +x dvn.sh
 
 dvn.sh has the following options, which can be combined:
 
  **--standard**
    Installs a standard development environment containing:
    
      * localepurge
      * software-properties-common
      * curl
      * apt-transport-https
      * build-essential
      * linux-headers
      * htop
      * openssh-server
      * emacs
      * gimp
      * xorg
      * xfce4 (minimal install)
      * tango-icon-theme
      * xfce4-terminal
      * Microsoft Visual Studio Code
      * Filezilla
      * Mozilla Firefox
      * Chromium
      * Pidgin
      * Nginx
      * Dart
      * Golang
      * Jupyter
      * Lua
      * Node.js
          * CoffeeScript
      * OpenJDK
      * Python2
      * Python3
          * pip
          * matplotlib
          * scipy
      * Ruby
      * Rails
      * Rust
      
  **--kitchensink**
    Installs additional packages and languages, including:
    
      * Ada
          *GNAT
      * Agda
      * Erlang
      * Haskell
      * Swift
      
  **--experimental**
    Installs experimental packages and languages, including:
    
      none
      
  **--virtualbox**
    Installs the Oracle VirtualBox Guest Additions.

  **--no-prereqs**
    If you're using dvn.sh multiple times, using this argument will skip the prerequisite setup.
    
  **--power-minimize**
    For power-users. This will reduce the footprint of your image by removing unecessary components from Debian.

When running dvn.sh for the first time, you have to include the "--standard" option

  > $ dvn.sh --standard

After dvn.sh has been run once, you can add some more obscure languages:

  > $ dvn.sh --kitchensink
  
Or you can do everything at once:

  > $ dvn.sh --standard --kitchensink -- virtualbox
  
