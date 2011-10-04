class cloudstack {
  include cloudstack::params

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

  file { "/etc/hosts":
    content => template("cloudstack/hosts"),
  }

  package {wget: ensure => present}   ### Not needed after 2.2.9, see bug 11258

  file { "/etc/selinux/config":
    source => "puppet://puppet/cloudstack/config",
  }
  exec { "/usr/sbin/setenforce 0":
    onlyif => "/usr/sbin/getenforce | grep Enforcing",
  }
}
