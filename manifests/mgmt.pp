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
  include cloudstack
  include mysql::server

  $dbstring = inline_template( "<%= \"/usr/bin/cloud-setup-databases \" +
              \"cloud:dbpassword@localhost --deploy-as=root\" %>" )

  package { 'cloud-client':
    ensure  => present,
    require => Yumrepo[ 'cloudstack' ],
  }

  service { 'cloud-management':
    ensure    => running,
    enable    => true,
    hasstatus => true, 
    require   => Package[ 'cloud-client' ],
  }

  exec { '/usr/bin/cloud-setup-management':
    unless  => [ '/usr/bin/test -e /etc/sysconfig/cloud-management' ],
    require => [ Service[ 'cloud-management' ], 
                 Exec[ 'cloud_setup_databases' ] ],
  }

  iptables { 'http':
    proto => 'tcp',
    dport => '80',
    jump  => 'ACCEPT',
  }

  iptables { 'http-alt':
    proto => 'tcp',
    dport => '8080',
    jump  => 'ACCEPT',
  }

###### this is the unauthenticated API interface - should be locked down by default.
#  iptables { 'port-8096':    
#    proto => 'tcp',
#    dport=> '8096',
#    jump => 'ACCEPT',
#    }

  iptables { 'port-8250':    #### Think this is for cpvm, but check for certain.
    proto => 'tcp',
    dport => '8250',
    jump  => 'ACCEPT',
  }

  iptables { 'port-9090':    ############# find out what this does in cloudstack
    proto => 'tcp',
    dport => '9090',
    jump  => 'ACCEPT',
  }

  exec { 'cloud_setup_databases':
    command => $dbstring,
    creates => '/var/lib/mysql/cloud',
    require => Service[ 'mysqld' ],
  }

  cloudstack::zone { 'zone1': }

########## Pod #################

# exec {'curl 'http://localhost:8096?command=createPod&gateway=192.168.203.1&name=Pod1&netmask=255.255.255.0&startip=192.168.203.200&zoneid=4&endip=192.168.203.230'':
#   onlyif => [ 'curl 'http://localhost:8096/?command=listZones&available=true' | grep Zone1', 
#     'curl 'http://localhost:8096/?command=listPods' | grep -v Pod1', 
#   ]
# }

########## Cluster ##############

# exec {'curl 'http://localhost:8096?command=addCluster&clustername=Cluster1&clustertype=CloudManaged&hypervisor=${hvtype}&zoneid=4&podid=1'':
#   onlyif => ['curl 'http://localhost:8096/?command=listZones&available=true' | grep Zone1',
#     'curl 'http://localhost:8096/?command=listPods' | grep Pod1',
#     'curl 'http://localhost:8096/?command=listClusters' | grep -v Cluster1',
#   ]
# }

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

}
