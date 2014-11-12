class xen {
#    case $operatingsystem {
#        debian: {
            $packagelist = [ "xen-linux-system", "xen-tools", "debootstrap" ]
#        }
#        ubuntu: {
#            $packagelist = [ "xen-linux-system", "xen-tools", "debootstrap" ]
#        }
#    }

    package { $packagelist:
        ensure => installed,
    }

#    service { 'apache2':
#        ensure => running,
#        enable => true,
#        require => Package['nullmailer']
#    }

    exec { ['/bin/mv /etc/grub.d/10_linux /etc/grub.d/25_linux', '/bin/echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub']:
#        cwd => "/var/tmp",
#        creates => "/var/tmp/myfile",
#        path => ["/bin", "/usr/bin", "/usr/sbin"],

#        require => Package["xen-linux-system"],
        require => Package[$packagelist],
    }

#    file { "/etc/mailname":
#        mode => 644,
#        owner => root,
#        group => root,
#        source => "puppet:///modules/nullmailer/mailname",
#        require => Package["nullmailer"],
#    }

#    file { "/etc/nullmailer/remotes":
#        mode => 600,
#        owner => mail,
#        group => mail,
#        source => "puppet:///modules/nullmailer/remotes",
#        require => Package["nullmailer"],
#    }
}
