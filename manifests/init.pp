# Class: cloudstack
#
# This class installs the base CloudStack components
#
# Parameters:
#
# Actions:
#   Install the CloudStack repository: [cloudstack]
#   Manage sudoers file
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

  case $::operatingsystem {
    /(centos|redhat)/: {
      $baseurl = "http://yumrepo/repositories/rhel/$::operatingsystemrelease/stable/oss/",
    }
    fedora: {
      $baseurl = 'http://192.168.203.177/foo/',
    }
    default: {
      fail( "Cloudstack module is only supported on CentOS, RedHat, and Fedora-based systems."
    }
  }

  yumrepo{ 'Cloudstack':
    baseurl  => $baseurl,
    name     => 'CloudStack',
    enabled  => 1,
    gpgcheck => 0,
  }

  file { '/etc/sudoers.d/':
    ensure  => directory,
    mode    => '0550',
    owner   => root,
    group   => root,
    require => Package[ 'sudo' ]
  }

  file { '/etc/sudoers.d/cloudstack.sudo':
    source => "puppet:///puppet/cloudstack/cloudstack.sudo"
    mode   => '0440',
    owner  => root,
    group  => root,
  }

  file { '/etc/hosts':
    content => template( 'cloudstack/hosts' ),
  }

  package { wget: ensure => present }   ### Not needed after 2.2.9, see bug 11258

  file { '/etc/selinux/config':
    source => 'puppet://puppet/cloudstack/config',
  }
  exec { '/usr/sbin/setenforce 0':
    onlyif => '/usr/sbin/getenforce | grep Enforcing',
  }
}
