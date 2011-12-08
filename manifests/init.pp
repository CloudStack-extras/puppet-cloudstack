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


  resources hosts { 
	name => "hosts",
	purge => true,
	}

  case $::operatingsystem {
    /(CentOS|redhat)/: {
#      $baseurl = "http://192.168.0.189/yumrepo/repositories/rhel/${::operatingsystemrelease} \
#                  /stable/oss/"
       $baseurl = "http://192.168.0.189/~eric/cloudstack_repo/"
    }
    fedora: {
      $baseurl = 'http://192.168.203.177/foo/'
    }
    default: {
      fail( 'Cloudstack module is only supported on CentOS, RedHat, and \
            Fedora-based systems.' )
    }
  }

  yumrepo{ 'cloudstack':
    baseurl  => $baseurl,
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
    host_aliases => [ 'localhost.localdomain', $::fqdn, $::hostname ],
  }

  package { 'wget': ensure => present } # Not needed after 2.2.9, see bug 11258

  file { '/etc/selinux/config':
    source => 'puppet:///modules/cloudstack/config',
  }

  exec { 'disable_selinux':
    command => '/usr/sbin/setenforce 0',
    onlyif  => '/usr/sbin/getenforce | grep Enforcing',
  }
}
