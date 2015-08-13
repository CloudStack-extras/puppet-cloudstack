# Class: cloudstack::mgmt
#
# This class builds the CloudStack management node
#
# Parameters:
#
# Actions:
# Install the cloud-client package
# Install cloud database only if MySQL is installed and configured
# Run cloud-setup-management script
# Open appropriate iptables ports
#
# Requires:
#
# Package[ 'sudo' ]

# Sample Usage:
# This class should not be included directly.  It is called from other modules.
#
class cloudstack::mgmt {

#  include mysql::server   #
## We really want to specify this - but in the absence of this

########### MYSQL section #########
  package { 'mysql-server':
    ensure => present,
    }

  service { 'mysqld':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package[ 'mysql-server' ],
  }

######### END MYSQL #####################################

  $dbstring = inline_template( "<%= \"/usr/bin/cloudstack-setup-databases \" +
              \"cloud:dbpassword@localhost --deploy-as=root\" %>" )
# If you are using a separate database or different passwords, change it above


  package { 'cloudstack-management':
    ensure  => present,
    require => Yumrepo[ 'cloudstack' ],
  }

  service { 'cloudstack-management':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [Package[ 'cloudstack-management' ], Service[ 'mysqld' ], File[ '/etc/cloudstack/management/tomcat6.conf' ], File[ '/usr/share/cloudstack-management/conf/server.xml' ] ],
  }

  exec { '/usr/bin/cloudstack-setup-management':
    unless  => [ '/usr/bin/test -e /etc/sysconfig/cloudstack-management' ],
    require => [ Service[ 'cloudstack-management' ],
    Exec[ 'cloudstack_setup_databases' ] ],
  }

  exec { 'cloudstack_setup_databases':
    command => $dbstring,
    creates => '/var/lib/mysql/cloud',
    require => [Package[ 'cloudstack-management' ], Service[ 'mysqld' ] ],
  }


  ######################################################
  ############## tomcat section ########################
  ######################################################


  file { '/etc/cloudstack/management/tomcat6.conf':
    ensure  => 'link',
    group   => '0',
    mode    => '0777',
    owner   => '0',
    target  => 'tomcat6-nonssl.conf',
    require => Package[ 'cloudstack-management' ],
  }

  file { '/usr/share/cloudstack-management/conf/server.xml':
    ensure  => 'link',
    group   => '0',
    mode    => '0777',
    owner   => '0',
    target  => 'server-nonssl.xml',
    require => Package[ 'cloudstack-management' ],
  }


######################################################
############ firewall section ########################
######################################################


  firewall { '003 allow port 80 in':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }


  firewall { '120 permit 8080 - web interface':
    proto  => 'tcp',
    dport  => '8080',
    action => 'accept',
  }

###### this is the unauthed API interface - should be locked down by default.
# firewall { '130 permit unauthed API':
#   proto => 'tcp',
#   dport => '8096',
#   jump  => 'accept',
# }
#

  firewall { '8250 CPVM':    #### Think this is for cpvm, but check for certain.
    proto  => 'tcp',
    dport  => '8250',
    action => 'accept',
  }

  firewall { '9090 unk port':    ######## find out what this does in cloudstack
    proto  => 'tcp',
    dport  => '9090',
    action => 'accept',
  }


}
########## SecStorage ############
## NOTE: This will take a LONG time to run. Go get a cup of coffee
# exec { 'mount ${cloudstack::cs_sec_storage_nfs_server}:${cloudstack::cs_sec_storage_mnt_point}  /mnt ;
#   ${cloudstack::system_tmplt_dl_cmd} -m /mnt -u ${cloudstack::sysvm_url_kvm} -h kvm -F ;
#   curl 'http://localhost:8096/?command=addSecondaryStorage&url=nfs://${cloudstack::cs_sec_storage_nfs_server}${cloudstack::cs_sec_storage_mnt_point}&zoneid=1' ;
#   touch /var/lib/cloud/ssvm':
#   onlyif => [ 'test ! -e /var/lib/cloud/ssvm', 'curl 'http://localhost:8096/?command=listZones&available=true' | grep Zone1',]
# }

########## Primary Storage ########
### THis needs to add a check for a host to have been added
# exec { 'curl 'http://localhost:8096/?command=createStoragePool&name=PStorage&url=nfs://${cloudstack::pri_storage_nfs_server}${cloudstack::pri_storage_mnt_point}&zoneid=4&podid=1'':
#   onlyif => ['curl 'http://localhost:8096/?command=listPods' | grep Pod1',
#     'curl 'http://localhost:8096/?command=listStoragePools' | grep -v PStorage',
#   ]
# }
