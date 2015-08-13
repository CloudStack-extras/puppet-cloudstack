# Defined resource type: cloudstack::zone
#
# This defined type is used to identify a CloudStack zone
#
# Parameters:
# zone_dns - The external DNS server
# zone_internal_dns - Internal DNS server
# networktype - Network type to use for zone.  Valid options are
#
# Actions:
#
# Requires:
#
#
# Sample Usage:
# cloudstack::zone { 'samplezone':
#   zone_dns => 'myinternaldns',
# }
#
define cloudstack::zone(
  $zone_dns='8.8.8.8',
  $zone_internal_dns='8.8.8.8',
  $networktype='Basic'
  ) {
    $teststring = inline_template( "<%= \"http://localhost:\" +
      \"${cloudstack::params::mgmt_port}/?command=listZones&\" +
      \"available=true\" %>" )
    $reststring = inline_template( "<%= \"http://localhost:\" +
      \"${cloudstack::params::mgmt_port}/?command=createZone&dns1\" +
      \"=${zone_internal_dns}&internaldns1=${zone_internal_dns}\" +
      \"&name=${name}&networktype=${networktype}\" %>" )

    exec { "/usr/bin/curl \'${reststring}\'":
      onlyif  => "/usr/bin/curl \'${teststring}\' | grep -v ${name}",
      require => Exec[ 'cloudstack_setup_databases' ],
    }
}
