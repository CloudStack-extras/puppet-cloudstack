class cloudstack::mgmt {
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

	package {cloud-client : ensure => present, require => Yumrepo[CloudStack], }


########## Requires the iptables module from: 

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
################## END MYSQL SECTION ###################################################################################################
		


}

class cloudstack::no_selinux {
	file { "/etc/selinux/config":
		source => "puppet://puppet/files/selinux/config",
	}
	exec { "/usr/sbin/setenforce 0":
		onlyif => "/usr/sbin/getenforce | grep Enforcing",
	}
}
