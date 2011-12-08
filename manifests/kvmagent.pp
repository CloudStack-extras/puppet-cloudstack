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

  package { 'NetworkManager': 
    ensure => absent;
  }

  service { 'network': 
    ensure => running,
    enabled => true, 
    hasstatus => true,
    requires => Package[ 'cloud-agent' ],
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

################## Firewall stuff #########################
#

  firewall { "first range":
    proto => 'tcp',
    dport => '49152-49216',
    jump => 'ACCEPT',
  }

  firewall { " 191 VNC rules": 
    proto => 'tcp',
    dport => '5900-6100',
    jump => 'ACCEPT',
  } 

  firewall { " 192 port 16509":
    proto => 'tcp',
    dport => '16509',
    jump => 'accept',
  }


 
############ Need to do something that will take care of KVM - make sure module is loaded - need to define what tests cloud-setup-agent actually runs to test for KVM and ensure that we do those tests as well, and rectify if needed (do a reboot?? )
### Need to handle hostname addition as well - and probably a def gw and ensuring that DNS is set since


### Require network to be enable
### Require NetworkManager be disabled (Is it installed by default, do we need to do a case?, perhaps we 'ensure absent') 
### Make sure we cycle network after deploying a ifcfg. 
### Do we handle creation of cloud-br0? I am thinking not, seems like there's a lot of magic there. For now, lets stay away from that. 

}
