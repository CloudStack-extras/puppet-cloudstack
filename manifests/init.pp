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
class cloudstack (

  $mgmt_port = $cloudstack::params::mgmt_port,
  $cs_mgmt_server = $cloudstack::params::cs_mgmt_server,
  $cs_agent_netmask = $cloudstack::params::cs_agent_netmask,
  $cs_sec_storage_nfs_server = $cloudstack::params::cs_sec_storage_nfs_server,
  $cs_sec_storage_mnt_point = $cloudstack::params::cs_sec_storage_mnt_point,
  $pri_storage_nfs_server = $cloudstack::params::pri_storage_nfs_server,
  $pri_storage_mnt_point = $cloudstack::params::pri_storage_mnt_point,
  $hvtype = $cloudstack::params::hvtype,
  $system_tmplt_dl_cmd = $cloudstack::params::system_tmplt_dl_cmd,
  $sysvm_url_kvm = $cloudstack::params::sysvm_url_kvm,
  $sysvm_url_xen = $cloudstack::params::sysvm_url_xen,


) inherits cloudstack::params {


  resources { 'host':
    name  => 'host',
    purge => true,
  }


  yumrepo{ 'cloudstack':
    baseurl  => 'http://cloudstack.apt-get.eu/rhel/4.2/',
    # baseurl  => 'http://cloudstack.apt-get.eu/rhel/4.1/',
    # baseurl  => 'http://cloudstack.apt-get.eu/rhel/4.0/',
    enabled  => '1',
    gpgcheck => '0',
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
    proto  => 'icmp',
    action => 'accept',
  }
  firewall { '002 allow all to lo interface':
    iniface => 'lo',
    action  => 'accept',
  }

  firewall { '003 allow ssh':
    dport => '22',
    proto => 'tcp',
  }
}
