include cloudstack::mgmt

cloudstack::zone { 'zone1': } ->

cloudstack::pod { 'pod1':
  gateway => '192.168.203.1',
  netmask => '255.255.255.0',
  startip => '192.168.203.200',
  endip   => '192.168.203.230',
  zoneid  => '1',
}

cloudstack::cluster { 'cluster1':
  clustertype => 'CloudManaged',
  hypervisor  => $hvtype,
  zoneid      => '1',
  podid       => '1',
}
