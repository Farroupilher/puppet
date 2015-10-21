# class: varnish
class varnish {
    package { [ 'varnish', 'stunnel4' ]:
        ensure => present,
    }

    service { 'varnish':
        ensure  => 'running',
        require => Package['varnish'],
    }

    service { 'stunnel4':
        ensure  => 'running',
        require => Package['stunnel4'],
    }

    file { '/var/lib/varnish/mediawiki':
        ensure  => directory,
        notify  => Service['varnish'],
        require => Package['varnish'],
    }

    file { '/etc/varnish/default.vcl':
        ensure  => present,
        source  => 'puppet:///modules/varnish/varnish/default.vcl',
        notify  => Service['varnish'],
        require => Package['varnish'],
    }

    file { '/etc/default/varnish':
        ensure  => present,
        source  => 'puppet:///modules/varnish/varnish/varnish.default',
        notify  => Service['varnish'],
        require => Package['varnish'],
    }

    file { '/etc/systemd/system/varnish.service':
        ensure  => present,
        source  => 'puppet:///modules/varnish/varnish/varnish.service',
        require => Package['varnish'],
    }

    exec { 'systemctl daemon-reload':
        path    => '/bin',
        require => File['/etc/systemd/system/varnish.service'],
    }

    ssl::cert { 'wildcard.miraheze.org': }
    ssl::cert { 'spiral.wiki': }
    ssl::cert { 'anuwiki.com': }
    ssl::cert { 'antiguabarbudacalypso.com': }
    ssl::cert { 'permanentfuturelab.wiki': }
    ssl::cert { 'secure.reviwiki.info': }
    ssl::cert { 'wiki.printmaking.be': }

    nginx::site { 'mediawiki':
        ensure => present,
        source => 'puppet:///modules/varnish/nginx/mediawiki.conf',
    }

    file { '/etc/nginx/sites-enabled/default':
        ensure => absent,
        notify => Service['nginx'],
    }

    file { '/etc/stunnel/mediawiki.conf':
        ensure  => present,
        source  => 'puppet:///modules/varnish/stunnel.conf',
        notify  => Service['stunnel4'],
        require => Package['stunnel4'],
    }
}