#!/bin/bash

# This script will run once after a fresh installation

# todo
# clear terminal from wrapped lines

LOG=/var/log/auto-install.log
#MAC=$(LANG=us_EN; ifconfig -a | head -1 | awk /HWaddr/'{print tolower($5)}')
if [ ! -z $1 ]; then
    MAC=$1
else
    MAC=$(ip link | sed -n "/BROADCAST.*state UP/{n;p}" | tail -1 | tr -s " " | cut -d" " -f3)
    if [ -z ${MAC} ]; then
        IFACE=$(route | grep default | sed -e's/  */ /g' | cut -d" " -f8)
        MAC=$(ip link | sed -n "/${IFACE}/{n;p}" | tail -1 | tr -s " " | cut -d" " -f3)
    fi
fi

MAC_HASH=$(echo ${MAC} | md5sum | cut -d" " -f1)


# default functions
function script4() {
    if [ ! -z ${1} ]; then
        URL=https://raw.githubusercontent.com/panticz/installit/master/${1}
        FILE=${URL##*/}

        echo "URL:$URL"

        wget -q --no-check-certificate ${URL} -O /tmp/${FILE}
        chmod +x /tmp/${FILE}
        bash /tmp/${FILE} ${2} 2>&1 | tee -a ${LOG}
    fi
}

# install
function install() {
    echo "--- install $@ ---" >> ${LOG}
    apt-get install -y --force-yes $@ 2>&1 | tee -a ${LOG}
}

# create user
function addUser() {
    USERNAME=$1

        echo "--- addUser ($USERNAME)---"

    if [ ! -z $USERNAME ]; then
        useradd -m $USERNAME
        echo $USERNAME > /tmp/pw
        echo $USERNAME >> /tmp/pw
        passwd $USERNAME < /tmp/pw
        rm /tmp/pw
    fi
}


#
# APPS
#
function install_ubuntu-restricted-extras() {
    script4 install.ubuntu-restricted-extras.sh
}

function install_skype() {
    script4 install.skype.sh
}

function install_twinkle() {
    script4 install.twinkle.sh
}

function install_boxee() {
    script4 dep/install.boxee.sh
}

function install_openttd() {
    script4 install.openttd.sh
}

function install_wine() {
    script4 install.wine.sh
}

function install_hibiscus() {
    script4 install.hibiscus.sh
}

function install_dropbox() {
    script4 install.dropbox.sh
}

function install_acroread() {
    script4 install.acroread.sh
}

function install_icinga() {
    script4 install.icinga.sh
}

function install_puppet_client() {
    script4 install.puppet-client.sh
}

function install_nemo() {
    script4 install.nemo.sh
}


#
# DEVELOPMENT
#
function install_sqldeveloper() {
    script4 install.sqldeveloper.sh http://srv/ubuntu/install/sqldeveloper-no-jre.zip $1
}

function install_netbeans() {
    script4 install.netbeans.sh

    # fix bold menu font
    sudo apt-get remove -y fonts-unfonts-core
}

function install_eclipse() {
    script4 install.eclipse.sh
}



#
# PRINTER
#
function install_HP-Laserjet-4050n() {
    PRINTER_NAME=$1
    PRINTER_IP=$2
    
    # check parameter
    [ -z ${PRINTER_NAME} ] && PRINTER_NAME=HP-Laserjet-4050n
    [ -z ${PRINTER_IP} ] && PRINTER_IP=hp4050
    
    # create printer
    wget -q http://dl.panticz.de/hardware/hp_laserjet_4050n/HP-Laserjet-4050n.ppd -O /tmp/HP-Laserjet-4050n.ppd
    sudo lpadmin -p ${PRINTER_NAME} -v socket://${PRINTER_IP}:9100 -E -P /tmp/HP-Laserjet-4050n.ppd
    rm /tmp/HP-Laserjet-4050n.ppd
    
    #sudo /usr/bin/lpoptions -o Resolution=600dpi -o Option1=True -o Duplex=DuplexNoTumble -o InputSlot=Auto 
}

function install_HP-Officejet-Pro-8500-a910() {
    IP=$1
    
    wget -q http://dl.panticz.de/hardware/hp_officejet-pro-8500/HP-Officejet-Pro-8500-a910.ppd -O /tmp/HP-Officejet-Pro-8500-a910.ppd
    sudo lpadmin -p HP8500 -v socket://${IP}:9100 -E -P "/tmp/HP-Officejet-Pro-8500-a910.ppd"
}

function install_Canon-LBP() {
    IP=$1
    
    wget -q http://dl.panticz.de/hardware/canon_lbp/Canon-LBP-5975.ppd -O /tmp/Canon-LBP-5975.ppd
    sudo lpadmin -p CanonLBP -v socket://${IP}:9100 -E -P "/tmp/Canon-LBP-5975.ppd"
}

function install_Kyocera-FS-C5016N() {
    # get driver from kyocera homepage
    wget http://www.kyoceramita.de/dlc/de/driver/all/linux_ppd_s_ksl_8.-downloadcenteritem-Single-File.downloadcenteritem.tmp/Linux_PPDs_KSL8_4.zip -P /tmp/
    unzip /tmp/Linux_PPDs_KSL8_4.zip -d /tmp
    sudo lpadmin -p LaserColor -v socket://192.168.1.15:9100 -E -P "/tmp/PPD's_KSL_8.4/English/Kyocera_Mita_FS-C5016N_en.ppd"
#Foomatic/hpijs-pcl5e
    # -o PageSize=A4

    # install linux driver
    # foomatic-ppdfile -p "foomatic-ppdfile:Kyocera-FS-C5016N-Postscript.ppd" > /tmp/Kyocera-FS-C5016N-Postscript.ppd
    # lpadmin -p LaserColorOben -v socket://192.168.1.11:9100 -E -P /tmp/Kyocera-FS-C5016N-Postscript.ppd -o PageSize=A4

    # clean up
    rm /tmp/Linux_PPDs_KSL8_4.zip
    rm -r /tmp/PPD*_KSL_8.4
}

function install_Kyocera-FS-3820N() {
    # get driver from kyocera homepage
    wget http://www.kyoceramita.de/dlc/de/driver/all/linux_ppd_s_ksl_8.-downloadcenteritem-Single-File.downloadcenteritem.tmp/Linux_PPDs_KSL8_4.zip -P /tmp/
    unzip /tmp/Linux_PPDs_KSL8_4.zip -d /tmp
    sudo lpadmin -p Laser -v socket://192.168.1.11:9100 -E -P "/tmp/PPD's_KSL_8.4/English/Kyocera_Mita_FS-3820N_en.ppd"

    # clean up
    rm /tmp/Linux_PPDs_KSL8_4.zip
    rm -r /tmp/PPD*_KSL_8.4
}

function install_epson_business_inkjet() {
    script4 hardware/install.epson-business-inkjet.sh
    sudo lpadmin -p EpsonOben -v socket://EpsonOben:2501 -E -P /usr/share/cups/model/ekpxb310.ppd
    # -o DefaultInputSlot=Front
    # lpoptions -p EpsonColor -o MediaType=PLAIN -o PageSize=A5
}
        
function install_Kyocera_FS-1010() {
    PRINTER_NAME=$1
    PRINTER_IP=$2
    
    # check parameter
    [ -z ${PRINTER_NAME} ] && PRINTER_NAME=Kyocera-FS-1010
    [ -z ${PRINTER_IP} ] && PRINTER_IP=kyocera
    
    # create printer
    wget -q http://dl.panticz.de/hardware/kyocera_fs-1010/Kyocera-FS-1010.ppd -O /tmp/Kyocera-FS-1010.ppd
    sudo lpadmin -p ${PRINTER_NAME} -v socket://${PRINTER_IP}:9100 -E -P /tmp/Kyocera-FS-1010.ppd
    rm /tmp/Kyocera-FS-1010.ppd
}

function install_java-jdk() {
    sudo apt-get remove -y openjdk*
    script4 install.java-jdk.sh
}

function install_java-jre() {
    #script4 install.java-jre.sh
    echo "There is no Java JRE available, install JDK..."
    install_java-jdk
}

function install_yajhfc() {
    script4 install.yajhfc.sh
}

function install_language() {
    install openoffice.org-help-de openoffice.org-l10n-de gimp-help-de gnome-user-guide-de openoffice.org-hyphenation openoffice.org-hyphenation-de openoffice.org-thesaurus-de openoffice.org-thesaurus-de-ch gimp-help-en gnome-user-guide-en openoffice.org-help-en-gb openoffice.org-l10n-en-gb openoffice.org-l10n-en-za openoffice.org-hyphenation-en-us openoffice.org-thesaurus-en-au openoffice.org-thesaurus-en-us
}

# install desktop
function install_gnome_desktop() {
    # install gnome desktop
    sudo apt-get -q install -y ubuntu-desktop

    # install extras
    install_desktop_extras

    # install gnome 3 classic
    if [ $(lsb_release -rs | tr -d ".") -ge 1110 ]; then
        install_gnome_fallback
    fi

    # configure nautilus
    gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t string -s /apps/nautilus/preferences/default_folder_viewer 'list_view'
    gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t string -s /apps/nautilus/list_view/default_zoom_level smallest
    gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t string -s /apps/nautilus/preferences/show_directory_item_counts never

    # fix network manager, else VPN wont work
    sudo sed -i 's|managed=false|managed=true|g' /etc/NetworkManager/nm-system-settings.conf
    sudo sed -i 's|managed=false|managed=true|g' /etc/NetworkManager/NetworkManager.conf

    # fix wait 60 sec for network
    sudo sed -i "s|sleep|#sleep|g" /etc/init/failsafe.conf

    # install "old" nautilus
#    if [ $(lsb_release -rs | tr -d ".") -ge 1304 ]; then
#        sudo add-apt-repository -y ppa:webupd8team/experiments
#        sudo apt-get update -qq
#        sudo apt-get -y dist-upgrade
#    fi

    # disable screen saver lock
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t boolean -s /apps/gnome-power-manager/lock_on_blank_screen false
    gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t boolean -s /apps/gnome-power-manager/lock_use_screensaver_settings false
    gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t boolean -s /apps/gnome-screensaver/idle_activation_enabled false

    # fix clock in natty
    # todo (set for all user)
    gsettings set com.canonical.indicator.datetime show-day true
    gsettings set com.canonical.indicator.datetime show-date true

    # remove indicator-me applet
    # sudo apt-get remove -y indicator-me

    # remove unnecessary software
    sudo apt-get remove -y gnome-orca onboard
    rm /etc/xdg/autostart/orca-autostart.desktop

    # oneiric tweaks
    sudo apt-get install -y compizconfig-settings-manager
    
    # turn off error reporting
    sudo sed -i 's|enabled=1|enabled=0|g' /etc/default/apport

    # fix network manager
    if [ $(lsb_release -rs | tr -d ".") -ge 1310 ]; then
        sed -i '$ i\service network-manager restart' /etc/rc.local
    else
        sed -i '$ i\/etc/init.d/network-manager restart' /etc/rc.local
    fi
}

function install_lxdm_desktop() {
    # install lubuntu desktop
    install lubuntu-desktop

    # install pulse audio
    install pavucontrol pulseaudio pulseaudio-utils

    # install extras
    install_desktop_extras
}

# install default applications
function install_desktop_extras() {
    install_ubuntu-restricted-extras
    install_thunderbird
    install_firefox
# dep # install_java-jre
    install_libreoffice
    install_teamviewer
    install_vlc
    apt-get install -y p7zip

    install linux-firmware-nonfree

    #broken?
    #install_language

    # fix slow print dialog (maverick)
# dep # sed -i 's|Listen /var/run/cups/cups.sock|#Listen /var/run/cups/cups.sock|g' /etc/cups/cupsd.conf
}

# install gnome 3 fallback (classic)
function install_gnome_fallback() {
    script4 install.gnome-fallback.sh
}


# install thunderbird
function install_thunderbird() {
    script4 install.thunderbird.sh
}

# install firefox
function install_firefox() {
    script4 install.firefox.sh
}

# install libreoffice
function install_libreoffice() {
    script4 install.libreoffice.sh 
}

# install multimedia
function install_multimedia() {
    install_skype
    install_dvd
    # install gbrainy
    install_vlc
}

# install vlc
function install_vlc() {
    script4 install.vlc.sh
}

# install pulseaudio equalizer
function install_pulseaudio-equalizer() {
    script4 install.pulseaudio-equalizer.sh
}

# install dvd support
function install_dvd() {
    script4 install.libdvdcss.sh
}

function install_nero() {
    script4 install.nero.sh http://fs/ubuntu/install/nerolinux-x86_64.deb
}

function install_mysql-admin() {
    script4 install.mysql-admin.sh
}

# install develop
function install_develop() {
    install_netbeans
    install_eclipse
    apt-get install -y scite
    #install_mysql-admin
}

function install_ssh-server() {
    apt-get install -y openssh-server
}

# install mr
function install_mr() {
    install -y openvpn network-manager-openvpn tofrodos imagemagick sshfs patch
    apt-get install -y libreoffice-java-common libreoffice-base libreoffice-officebean
#err?    install_yajhfc
    install_HP-Laserjet-4050n HP-Laserjet-4050n 192.168.1.18

    # install and configure ssh mounts
    wget -q http://dl.panticz.de/mr/install.mrshare.sh -O - | sudo bash -

    # configure database source
    # wget -q http://dl.panticz.de/mr/DataAccess.xcu.diff -O /tmp/DataAccess.xcu.diff
    # patch -p2 /usr/lib/openoffice/share/registry/data/org/openoffice/Office/DataAccess.xcu < /tmp/DataAccess.xcu.diff

    # install nfs
    sudo apt-get install -y nfs-common

    # create mount directories
    mkdir /media/programme /media/bilder /media/lagerliste /media/projekte /media/texte
    
    # create mountpoints
    sudo echo "srv:/programme          /media/programme      nfs4    _netdev,auto  0  0" >> /etc/fstab
    sudo echo "srv:/bilder             /media/bilder         nfs4    _netdev,auto  0  0" >> /etc/fstab
    sudo echo "srv:/lagerliste         /media/lagerliste     nfs4    _netdev,auto  0  0" >> /etc/fstab
    sudo echo "srv:/projekte           /media/projekte       nfs4    _netdev,auto  0  0" >> /etc/fstab
    sudo echo "srv:/texte              /media/texte          nfs4    _netdev,auto  0  0" >> /etc/fstab

    # load nfs module on startup
    cat /etc/modules | grep nfs || echo nfs >> /etc/modules
    
    # install forms
    install_forms

    # create gnome menu
    wget -q http://dl.panticz.de/mr/ritter.gnome.menu.sh -O - | sudo bash -
}

# ubuntu tuneup
function ubuntu_tuneup() {
    # disable vnc-server (broken?)
    #gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults/ -t boolean -s /desktop/gnome/remote_access/enabled false

    # remove apps from autostart
    mkdir /etc/xdg/autostart/disabled
    mv /etc/xdg/autostart/bluetooth-applet.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/evolution-alarm-notify.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/gnome-at-session.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/gnome-user-share.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/jockey-gtk.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/libcanberra-login-sound.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/ubuntuone-launch.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/user-dirs-update-gtk.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/vino-server.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/gwibber.desktop /etc/xdg/autostart/disabled/

    # disable services
    update-rc.d -f avahi-daemon remove
    update-rc.d -f bluetooth remove
}

# ubuntu_tuneup_extreme
function ubuntu_tuneup_extreme() {
    ubuntu_tuneup

    #mv /etc/xdg/autostart/gnome-power-manager.desktop /etc/xdg/autostart/disabled/
    #mv /etc/xdg/autostart/nm-applet.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/redhat-print-applet.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/update-notifier.desktop /etc/xdg/autostart/disabled/
    mv /etc/xdg/autostart/zeitgeist-datahub.desktop /etc/xdg/autostart/disabled/

    # disable compiz effects (broken)
    # gconftool-2 --type string --set /apps/gnome-session/rh/window_manager "metacity"

    update-rc.d -f laptop-mode remove
    update-rc.d -f rsync remove
    #update-rc.d -f powernowd remove
}

# install teamviewer
function install_teamviewer() {
    script4 install.teamviewer.sh
}

# install spotify
function install_spotify() {
    script4 install.spotify.sh
}

# autostart
function autostart_radio() {
    script4 gnome/enable.autostart.radio.sh $1 $2
}

# gnome
function gnome_autologin() {
    script4 gnome/enable.autologin.sh $1
    script4 gnome/disable_screenlock.sh
}

function gnome_human_list() {
    script4 gnome/enable.humanlist.sh
}

function gnome_tuneup() {
    script4 gnome/enable.reduced_resources.sh
}

# disable consistent network device naming
function disable_biosdevname() {
    wget --no-check-certificate https://raw.githubusercontent.com/panticz/scripts/master/disable_biosdevname.sh -O - | bash -
}

# install
function install_forms() {
    install_wine
    wget -q http://dl.panticz.de/mr/install.forms.sh -O - | sudo bash -s $1
}

function install_umtsmon() {
    script4 dep/install.umtsmon.sh
}

function install_tipp10() {
    script4 install.tipp10.txt
}

function install_xbmc() {
    script4 install.xbmc.sh
}

function install_gimp() {
    script4 install.gimp.sh
}

function install_handbrake() {
    script4 install.handbrake.sh
}

function install_chromium() {
    script4 install.chromium.sh
}

function install_virtualbox() {
    script4 install.virtualbox.sh $1
}

function install_bcm() {
    script4 dep/install.bcm.sh
}

function install_kvm() {
     apt-get install -y kvm #qemu
}

function install_xen() {
    script4 install.xen.sh
}

function install_lxc() {
    script4 install.lxc.sh
}

function install_docker() {
    apt-get install -y docker.io
}

function configure_pawkon() {
    echo "LABEL=home /home ext4 defaults 0 0" >> /etc/fstab

    apt-get install -y git
    apt-get install -y curl
    apt-get install -y terminator
    apt-get install -y whois

    apt-get install -y virtualbox
    apt-get install -y virtualbox-guest-utils
    apt-get install -y vagrant

    vagrant plugin install vagrant-salt
    vagrant plugin install vagrant-vbox-snapshot
    
    # remove unnecessary applications
    apt-get remove -y gnome-sudoku
    apt-get remove -y gnome-mahjongg
    apt-get remove -y gnome-mines
    apt-get remove -y aisleriot
    apt-get remove -y vino
    apt-get remove -y cheese
    apt-get remove -y empathy
    apt-get remove -y transmission-common
    apt-get remove -y simple-scan
    apt-get remove -y shotwell
    apt-get autoremove -y
    
    # TODO: run as user on first login
    # set default settings
    wget https://raw.githubusercontent.com/panticz/scripts/master/pako.sh -O - | bash -
}

function configure_pakonb() {
sudo apt-get clean | tee -a ${LOG}

# preconfigure fstab
if [ "${MAC_HASH}" == "ca9ee1b29e06b343d73346b82a717e3d" ]; then
#    echo "/dev/mapper/vg0-data    /home                 ext4    defaults      0  2" >> /etc/fstab
    echo "#/dev/sda4    /home                 ext4    defaults      0  2" >> /etc/fstab
fi

# fix wifi
update-rc.d network-manager defaults

# create mount directories
mkdir /media/hs /media/video /media/develop

cat <<EOF>> /etc/fstab
hs:/hs                  /media/hs             nfs4    _netdev,auto  0  0
hs:/video               /media/video          nfs4    _netdev,auto  0  0
tmpfs                   /tmp                  tmpfs   nosuid,size=50% 0  0
srv:/develop            /media/develop        nfs4    _netdev,auto  0  0
EOF


# add user to group
usermod -a -G fuse pako
usermod -a -G lpadmin pako
#?# usermod -a -G admin pako

# install aplications
###apt-get install -y vncviewer xvnc4viewer
###apt-get install -y couturier
###apt-get install -y gnomebaker
###apt-get install -y telepathy-sofiasip
install_chromium
install_gimp
install_hibiscus
sudo apt-get install -y filezilla
sudo apt-get install -y fprint-demo #libfprint0 libpam-fprint
sudo apt-get install -y libnotify-bin
sudo apt-get install -y pdftk
sudo apt-get install -y mbr mtools tofrodos
sudo apt-get install -y syslinux
sudo apt-get install -y searchmonkey
sudo apt-get install -y compizconfig-settings-manager
sudo apt-get install -y pdfshuffler
sudo apt-get install -y libmysql-java
sudo apt-get install -y nfs-common
sudo apt-get install -y dvdbackup
sudo apt-get install -y nautilus-image-converter
sudo apt-get install -y gnote
sudo apt-get install -y isomaster
sudo apt-get install -y hamster-indicator
sudo apt-get install -y clusterssh
install_handbrake
sudo apt-get install -y git
sudo apt-get install -y meld
sudo apt-get install -y build-essential
sudo apt-get install -y ipmitool
sudo apt-get install -y nmap
sudo apt-get install -y gconf-editor
sudo apt-get install -y rdesktop
sudo apt-get install -y libav-tools
sudo apt-get install -y terminator
sudo apt-get install -y curl
install_docker
install_lxc
install_twinkle

# remove unnecessary applications
apt-get remove -y gnome-sudoku gnome-mahjongg gnome-mines aisleriot

# install mssql driver
wget http://netcologne.dl.sourceforge.net/project/jtds/jtds/1.2.5/jtds-1.2.5-dist.zip -P /tmp/
unzip /tmp/jtds-1.2.5-dist.zip -d /tmp/
sudo cp /tmp/jtds-1.2.5.jar /usr/share/java/

# install printer
install_HP-Officejet-Pro-8500-a910 192.168.1.15
install_Kyocera_FS-1010 Kyocera-FS-1010 192.168.2.1
install_Canon-LBP 172.29.12.115

# set default printer
sudo lpoptions -d HP-Laserjet-4050n

# todo truecrypt (todo)
# http://hacktolive.org/wiki/Repository

# dep # script4 dep/install.sflphone.sh

# BROKEN # .config perimssions are set to root
# script4 dep/install.app-runner.sh

# set android usb rights
cat <<EOF> /etc/udev/rules.d/70-android.rules
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", MODE="0666"
EOF

# auto usb run
sudo wget http://www.panticz.de/sites/default/files/scripts/udev/70-persistent-usb_autorun.rules -O /etc/udev/rules.d/70-persistent-usb_autorun.rules
sudo wget http://www.panticz.de/sites/default/files/scripts/udev/usb_autorun.sh -O /usr/sbin/usb_autorun.sh
chmod a+x /usr/sbin/usb_autorun.sh

# configure sudoers
echo "pako ALL=NOPASSWD: /home/pako/privat/scripts/build/mkXbmc.sh" >> /etc/sudoers

# Fix: "mei_me 0000:00:03.0: unexpected reset: dev_state = RESETTING"
echo "blacklist mei_me" | sudo tee /etc/modprobe.d/blacklist-mei_me.conf

# restore OpenVPN configuration
wget https://raw.githubusercontent.com/panticz/scripts/master/restoreOpenvpnConfig.sh -O - | bash -

# restore WiFi configuration
wget https://raw.githubusercontent.com/panticz/scripts/master/restoreWifiConfig.sh -O - | bash -

# TODO: run as user on first login
# set default settings
wget https://raw.githubusercontent.com/panticz/scripts/master/pako.sh -O - | bash -
}

function install_nvidia_graphic() {
    script4 install.nvidia-graphic.sh
}

function addToFuse() {
    USER=$1

    sudo usermod -a -G fuse ${USER}
}

function enable_auto_update() {
    wget --no-check-certificate https://raw.githubusercontent.com/panticz/scripts/master/enable_auto_update.sh -O - | bash -
}

function install_ipmitool() {
    script4 install.ipmitool.sh
}

function install_cpuburn() {
    script4 install.cpuburn.sh
}

function update_grub() {
    for DEV in $(ls /dev/sd?); do
        grub-install ${DEV}
    done
}

function install_powermeter() {
    install_gnome_desktop
    install openssh-server
    install stress 
    install libcurl3
    install wget
    #powernowd
    #cpufrequtils
    #cpufreqd
    #sysfsutils

    install_ipmitool
    install_cpuburn
    
    # configure xdm cpuload
    wget -q http://dl.panticz.de/sts/install.powermeter.cpuload.sh -O - | sudo bash -
    
    #gnome_autologin
}


#function install_docky() {
#    add-apt-repository ppa:docky-core/ppa
#    apt-get update -qq
#    apt-get install -y docky
#       apt-get install -y xdotool
#}

function disable_apt_proxy() {
    sed -i 's|Acquire::http::Proxy|#Acquire::http::Proxy|g' /etc/apt/apt.conf
}

function install_webserver() {
debconf-set-selections <<\EOF
mysql-server-5.1 mysql-server/root_password_again string t00r
mysql-server-5.1 mysql-server/root_password string t00r
EOF
 
# install web server
apt-get -y install apache2 php5 mysql-server php5-mysql php5-mcrypt php5-gd php5-curl php5-cli libapache2-mod-auth-mysql bzip2 wget
 
# configure apache modules
a2enmod auth_mysql

sudo apt-get install -y openssh-server
}



#
# MAIN
#

# clear terminal
clear

# Disable console blanking
setterm -blank 0

# Save start time
echo "--- START ${MAC} $(date) ---" >> ${LOG}

# Update the package list
apt-get update -qq | tee -a ${LOG}
apt-get dist-upgrade -y -qq | tee -a ${LOG}

# Install basics needed for further installation or debugging
echo "MAC: ${MAC}"
echo "MAC_HASH: ${MAC_HASH}"

# get post install script for client
wget -q "http://preseed.panticz.de/lc/${MAC_HASH}" -O /tmp/lc.sh && chmod 777 /tmp/lc.sh && . /tmp/lc.sh

# Set the debconf priority back to low
#echo debconf debconf/priority select low | debconf-set-selections -v  2>&1 | tee -a ${LOG}

# Save the end time
echo "--- START ${MAC} $(date) ---" >> ${LOG}

# Remove init script
#dep# rm /etc/rc2.d/S99install
[ -f /etc/init/late_command.conf ] && rm /etc/init/late_command.conf

# Update the package list
apt-get update -qq | tee -a ${LOG}
apt-get dist-upgrade -y -qq | tee -a ${LOG}

# clean up
apt-get clean | tee -a ${LOG}
apt-get -y autoremove | tee -a ${LOG}

# disable APT proxy
disable_apt_proxy

# remove dummy lvm
[ -L /dev/vg0/dummy ] && lvremove -f /dev/vg0/dummy

# Sync and reboot
sync
sleep 3
reboot
