class icinga_ssh_client {
    package { "nagios-plugins-basic":
        ensure => installed,
    }

    # http://raw.github.com/justintime/nagios-plugins/master/check_mem/check_mem.pl
    file { "/usr/lib/nagios/plugins/check_mem":
        mode => 755,
        owner => root,
        group => root,
        require => Package['nagios-plugins-basic'],
        source => "puppet:///modules/icinga_ssh_client/check_mem",
    }

    # apt-get install -y nagios-plugins-contrib --no-install-recommends
    file { "/usr/lib/nagios/plugins/check_raid":
        mode => 755,
        owner => root,
        group => root,
        require => Package['nagios-plugins-basic'],
        source => "puppet:///modules/icinga_ssh_client/check_raid",
    }

    # TODO: relative path to id_rsa.pub
    # extract data from public key file (e.g. /var/lib/nagios/.ssh/id_rsa.pub)
    $ssh = split(file("/etc/puppet/modules/icinga_ssh_client/files/id_rsa.pub"), ' ')
    $ssh_type = values_at($ssh, 0)
    $ssh_key = values_at($ssh, 1)
    $ssh_id = values_at($ssh, 2)
    ssh_authorized_key { $ssh_id:
        ensure => present,
        user => root,
        type => $ssh_type,
        key => $ssh_key,
    }

    # alternatively, read key from file and remove line break
    # ssh_authorized_key { 'nagios@icinga':
    #    ensure => present,
    #    user => root,
    #    type => ssh-rsa,
    #    key => chomp(file("/etc/puppet/modules/icinga_ssh_client/files/id_rsa.pub")),
    # }
}
