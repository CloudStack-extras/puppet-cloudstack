class cloudstack {
		include cloudstack::no_selinux

        case $operatingsystem {
                centos,redhat : {
                        yumrepo{"Cloudstack":
                                baseurl => "http://yumrepo/repositories/rhel/$operatingsystemrelease/stable/oss/",
                                name => "CloudStack",
                                enable => 1,
                                gpgcheck => 0,
                        }
                }
                fedora : {
                        yumrepo{"Cloudstack":
                                baseurl => "http://192.168.203.177/foo/",
                                name => "CloudStack",
                                enabled => 1,
                                gpgcheck => 0,
                	}

        	}

	}
        file { "/etc/sudoers":
                source =>  "puppet://puppet/cloudstack/sudoers",
		mode => 440,
		owner => root,
		group => root,
        }

######### DEFINITIONS ####################

	$cs_mgmt_server = "192.168.203.177"
	$dns1 = "192.168.203.1"
	$dns2 = "8.8.8.8"
	$cs_agent_netmask = "255.255.255.0"
	


}
class cloudstack::nfs-common {
#this subclass provides NFS for primary and secondary storage on a single machine.
#this is not production quality - but useful for a POC/demo/dev/test environment. 
#you will either want to significantly alter or use your own nfs class

	include cloudstack

	package {nfs-utils: ensure => present}

	service {nfs:
		ensure => running,
		enable => true,
		hasstatus => true,
		require => [ Service[rpcbind], File["/primary"], File["/secondary"] ],
	}

	service {rpcbind: 
		ensure => running,
		enable => true,
		hasstatus => true,
	}
	file {"/primary":
		ensure => directory,
		mode => 777,
	}
	file {"/secondary":
		ensure => directory,
		mode => 777,
	}
	file {"/etc/sysconfig/nfs":
		source => "puppet://puppet/cloudstack/nfs",
		notify => Service[nfs],
	}

	file {"/etc/exports":
		source => "puppet://puppet/cloudstack/exports",
		notify => Service[nfs],
	}

	iptables {"udp111":
		proto => "udp",
		dport=> "111",
		jump => "ACCEPT",
	}

	iptables {"tcp111":
		proto => "tcp",
		dport => "111",
		jump => "ACCEPT",
	}

        iptables {"tcp2049":
                proto => "tcp",
                dport => "2049",
                jump => "ACCEPT",
        }		

        iptables {"tcp32803":
                proto => "tcp",
                dport => "32803",
                jump => "ACCEPT",
        }

        iptables {"udp32769":
                proto => "udp",
                dport => "32769",
                jump => "ACCEPT",
        }

        iptables {"tcp892":
                proto => "tcp",
                dport => "892",
                jump => "ACCEPT",
        }

        iptables {"udp892":
                proto => "udp",
                dport => "892",
                jump => "ACCEPT",
        }

        iptables {"tcp875":
                proto => "tcp",
                dport => "875",
                jump => "ACCEPT",
        }

        iptables {"udp875":
                proto => "udp",
                dport => "875",
                jump => "ACCEPT",
        }

        iptables {"tcp662":
                proto => "tcp",
                dport => "662",
                jump => "ACCEPT",
        }

        iptables {"udp662":
                proto => "udp",
                dport => "662",
                jump => "ACCEPT",
        }
	
}


class cloudstack::kvmagent {
	include cloudstack 
	package {cloud-agent : ensure => present, require => Yumrepo[CloudStack], }

	exec { "cloud-setup-agent":
		creates => "/var/log/cloud/setupAgent.log",
		requires => [ Package[cloud-agent], 
				Package[NetworkManager], 
				File["/etc/sudoers"], 
				File["/etc/cloud/agent/agent.properties"],
				File["/etc/sysconfig/network-scripts/ifcfg-eth0"], 
				File["/etc/hosts"], 
				File["/etc/sysconfig/network"], 
				File["/etc/resolv.conf"], 
				Service["network"], ]
	}


	file { "/etc/cloud/agent/agent.properties": 
		ensure => present,
		requires => Package[cloud-agent],
		content =>  template("cloudstack/agent.properties")
	}

######## AGENT NETWORKING SECTION SEE NOTES BEFORE END OF NETWORKING SECTION ############
	
	file { "/etc/sysconfig/network-scripts/ifcfg-eth0":
		content => template("cloudstack/ifcfg-eth0"),
	}


	service { network: 
		ensure => running, 
		enabed => true,
		hasstatus => true, ## Is that really true?
		requires => [ Package[NetworkManager], File["/etc/sysconfig/network-scripts/ifcfg-eth0"], ]
	}
	
	package { NetworkManager:
		ensure => absent,
	}

	file { "/etc/sysconfig/network":
		content => template("cloudstack/network"),
	}

	file { "/etc/hosts":  ## Note this file pulls from facter - you may need to adjust to define this externally
		content => template("cloudstack/hosts"),
	} 

	file { "/etc/resolv.conf":
		content => template("cloudstack/resolv.conf"),
	}

### NOTES: This assumes a single NIC (eth0) will be used for CloudStack and ensures that the 
### config file is correct syntactically and in place
### If you wish to use more than a single NIC you will need to edit both the agent.properties
### file and add additional ifcfg-ethX files to this configuration. 
### 

######### END AGENT NETWORKING ##############################################################

 
########## Also need to create a agent.properties stanza, and likely need to define
########## IP address or name for management server - and do agent.properties as a template. 
############ Need to do something that will take care of IP configuration
############ Need to do something that will take care of KVM - make sure module is loaded - need to define what tests cloud-setup-agent actually runs to test for KVM and ensure that we do those tests as well, and rectify if needed (do a reboot?? )
### Need to handle hostname addition as well - and probably a def gw and ensuring that DNS is set since
### we are so backwards as to not use DHCP


### IP Address thoughts:
### Use a template based on /etc/sysconfig/ifcfg-ethX
### By default only specify eth0, with liberal commenting about what to do in the event of needing to change our simple configuration (e.g. edit agent.properites, add additional network config, etc. 
### Require network to be enable
### Require NetworkManager be disabled (Is it installed by default, do we need to do a case?, perhaps we 'ensure absent') 
### Make sure we cycle network after deploying a ifcfg. 
### Do we handle creation of cloud-br0? I am thinking not, seems like there's a lot of magic there. For now, lets stay away from that. 

}

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
		jump => "ACCEPT",}

	iptables { "http-alt":
		proto => "tcp",
		dport=> "8080",
		jump => "ACCEPT",
		}

#	iptables { "port-8096":      ###### this is the unauthenticated API interface - should be locked down by default.
#		proto => "tcp",
#		dport=> "8096",
#		jump => "ACCEPT",
#		}

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

	exec {"curl 'http://localhost:8096?command=createPod&gateway=192.168.203.1&name=Pod1&netmask=255.255.255.0&startip=192.168.203.200&oneid=4&endip=192.168.203.230'"
		onlyif => ["curl 'http://localhost:8096/?command=listZones&available=true' | grep -v Zone1", 
			"curl 'http://localhost:8096/?command=listPods' | grep -v Pod1", ]
	} 
}

class cloudstack::no_selinux {
	file { "/etc/selinux/config":
		source => "puppet://puppet/cloudstack/config",
	}
	exec { "/usr/sbin/setenforce 0":
		onlyif => "/usr/sbin/getenforce | grep Enforcing",
	}
}
