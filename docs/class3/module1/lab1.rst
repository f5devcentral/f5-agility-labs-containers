Using the F5 Router Plug-in
---------------------------

The F5 router plug-in is available starting in OpenShift Container Platform 3.0.2.
The F5 router plug-in is provided as a container image and run as a pod. Deploying the F5 router is done using the a config file saved on the OC-Master ''f5-hostsubnet.yaml'' to specify the following parameters for the F5 BIG-IP® host:

::
Flag	Description  --type=f5-router
Specifies that an F5 router should be launched (the default --type is haproxy-router).  --external-host
Specifies the F5 BIG-IP® host’s management interface’s host name or IP address.  --external-host-username
Specifies the F5 BIG-IP® user name (typically admin).  --external-host-password
Specifies the F5 BIG-IP® password.  --external-host-http-vserver
Specifies the name of the F5 virtual server for HTTP connections.  --external-host-https-vserver
Specifies the name of the F5 virtual server for HTTPS connections.  --external-host-private-key
Specifies the path to the SSH private key file for the F5 BIG-IP® host. Required to upload and delete key and certificate files for routes.  --external-host-insecure
::
A
 Boolean flag that indicates that the F5 router should skip strict certificate verification with the F5 BIG-IP® host.
As with the HAProxy router, the oadm router command creates the service and deployment configuration objects, and thus the replication controllers and pod(s) in which the F5 router itself runs. The replication controller restarts the F5 router in case of crashes. Because the F5 router is only watching routes and endpoints and configuring F5 BIG-IP® accordingly, running the F5 router in this way along with an appropriately configured F5 BIG-IP® deployment should satisfy high-availability requirements.



Review BIG-IP configuration
---------------------------




Create OSE Router Connector
---------------------------

Configuration steps done on the BIGIP
License BIG-IP
tmsh create net vlan internal interfaces add {1.2}
tmsh create net self 10.10.199.98/24 vlan internal
tmsh create net vlan external interfaces add {1.1}
tmsh create net self 10.10.201.98/24 vlan external
tmsh create auth partition kubernetes
tmsh create net tunnel vxlan ose-vxlan {app-service none flooding-type multipoint}
tmsh create net tunnel tunnel ose-tunnel {key 0 local-address 10.10.199.98 profile ose-vxlan}
tmsh save sys config


Configuration steps on ose-mstr01(steps 4 and 5 are done on the BIGIP)
oc login -u demouser
oc create -f f5-hostsubnet.yaml
oc get hostsubnet (This will return the IP space that can be used to setup a self on the ose-tunnel on the BIGIP)
tmsh create net self 10.131.0.98/14 vlan ose-vlan
tmsh save sys config
oc create -f f5-cc.yaml
oc create -f f5-vs2.yaml

Yaml files needed for OSE configuration
https://www.dropbox.com/s/jy7ed961l554g30/f5-vs2.yaml?dl=0
https://www.dropbox.com/s/sqb2pv2bbwbp2an/f5-hostsubnet.yaml?dl=0
https://www.dropbox.com/s/3mwmesf9lf206qq/f5-cc.yaml?dl=0

.. TODO:: Needs lab description

This lab will teach you how to download the |bip| |ve| image to your system.

Task – Open a Web Browser
~~~~~~~~~~~~~~~~~~~~~~~~~

.. TODO:: Needs task description

In this task you will open a web browser and navigate to the |f5| Downloads
site.

.. NOTE:: An account is required to download software.  You can create one at
   https://login.f5.com/resource/registerEmail.jsp

Follow these steps to complete this task:

#. Open your web browser
#. Navigate to https://downloads.f5.com
#. Login with your username and password.
#. After logging in you should see the following window:

   |image1|

Task – Download the Image
~~~~~~~~~~~~~~~~~~~~~~~~~

.. TODO:: Needs task description

In this task we will download the |f5| |bip| |ve| image to your system

Follow these steps to complete this task:

#. Click the 'Find a Download' button.

   .. image:: /_static/image002.png

#. Click the link that contains the |bip| TMOS software version you would like
   to download.

   .. IMPORTANT:: Be sure to click a link that has "\ |ve|" in the name

#. Find the image appropriate for your hypervisor
#. Download the image and save it to you local system

.. |image1| image:: /_static/image001.png
