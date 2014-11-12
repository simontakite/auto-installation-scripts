class apache {
    case $::osfamily {
        'redhat': {
            $apache_name = 'httpd'
        }
        'debian': {
            $apache_name = 'apache2'
        }
        default: {
            $apache_name = 'apache2'
        }
    }

    # install apache
    package { "$apache_name":
        ensure => installed,
        #name => 'apache2-mpm-prefork', # httpd if CentOS
        alias  => "apache",
    }

    # enable apache service
    service { 'apache2':
        ensure => running,
        enable => true,
        require => Package['apache']
    }

    file { "/var/www/index.html":
        mode => 644,
        owner => www-data,
        group => www-data,
        source  => "puppet:///modules/apache/index.html",
        require => Package["apache"],
    }
}
