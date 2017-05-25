#!/usr/bin/env bash
# installateur pour epg de euroiptv
# Supported Operating Systems: 
# Ubuntu server 12.04/14.04/16.04
# 32bit and 64bit
EPG_INSTALLER_VERSION="1.0"
#--- Display the 'welcome' splash/user warning info..
echo ""
echo "############################################################"
echo "#  Welcome to the Official Sentora Installer $SENTORA_INSTALLER_VERSION  #"
echo "############################################################"

echo -e "\nChecking that minimal requirements are ok"

# Ensure the OS is compatible with the launcher
if [ -f /etc/centos-release ]; then
    OS="CentOs"
    VERFULL=$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)
    VER=${VERFULL:0:1} # return 6 or 7
elif [ -f /etc/lsb-release ]; then
    OS=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
    VER=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')
elif [ -f /etc/os-release ]; then
    OS=$(grep -w ID /etc/os-release | sed 's/^.*=//')
    VER=$(grep VERSION_ID /etc/os-release | sed 's/^.*"\(.*\)"/\1/')
 else
    OS=$(uname -s)
    VER=$(uname -r)
fi
ARCH=$(uname -m)

echo "Detected : $OS  $VER  $ARCH"

if [[ "$OS" = "Ubuntu" && ("$VER" = "12.04" || "$VER" = "14.04" || "$VER" = "16.04" ) ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by epg generator." 
    exit 1
fi

# Check if the user is 'root' before allowing installation to commence
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi

#--- Set custom logging methods so we create a log file in the current working directory.
logfile=$(date +%Y-%m-%d_%H.%M.%S_epg_install.log)
touch "$logfile"
exec > >(tee "$logfile")
exec 2>&1

apt-get update
apt-get -y dist-upgrade
apt-get install -y python-software-properties


if [[ "$OS" = "Ubuntu" && ("$VER" = "14.04" || "$VER" = "16.04" ) ]] ; then
apt-get -y install software-properties-common
apt-get install -y python3-software-properties
fi

add-apt-repository -y ppa:mythbuntu/xmltv
apt-get update
apt-get -y install xmltv wget
wget --no-check-certificate https://github.com/andykimpe/euroiptv-epg-fr/raw/master/tv_grab_telerama -O /usr/bin/tv_grab_telerama
chmod +x /usr/bin/tv_grab_telerama