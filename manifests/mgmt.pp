class cloudstack::mgmt {
  include cloudstack

  package {cloud-client : ensure => present, require => Yumrepo[CloudStack], }

  exec { "cloud-setup-management":
    onlyif => [ "test -e /var/lib/mysql/cloud", 
      "test -e /etc/sysconfig/cloud-management", 
      "service cloud-management status |grep -v running" ]  
    #The last check won't work on systemd, need to come up with some alternative
    }
########## Requires the iptables module from: http://github.com/camptocamp/puppet-iptables/ 

  iptables { "http":
    proto => "tcp",
    dport=> "80",
    jump => "ACCEPT",
  }

  iptables { "http-alt":
    proto => "tcp",
    dport=> "8080",
    jump => "ACCEPT",
  }

#  iptables { "port-8096":      ###### this is the unauthenticated API interface - should be locked down by default.
#    proto => "tcp",
#    dport=> "8096",
#    jump => "ACCEPT",
#    }

  iptables { "port-8250":     ############ Think this is for cpvm, but check for certain. 
    proto => "tcp",
    dport=> "8250",
    jump => "ACCEPT",
  }

  iptables { "port-9090":    ####################### find out what this does in cloudstack
    proto => "tcp",
    dport=> "9090",
    jump => "ACCEPT",
  }


#################### MYSQL SECTION - can likely be removed if you are using puppet in production and use your own mysql module #########
# wondering if i should do this as a separate subclass

  package {mysql-server : ensure => present }

  service {mysqld:
    name => $operatingsystem? {
      default => "mysqld",
      ubuntu => "mysql",
    },
    ensure => running, 
    enable => true, 
    hasstatus => true, 
    require => Package[mysql-server],
  }

  file {"/etc/my.cnf":
    source => "puppet://puppet/cloudstack/my.cnf",
    notify => Service[mysqld],
  }

  exec {"cloud-setup-databases cloud:dbpassword@localhost --deploy-as=root":
    creates => "/var/lib/mysql/cloud",
  }

################## END MYSQL SECTION ###################################################################################################
    
################## CloudStack configuration section ####################################################################################

########## Zone ################

  exec {"curl 'http://localhost:8096/?command=createZone&dns1=8.8.8.8&internaldns1=8.8.8.8&name=Zone1&networktype=Basic'":
    onlyif => "curl 'http://localhost:8096/?command=listZones&available=true' | grep -v Zone1"
  }

########## Pod #################

  exec {"curl 'http://localhost:8096?command=createPod&gateway=192.168.203.1&name=Pod1&netmask=255.255.255.0&startip=192.168.203.200&zoneid=4&endip=192.168.203.230'":
    onlyif => [ "curl 'http://localhost:8096/?command=listZones&available=true' | grep Zone1", 
      "curl 'http://localhost:8096/?command=listPods' | grep -v Pod1", 
    ]
  }

########## Cluster ##############

  exec {"curl 'http://localhost:8096?command=addCluster&clustername=Cluster1&clustertype=CloudManaged&hypervisor=${hvtype}&zoneid=4&podid=1'":
    onlyif => ["curl 'http://localhost:8096/?command=listZones&available=true' | grep Zone1",
      "curl 'http://localhost:8096/?command=listPods' | grep Pod1",
      "curl 'http://localhost:8096/?command=listClusters' | grep -v Cluster1",
    ]
  }

########## SecStorage ############
## NOTE: This will take a LONG time to run. Go get a cup of coffee
  exec { "mount ${cloudstack::cs_sec_storage_nfs_server}:${cloudstack::cs_sec_storage_mnt_point}  /mnt ; 
    ${cloudstack::system_tmplt_dl_cmd} -m /mnt -u ${cloudstack::sysvm_url_kvm} -h kvm -F ; 
    curl 'http://localhost:8096/?command=addSecondaryStorage&url=nfs://${cloudstack::cs_sec_storage_nfs_server}${cloudstack::cs_sec_storage_mnt_point}&zoneid=1' ;
    touch /var/lib/cloud/ssvm":
    onlyif => [ "test ! -e /var/lib/cloud/ssvm", "curl 'http://localhost:8096/?command=listZones&available=true' | grep Zone1",]
  }

########## Primary Storage ########
### THis needs to add a check for a host to have been added
  exec { "curl 'http://localhost:8096/?command=createStoragePool&name=PStorage&url=nfs://${cloudstack::pri_storage_nfs_server}${cloudstack::pri_storage_mnt_point}&zoneid=4&podid=1'":
    onlyif => ["curl 'http://localhost:8096/?command=listPods' | grep Pod1",
      "curl 'http://localhost:8096/?command=listStoragePools' | grep -v PStorage", 
    ]
  }

}
