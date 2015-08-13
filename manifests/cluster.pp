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
define cloudstack::cluster(
  $zoneid,
  $podid,
  $clustertype = 'CloudManaged',
  $hypervisor = $hvtype,
  ) {
    #### NEED TO VERIFY THAT ZONEID AND PODID ARE VALID!
    $teststring_zone = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=listZones&\" +
                   \"available=true\" %>" )
    $teststring_pod = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=listPods&\" +
                   \"available=true\" %>" )
    $teststring_cluster = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=listClusters&\" +
                   \"available=true\" %>" )
    $reststring = inline_template( "<%= \"http://localhost:\" +
                   \"${cloudstack::params::mgmt_port}/?command=addCluster&\" +
                   \"clustername=${name}&clustertype=${clustertype}&\" +
                   \"hypervisor=${hypervisor}&zoneid=${zoneid}&\" +
                   \"podid=${podid}\" %>" )

    exec { "/usr/bin/curl \'${reststring}\'":
      onlyif  => [
        "/usr/bin/curl \'${teststring_zone}\' | grep ${zoneid}",
        "/usr/bin/curl \'${teststring_pod}\' | grep ${podid}",
        "/usr/bin/curl \'${teststring_cluster}\' | grep -v ${cluster}"
      ],
      require => Exec[ 'cloudstack_setup_databases' ],
    }
}
