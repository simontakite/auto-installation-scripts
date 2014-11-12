class php5 {
    case $::osfamily {
        default: {
            $pkg = 'php5'
        }
    }

    # install PHP and restarts apache to load the module
    #package { ['php54', 'php54-apc', 'php54-mod-php']:
    package { "$pkg":
        ensure  => installed,
        notify  => Service['apache2'],
        #require => [ Package['php5-mysql'], Package['apache'] ],
        require => Package["apache"],
    }

    exec { "/bin/date -I > /tmp/debug": }
#cat /etc/apache2/mods-enabled/php5.conf
#<FilesMatch ".+\.ph(p[345]?|t|tml)|.htm([l]*)$">
}
