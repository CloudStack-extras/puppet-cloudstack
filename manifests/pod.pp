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
define cloudstack::pod(
  $gateway,
  $netmask,
  $startip,
  $endip,
  $zoneid
  ) {
    $teststring_zone = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=listZones&\" +
                   \"available=true\" %>" )
    $teststring_pod = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=listPods&\" +
                   \"available=true\" %>" )
    $reststring = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=createPod&\" +
                   \"gateway=${gateway}&name=${name}&netmask=${netmask}&\" +
                   \"startip=${startip}&endip=${endip}&zoneid=${zoneid}\" %>" )

    exec { "/usr/bin/curl \'${reststring}\'":
      unless  => [
        "/usr/bin/curl \'${teststring_zone}\' | grep ${zoneid}",
        "/usr/bin/curl \'${teststring_pod}\' | grep -v ${pod}",
      ],
      require => Exec[ 'cloudstack_setup_databases' ],
    }
}
