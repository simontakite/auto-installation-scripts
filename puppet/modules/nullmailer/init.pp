class nullmailer {
    package { "nullmailer":
        ensure => installed,
    }

    service { 'nullmailer':
        ensure => running,
        enable => true,
        require => Package['nullmailer']
    }

    file { "/etc/mailname":
        mode => 644,
        owner => root,
        group => root,
        source => "puppet:///modules/nullmailer/mailname",
        require => Package["nullmailer"],
    }

    file { "/etc/nullmailer/remotes":
        mode => 600,
        owner => mail,
        group => mail,
        source => "puppet:///modules/nullmailer/remotes",
        require => Package["nullmailer"],
    }
}
