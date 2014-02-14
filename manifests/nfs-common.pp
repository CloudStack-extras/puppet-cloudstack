# Class: cloudstack::nfs-common
#
# this subclass provides NFS for primary and secondary storage
# on a single machine. this is not production quality - but useful
# for a POC/demo/dev/test environment.
# you will either want to significantly alter or use your own nfs class
class cloudstack::nfs-common {

  include cloudstack

  package {'nfs-utils':
    ensure => present
  }

  service {'nfs':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [ Service[rpcbind], File['/primary'], File['/secondary'] ],
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
    source => 'puppet:///modules/cloudstack/nfs',
    notify => Service[nfs],
  }

  file {'/etc/exports':
    source => 'puppet:///modules/cloudstack/exports',
    notify => Service[nfs],
  }

  firewall {'111 udp':
    proto  => 'udp',
    dport  => '111',
    action => 'accept',
  }

  firewall {'111 tcp':
    proto  => 'tcp',
    dport  => '111',
    action => 'accept',
  }

  firewall {'2049 tcp':
    proto  => 'tcp',
    dport  => '2049',
    action => 'accept',
  }

  firewall {'32803 tcp':
    proto  => 'tcp',
    dport  => '32803',
    action => 'accept',
  }

  firewall {'32769 udp':
    proto  => 'udp',
    dport  => '32769',
    action => 'accept',
  }

  firewall {'892 tcp':
    proto  => 'tcp',
    dport  => '892',
    action => 'accept',
  }

  firewall {'892 udp':
    proto  => 'udp',
    dport  => '892',
    action => 'accept',
  }

  firewall {'875 tcp':
    proto  => 'tcp',
    dport  => '875',
    action => 'accept',
  }

  firewall {'875 udp':
    proto  => 'udp',
    dport  => '875',
    action => 'accept',
  }

  firewall {'662 tcp':
    proto  => 'tcp',
    dport  => '662',
    action => 'accept',
  }

  firewall {'662 udp':
    proto  => 'udp',
    dport  => '662',
    action => 'accept',
  }

}
