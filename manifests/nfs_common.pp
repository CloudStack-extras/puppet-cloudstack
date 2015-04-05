class cloudstack::nfs_common {
    #this subclass provides NFS for primary and secondary storage on a single machine.
    #this is not production quality - but useful for a POC/demo/dev/test environment. 
    #you will either want to significantly alter or use your own nfs class

	include cloudstack

	package {'nfs-utils':
        ensure => present,
    }

	service {'nfs':
		ensure    => running,
		enable    => true,
		hasstatus => true,
		require   => [
            Service['rpcbind'],
            File['/primary'],
            File['/secondary'],
        ],
	}

	service {'rpcbind':
		ensure    => running,
		enable    => true,
		hasstatus => true,
	}
	file {'/primary':
		ensure => directory,
		mode   => '0777',
	}
	file {'/secondary':
		ensure => directory,
		mode   => '0777',
	}
	file {'/etc/sysconfig/nfs':
		source => 'puppet://puppet/cloudstack/nfs',
		notify => Service['nfs'],
	}

	file {'/etc/exports':
		source => 'puppet://puppet/cloudstack/exports',
		notify => Service['nfs'],
	}

	iptables {'udp111':
		proto => 'udp',
		dport => '111',
		jump  => 'ACCEPT',
	}

	iptables {'tcp111':
		proto => 'tcp',
		dport => '111',
		jump  => 'ACCEPT',
	}

    iptables {'tcp2049':
        proto => 'tcp',
        dport => '2049',
        jump  => 'ACCEPT',
    }		

    iptables {'tcp32803':
        proto => 'tcp',
        dport => '32803',
        jump  => 'ACCEPT',
    }

    iptables {'udp32769':
        proto => 'udp',
        dport => '32769',
        jump  => 'ACCEPT',
    }

    iptables {'tcp892':
        proto => 'tcp',
        dport => '892',
        jump  => 'ACCEPT',
    }

    iptables {'udp892':
        proto => 'udp',
        dport => '892',
        jump  => 'ACCEPT',
    }

    iptables {'tcp875':
        proto => 'tcp',
        dport => '875',
        jump  => 'ACCEPT',
    }

    iptables {'udp875':
        proto => 'udp',
        dport => '875',
        jump  => 'ACCEPT',
    }

    iptables {'tcp662':
        proto => 'tcp',
        dport => '662',
        jump  => 'ACCEPT',
    }

    iptables {'udp662':
        proto => 'udp',
        dport => '662',
        jump  => 'ACCEPT',
    }
	
}

