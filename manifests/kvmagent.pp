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

  package { 'cloud-agent': 
    ensure  => present, 
    require => Yumrepo[ 'cloudstack' ], 
  }

  exec { '/usr/bin/cloud-setup-agent':
    creates  => '/var/log/cloud/setupAgent.log',
    require => [ 
      Package[   'cloud-agent'                               ],
      File[      '/etc/cloud/agent/agent.properties'         ],
      File_line[ 'cs_sudo_rule'                              ],
      Host[      'localhost'                                 ],
    ],
  }


  file { '/etc/cloud/agent/agent.properties': 
    ensure  => present,
    require => Package[ 'cloud-agent' ],
    content => template( 'cloudstack/agent.properties' ),
  }


 
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
