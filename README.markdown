This is the CloudStack puppet manifest. 
The original location for this is: 
https://gitorious.org/cloudstack-puppet


To the extent that this manifest is copyrightable (and that is questionable, as configurations generally aren't) it is licensed under the GPLv3 or at your option any later version. 

For problems or help, please send messages on: 
https://lists.sourceforge.net/lists/listinfo/cloudstack-devel

Test Plan: 
So this should start from easiest submodules to most complex. 
So I am testing in this order: 

NFS server:
(Can I successfully add primary and secondary storage to an existing cloudstack instance)

Management Server: 
Do the packages get installed properly (repos setup?)
Once installed does database get provisioned
Once database provisioned does UI come up? 

Agent: 
Soooo much to test here.....basically does it work. 

