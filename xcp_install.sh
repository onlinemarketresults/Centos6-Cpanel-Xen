##Based on http://grantmcwilliams.com/item/563-centos6-on-xcp

##This line gets the Network UUID for xenbr0.
##If you're using a different bridge you will want to insert it here.
##Get a list of XCP networks with xe network-list
##This network is connected to the outside interface.
##This tutorial requires there to be a DHCP server on this network
##answering requests and providing network access to the Internet.
NETUUID=$(xe network-list bridge=xenbr0 --minimal)
##Here we create the VM from the RHEL6 template, create a network interface and add it to our network from step one. Additional settings are for configuring the install repository and specifying the kickstart file from my site. The last setting turns off VNC so we can watch the install via a text console (very important in my environment).  Even if you can't see all the text below just highlight and paste. The text is there even if it's not visible.
##
TMPLUUID=$(xe template-list | grep -B1 'name-label.*Red Hat.* 6.*64-bit' | awk -F: '/uuid/{print $2}'| tr -d " ")
VMUUID=$(xe vm-install new-name-label="CentOS6-cPanel" template=${TMPLUUID})
xe vif-create vm-uuid=$VMUUID network-uuid=$NETUUID mac=random device=0
xe vm-param-set uuid=$VMUUID other-config:install-repository=http://mirror.centos.org/centos/6/os/x86_64
xe vm-param-set uuid=$VMUUID PV-args="ks=https://github.com/onlinemarketresults/Centos6-Cpanel-Xen/raw/master/cpanel-config/cpanel-ks.cfg ksdevice=eth0"
#Disable VNC for headless environment we can monitor via text console
xe vm-param-set uuid=${VMUUID} other-config:disable_pv_vnc=1

##Start the VM and monitor install
xe vm-start uuid=$VMUUID
DOMID=$(xe vm-list uuid=${VMUUID} params=dom-id --minimal)
/usr/lib/xen/bin/xenconsole ${DOMID}
#After it installs, it will shutdown

##Start VM and configure settings
xe vm-start uuid=$VMUUID
DOMID=$(xe vm-list uuid=${VMUUID} params=dom-id --minimal)
/usr/lib/xen/bin/xenconsole ${DOMID}
#User/pass = root/bogus

##TODO: change root password
##TODO: change network settings to static IP using system-config-network
##TODO: rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt rpm -ivh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
