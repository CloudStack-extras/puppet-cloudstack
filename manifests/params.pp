# Class:: cloudstack::params
#
#
class cloudstack::params {
  $mgmt_port = '8096'
  $cs_mgmt_server = '192.168.203.177'
  $cs_agent_netmask = '255.255.255.0'
  $cs_sec_storage_nfs_server = '192.168.203.177'
  $cs_sec_storage_mnt_point = '/secondary'
  $pri_storage_nfs_server = '192.168.203.177'
  $pri_storage_mnt_point = '/primary'
  $hvtype = 'KVM'
  $system_tmplt_dl_cmd = '/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt'
  $sysvm_url_kvm = 'http://cloudstack.apt-get.eu/systemvm/4.5/systemvm64template-4.5-kvm.qcow2.bz2'
  $sysvm_url_xen = 'http://cloudstack.apt-get.eu/systemvm/4.5/systemvm64template-4.5-xen.vhd.bz2'
} # Class:: cloudstack::params
