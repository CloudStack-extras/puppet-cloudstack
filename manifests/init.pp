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

  file_line { 'cs_sudo_rule'
    path => '/etc/sudoers',
    line => 'cloud ALL = NOPASSWD : ALL',
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
