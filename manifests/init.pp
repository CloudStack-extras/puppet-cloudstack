# Class: cloudstack
#
# This class installs the base CloudStack components
#
# Parameters:
#
# Actions:
#   Install the CloudStack repository: [cloudstack]
#   Manage sudoers entry for cloud user
#   Manage hosts file
#   Turn off selinux
#   Ensure wget installed
#
# Requires:
#
# Package[ 'sudo' ]

# Sample Usage:
# This class should not be included directly.  It is called from other modules.
#
class cloudstack {
  include cloudstack::params


  resources { 'host': 
	name => "host",
	purge => true,
	}


  yumrepo{ 'cloudstack':
    baseurl  => 'http://cloudstack.apt-get.eu/rhel/4.2/'
    # baseurl  => 'http://cloudstack.apt-get.eu/rhel/4.1/',
    # baseurl  => 'http://cloudstack.apt-get.eu/rhel/4.0/',
    enabled  => 1,
    gpgcheck => 0,
  }

  file_line { 'cs_sudo_rule':
    path => '/etc/sudoers',
    line => 'cloud ALL = NOPASSWD : ALL',
  }

  host { 'localhost':
    ensure       => present,
    ip           => '127.0.0.1',
    host_aliases => [ $::fqdn, 'localhost.localdomain', $::hostname ],
  }

  package { 'wget': ensure => present } # Not needed after 2.2.9, see bug 11258

  file { '/etc/selinux/config':
    source => 'puppet:///modules/cloudstack/config',
  }

  exec { 'disable_selinux':
    command => '/usr/sbin/setenforce 0',
    onlyif  => '/usr/sbin/getenforce | grep Enforcing',
  }



################ base firewall ############################
#

  firewall { '001 allow icmp':
    proto => 'icmp',
    action => 'accept',
  }
  firewall { '002 allow all to lo interface':
    iniface => 'lo',
    action => 'accept',
  }

  firewall { '003 allow ssh':
	dport => '22',
        proto => 'tcp',
  }

}
