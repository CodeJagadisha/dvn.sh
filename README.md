# dvn.sh

#### dvn.sh is a Bash shell script that will automatically build a Debian linux baseed software development environment.

*dvn.sh is currently beta.*

To get the latest version of dvn.sh:

  > $ wget $HOME http://aprettycoolprogram.com/dvn/dvn.sh
  
  > $ chmod +x dvn.sh
 
 dvn.sh has the following options, which can be combined:
 
  **--standard**
    Installs a standard development environment containing:
    
      * localepurge
      * curl
      * apt-transport-https
      * build-essential
      * linux-headers
      * htop
      * xorg
      * xfce4 (minimal install)
      * tango-icon-theme
      * xfce4-terminal
      * Microsoft Visual Studio Code
      * Filezilla
      * Mozilla Firefox
      * Pidgin
      * Nginx
      * OpenJDK 8 JDK
      * Python2 2.7.13
      * Python3 3.5.3
      * Python3-pip
      * Python3-matplotlib
      * Python3-scipy
      * Jupyter
      * Ruby 2.3.1
      * Rails 4.2.7.1
      * Golang 1.9
      * Lua 5.3.4
      * Rust 1.2
      
  **--kitchensink**
    Installs additional packages and languages, including:
    
      * Ada 6.3.0 (w/gnat)
      * Agda 2.5.1.1
      * Erlang 8.2.1
      * Swift 3.1.1
      
  **--experimental**
    Installs experimental packages and languages, including:
    
      none
      
  **--virtualbox**
    Installs the Oracle VirtualBox Guest Additions.

When running dvn.sh for the first time, you have to include the "--standard" option

  > $ dvn.sh --standard

After dvn.sh has been run once, you can add some more obscure languages:

  > $ dvn.sh --kitchensink
  
Or you can do everything at once:

  > $ dvn.sh --standard --kitchensink -- virtualbox
  
