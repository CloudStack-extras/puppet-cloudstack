# Defined resource type: cloudstack::zone
#
# This defined type is used to identify a CloudStack zone
#
# Parameters:
#
# Actions:
#
# Requires:
#
#
# Sample Usage:
# This class should not be included directly.  It is called from other modules.
#
define cloudstack::zone( 
  $zone_dns='8.8.8.8', 
  $zone_internal_dns='8.8.8.8', 
  networktype='Basic'
  ) {
    $reststring = "\'http://localhost:${cloudstack::params::mgmt_port}/?command\
                   =createZone&dns1=${zone_internal_dns}&internaldns1=\
                   ${zone_internal_dns}&name=${name}&networktype=\
                   ${networktype}\'"
    notify { $reststring: }
    exec { "curl ${reststring}":
      onlyif => "curl \'http://localhost:${cloudstack::params::mgmt_port}/?\
                 command=listZones&available=true\' | grep -v ${name}",
    } 
}