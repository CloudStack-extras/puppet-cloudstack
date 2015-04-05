class cloudstack::no_selinux {
	file { '/etc/selinux/config':
		source => 'puppet://puppet/cloudstack/config',
	}
	exec { '/usr/sbin/setenforce 0':
		onlyif => '/usr/sbin/getenforce | grep Enforcing',
	}
}
