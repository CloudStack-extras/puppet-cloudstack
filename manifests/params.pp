# Class:: cloudstack::params
#
#
class cloudstack::params {

  $mgmt_port = '8096'
  $cs_mgmt_server = "192.168.203.177"
  $cs_agent_netmask = "255.255.255.0"
  $cs_sec_storage_nfs_server = "192.168.203.176"
        $cs_sec_storage_mnt_point = "/secondary"
  $pri_storage_nfs_server = "192.168.203.176"
  $pri_storage_mnt_point = "/primary"
  $hvtype = "KVM"
  $system_tmplt_dl_cmd = "/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt"
  $sysvm_url_kvm = "http://download.cloud.com/releases/2.2.0/systemvm.qcow2.bz2"
  $sysvm_url_xen = "http://download.cloud.com/releases/2.2.0/systemvm.vhd.bz2"


} # Class:: cloudstack::params
