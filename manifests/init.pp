class cloudstack {
		include cloudstack::no_selinux

        case $operatingsystem {
                centos,redhat : {
                        yumrepo{"Cloudstack":
                                baseurl => "http://yumrepo/repositories/rhel/$operatingsystemrelease/stable/oss/",
                                name => "CloudStack",
                                enabled => 1,
                                gpgcheck => 0,
                        }
                }
                fedora : {
                        yumrepo{"Cloudstack":
                                baseurl => "http://yumrepo/repositories/fedora/$operatingsystemrelease/stable-2.2/oss/",
                                name => "CloudStack",
                                enabled => 1,
                                gpgcheck => 0,
                	}

        	}

	}
}
class cloudstack::nfs-common {
#this subclass provides NFS for primary and secondary storage on a single machine.
#this is not production quality - but useful for a POC/demo/dev/test environment. 
#you will either want to significantly alter or use your own nfs class

	include cloudstack

	package {nfs-utils: ensure => present}

	service {nfs:
		ensure => running,
		enabled => true,
		hasstatus => true,
		require => Service[rpcbind],
		require => File["/primary"],
		require => File["/secondary"],
	}

	service {rpcbind: 
		ensure => running,
		enabled => true,
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
		port => "111",
		jump => "ACCEPT",
	}

	iptables {"tcp111":
		proto => "tcp",
		port  => "111",
		jump => "ACCEPT",
	}

        iptables {"tcp2049":
                proto => "tcp",
                port  => "2049",
                jump => "ACCEPT",
        }		

        iptables {"tcp32803":
                proto => "tcp",
                port  => "32803",
                jump => "ACCEPT",
        }

        iptables {"udp32769":
                proto => "udp",
                port  => "32769",
                jump => "ACCEPT",
        }

        iptables {"tcp892":
                proto => "tcp",
                port  => "892",
                jump => "ACCEPT",
        }

        iptables {"udp892":
                proto => "udp",
                port  => "892",
                jump => "ACCEPT",
        }

        iptables {"tcp875":
                proto => "tcp",
                port  => "875",
                jump => "ACCEPT",
        }

        iptables {"udp875":
                proto => "udp",
                port  => "875",
                jump => "ACCEPT",
        }

        iptables {"tcp662":
                proto => "tcp",
                port  => "662",
                jump => "ACCEPT",
        }

        iptables {"udp662":
                proto => "udp",
                port  => "662",
                jump => "ACCEPT",
        }
	
}


class cloudstack::kvmagent {
	include cloudstack 
	package {cloud-agent : ensure => present, require => Yumrepo[CloudStack], }
}

class cloudstack::mgmt {
	include cloudstack


	package {cloud-client : ensure => present, require => Yumrepo[CloudStack], }


########## Requires the iptables module from: http://github.com/camptocamp/puppet-iptables/ 

	iptables { "http":
		proto => "tcp",
		dport => "80",
		jump => "ACCEPT",
	}

	iptables { "http-alt":
		proto => "tcp",
		dport => "8080",
		jump => "ACCEPT",
		}

	iptables { "port-8096":      ###### find out what this port does in cloudstack
		proto => "tcp",
		dport => "8096",
		jump => "ACCEPT",
		}

	iptables { "port-8250":     ############ Think this is for cpvm, but check for certain. 
		proto => "tcp",
		dport => "8250",
		jump => "ACCEPT",
		}

	iptables { "port-9090":    ####################### find out what this does in cloudstack
		proto => "tcp",
		dport => "9090",
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
		source => "puppet://puppet/cloudstack/my.cnf"
		notify => Service[mysqld],
	}

	exec {"cloud-setup-databases cloud:dbpassword@localhost --deploy-as=root":
		creates => "/var/lib/mysql/cloud",
		requires => Package[cloud-client],
		requires => Package[mysql-server],
	}

################## END MYSQL SECTION ###################################################################################################
		


}

class cloudstack::no_selinux {
	file { "/etc/selinux/config":
		source => "puppet://puppet/cloudstack/config",
	}
	exec { "/usr/sbin/setenforce 0":
		onlyif => "/usr/sbin/getenforce | grep Enforcing",
	}
}
