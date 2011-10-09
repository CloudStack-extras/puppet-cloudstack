# Class: cloudstack::kvmagent
#
# This class installs the base CloudStack KVM agent
#
# Parameters:
#
# Actions:
# Install base cloudstack agent
# Install Package['cloud-agent']
# Run script Exec['cloud-setup-agent']
#
# Requires:
#
# Sample Usage:
#
class cloudstack::kvmagent {
  include cloudstack 
  package {cloud-agent : ensure => present, require => Yumrepo[CloudStack], }

  exec { "cloud-setup-agent":
    creates => "/var/log/cloud/setupAgent.log",
    requires => [ Package[cloud-agent],
      Package[NetworkManager],
      File["/etc/sudoers"],
      File["/etc/cloud/agent/agent.properties"]
      File["/etc/sysconfig/network-scripts/ifcfg-eth0"],
      File["/etc/hosts"],
      File["/etc/sysconfig/network"],
      File["/etc/resolv.conf"],
      Service["network"],
    ]
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
