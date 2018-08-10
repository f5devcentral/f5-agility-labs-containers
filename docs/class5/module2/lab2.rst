Module 2: Working with BIG-IP HA Pairs or Device Groups
=======================================================

Each Container Connector is uniquely suited to its specific container orchestration environment and purpose, utilizing the architecture and language appropriate for the environment. Application Developers interact with the platform’s API; the CCs watch the API for certain events, then act accordingly.

The Container Connector is stateless. The inputs are:

* the container orchestration environment’s config
* the BIG-IP device config
* the CC config (provided via the appropriate means for the container orchestration environment).

Wherever a Container Connector runs, it always watches the API and attempts to bring the BIG-IP up-to-date with the latest applicable configurations.

Managing BIG-IP HA Clusters in OpenShift
----------------------------------------

You can use the F5 Container Connectors to manage a BIG-IP HA active-standby pair or device group. The deployment details vary depending on the platform. For most, the basic principle is the same: You should run one BIG-IP Controller instance for each BIG-IP device. You will deploy two BIG-IP Controller instances - one for each BIG-IP device. To help ensure Controller HA, you will deploy each Controller instance on a separate Node in the cluster.

.. image:: /_static/class5/ha-cluster.jpg
    :align: center

BIG-IP Config Sync
------------------

**Important**

Each Container Connector monitors the BIG-IP partition it manages for configuration changes. If it discovers changes, the Connector reapplies its own configuration to the BIG-IP. F5 does not recommend making configuration changes to objects in any partition managed by a BIG-IP Controller via any other means (for example, the configuration utility, TMOS, or by syncing configuration from another device or service group). Doing so may result in disruption of service or unexpected behavior. 

The Container Connector for OpenShift uses FDB entries and ARP records to identify the Cluster resources associated with BIG-IP Nodes. Because BIG-IP config sync doesn’t include FDB entries or ARP records, F5 does not recommend using automatic configuration sync when managing a BIG-IP HA pair or cluster with the BIG-IP Controller. You must diable config sync when using tunnels.

Complete the steps below to set up the solution shown in the diagram. Be sure to use the correct IP addresses and subnet masks for your OpenShift Cluster

.. table:: Tasks

   ===== =====================================================================
   Step  Task
   ===== =====================================================================
   1.    :ref:`initial bigip ha setup`

   2.    :ref:`add bigip devices to openshift`

         * openshift create hostsubnets ha
         * openshift upload hostsubnets ha
         * openshift verify hostsubnets ha

   3.    :ref:`openshift vxlan setup ha`

         * creating OCP partition create
         * ocp-profile create 
         * openshift create vxlan profile ha
         * penshift create vxlan tunnel ha
         * openshift vxlan selfIP ha
         * openshift vxlan floatingip ha

   4.    :ref:`openshift deploy kctlr ha`

         * openshift rbac ha
         * openshift create deployment ha
         * openshift upload deployment ha
   ===== =====================================================================

.. _initial bigip ha setup:

Initial BIG-IP HA Setup
-----------------------

**Step 1:**

The purpose of this lab is not to cover BIG-IP High Availability (HA) in depth but focus on OpenShift configuration with BIG-IP. Some prior BIG-IP HA knowledge is required. We have created the BIG-IPs base configuration for bigip01 and bigip02 to save time. Below is the initial configuration used on each BIG-IP:

.. note:: The following is provided for informational purposes.  You do not need to run these commands for the lab.

**bigip01.f5.local**

.. code-block:: console

     tmsh modify sys global-settings hostname bigip01.f5.local
     tmsh modify sys global-settings mgmt-dhcp disabled
     tmsh create sys management-ip 10.10.200.98/24
     tmsh create sys management-route 10.10.200.1
     tmsh create net vlan external interfaces add {1.1}
     tmsh create net vlan internal interfaces add {1.2}
     tmsh create net vlan ha interfaces add {1.3}
     tmsh create net self 10.10.199.98/24 vlan internal
     tmsh create net self 10.10.201.98/24 vlan external
     tmsh create net self 10.10.202.98/24 vlan ha allow-service default
     tmsh create net route default gw 10.10.201.1
     tmsh mv cm device bigip1 bigip01.f5.local
     tmsh modify cm device bigip01.f5.local configsync-ip 10.10.202.98
     tmsh modify cm device bigip01.f5.local unicast-address {{ip 10.10.202.98} {ip management-ip}}
     tmsh modify cm trust-domain ca-devices add {10.10.200.99} username admin password admin
     tmsh create cm device-group ocp-devicegroup devices add {bigip01.f5.local bigip02.f5.local} type sync-failover auto-sync disabled
     tmsh run cm config-sync to-group ocp-devicegroup
     tmsh save sys config

**bigip02.f5.local**

.. code-block:: console

     tmsh modify sys global-settings hostname bigip02.f5.local
     tmsh modify sys global-settings mgmt-dhcp disabled
     tmsh create sys management-ip 10.10.200.99/24
     tmsh create sys management-route 10.10.200.1
     tmsh create net vlan external interfaces add {1.1}
     tmsh create net vlan internal interfaces add {1.2}
     tmsh create net vlan ha interfaces add {1.3}
     tmsh create net self 10.10.199.99/24 vlan internal
     tmsh create net self 10.10.201.99/24 vlan external
     tmsh create net self 10.10.202.99/24 vlan ha allow-service default
     tmsh create net route default gw 10.10.201.1
     tmsh modify sys global-settings gui-setup disabled
     tmsh mv cm device bigip1 bigip02.f5.local
     tmsh modify cm device bigip02.f5.local configsync-ip 10.10.202.99
     tmsh modify cm device bigip02.f5.local unicast-address {{ip 10.10.202.99} {ip management-ip}}
     tmsh save sys config

Before adding the BIG-IP devices to OpenShift make sure your High Availability (HA) device trust group, license, selfIP, vlans are configured correctly

Validate that SDN services license is active

.. note:: In your lab environment the BIG-IP VE LAB license includes the SDN license.  The following is provided as a reference of what you may see in a production license.  The SDN license is also included in the -V16 version of the BIG-IP VE license.


.. image:: /_static/class5/license.png
    :align: center

Validate the vlan configuration

.. image:: /_static/class5/vlans.png
    :align: center

Validate bigip01 self IP configuration

.. image:: /_static/class5/self-ip-bigip01.png
    :align: center

Validate bigip02 self IP configuration

.. image:: /_static/class5/self-ip-bigip02.png
    :align: center

Validate the device group HA settings and make sure bigip01 and bigip02 are in sync. If out of sync, sync the bigip

.. image:: /_static/class5/device-group-sync.png
    :align: center

All synced. Note the sync-failover configuration is set to manual sync

.. image:: /_static/class5/synced.png
    :align: center

The diagram below displays the BIG-IP deployment with the OpenShift cluster in High Availability (HA) active-standby pair or device group. Note this solution applies to BIG-IP devices v13.x and later only. To accomplish High Availability (HA) active-standby pair or device group with OpenShift the BIG-IP needs to create a floating vxlan tunnel address with is currently only available in BIG-IP 13.x and later.

.. _add bigip devices to openshift:

Upload the HostSubnet Files to the OpenShift API Server
-------------------------------------------------------

**Step 2:** Create a new OpenShift HostSubnet

HostSubnets must use valid YAML. You can upload the files individually using separate oc create commands. Create one HostSubnet for each BIG-IP device. These will handle health monitor traffic. Also create one HostSubnet to pass client traffic. You will create the floating IP address for the active device in this subnet as shown in the diagram above. 

.. attention:: We have created the YAML files to save time. The files are located at **/root/agility2018/ocp**

    cd /root/agility2018/ocp

Define HostSubnets
------------------

hs-bigip01.yaml

.. literalinclude:: ../../../openshift/advanced/ocp/hs-bigip01.yaml
  :language: yaml
  :emphasize-lines: 3,4,9

hs-bigip02.yaml

.. literalinclude:: ../../../openshift/advanced/ocp/hs-bigip02.yaml
  :language: yaml
  :emphasize-lines: 3,4,9

hs-bigip-float.yaml

.. literalinclude:: ../../../openshift/advanced/ocp/hs-bigip-float.yaml
  :language: yaml
  :emphasize-lines: 3,4,9

Create the HostSubnet files to the OpenShift API server

.. code-block:: console

     oc create -f hs-bigip01.yaml
     oc create -f hs-bigip02.yaml
     oc create -f hs-bigip-float.yaml

Verify creation of the HostSubnets:

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get hostsubnet
     NAME                       HOST                       HOST IP         SUBNET          EGRESS IPS
     openshift-f5-bigip-float   openshift-f5-bigip-float   10.10.199.200   10.131.4.0/23   []
     openshift-f5-bigip01       openshift-f5-bigip01       10.10.199.98    10.131.0.0/23   []
     openshift-f5-bigip02       openshift-f5-bigip02       10.10.199.99    10.131.2.0/23   []
     ose-mstr01.f5.local        ose-mstr01.f5.local        10.10.199.100   10.130.0.0/23   []
     ose-node01                 ose-node01                 10.10.199.101   10.128.0.0/23   []
     ose-node02                 ose-node02                 10.10.199.102   10.129.0.0/23   []
    [root@ose-mstr01 ocp]#

.. _openshift vxlan setup ha:

Set up VXLAN on the BIG-IP Devices
----------------------------------

**Step 3.1:** Create a new partition on your BIG-IP system

.. important:: The BIG-IP OpenShift Controller cannot manage objects in the /Common partition. 

    Its recommended to create all HA using the /Common partition

.. note:: You can copy and paste the following commands to be run directly from the OpenShift master (ose-mstr01).  To paste content into mRemoteNG; use your right mouse button.

* ssh root@10.10.200.98 tmsh create auth partition ocp
* ssh root@10.10.200.99 tmsh create auth partition ocp

**Step 3.2:** Creating ocp-profile

* ssh root@10.10.200.98 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint
* ssh root@10.10.200.99 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint

**Step 3.3:** Creating floating IP for underlay network

* ssh root@10.10.200.98 tmsh create net self 10.10.199.200/24 vlan internal traffic-group traffic-group-1
* ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

**Step 3.4:** Creating vxlan tunnel ocp-tunnel

* ssh root@10.10.200.98 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.98 traffic-group traffic-group-1
* ssh root@10.10.200.99 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.99 traffic-group traffic-group-1

**Step 3.5:** Creating overlay self-ip

* ssh root@10.10.200.98 tmsh create net self 10.131.0.98/14 vlan ocp-tunnel
* ssh root@10.10.200.99 tmsh create net self 10.131.2.99/14 vlan ocp-tunnel

**Step 3.6:** Creating floating IP for overlay network

* ssh root@10.10.200.98 tmsh create net self 10.131.4.200/14 vlan ocp-tunnel traffic-group traffic-group-1
* ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

**Step 3.7:** Saving configuration

* ssh root@10.10.200.98 tmsh save sys config
* ssh root@10.10.200.99 tmsh save sys config

Before adding the BIG-IP controller to OpenShift validate the partition and tunnel configuration

Validate that the OCP bigip partition was created

.. image:: /_static/class5/partition.png
    :align: center

Validate bigip01 self IP configuration

Note: On the active device, there is floating IP address in the subnet assigned by the OpenShift SDN.

.. image:: /_static/class5/self-ip-bigip01-ha.png
    :align: center

Validate bigip02 self IP configuration

.. image:: /_static/class5/self-ip-bigip02-ha.png
    :align: center

Check the ocp-tunnel configuration (under Network -> Tunnels). Note the local-address 10.10.199.200 and secondary-address are  10.10.199.98 for bigip01 and 10.10.199.99 for bigip02.  The secondary-address will be used to send monitor traffic and the local address will be used by the active device to send client traffic.

.. image:: /_static/class5/bigip01-tunnel-ip.png
    :align: center

.. _openshift deploy kctlr ha:

Deploy the BIG-IP Controller
----------------------------

Take the steps below to deploy a contoller for each BIG-IP device in the cluster.

Set up RBAC
-----------

The F5 BIG-IP Controller requires permission to monitor the status of the OpenSfhift cluster.  The following will create a "role" that will allow it to access specific resources.

You can create RBAC resources in the project in which you will run your BIG-IP Controller. Each Controller that manages a device in a cluster or active-standby pair can use the same Service Account, Cluster Role, and Cluster Role Binding.

**Step 4.1:** Create a Service Account for the BIG-IP Controller

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create serviceaccount bigip-ctlr -n kube-system
     serviceaccount "bigip-ctlr" created

**Step 4.2:** Create a Cluster Role and Cluster Role Binding with the required permissions.

The following file has already being created **f5-kctlr-openshift-clusterrole.yaml** which is located in /root/agility2018/ocp

.. literalinclude:: ../../../openshift/advanced/ocp/f5-kctlr-openshift-clusterrole.yaml
  :language: yaml
  :linenos:
  :emphasize-lines: 3,23

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f f5-kctlr-openshift-clusterrole.yaml
     clusterrole "system:bigip-ctlr" created
     clusterrolebinding "bigip-ctlr-role" created

Create Deployments
------------------

**Step 4.3:** Deploy the BIG-IP Controller

Create an OpenShift Deployment for each Controller (one per BIG-IP device). You need to deploy a controller for both f5-bigip-node01 and f5-bigip-node02

* Provide a unique metadata.name for each Controller.
* Provide a unique --bigip-url in each Deployment (each Controller manages a separate BIG-IP device).
* Use the same --bigip-partition in all Deployments.

bigip01-cc.yaml

.. literalinclude:: ../../../openshift/advanced/ocp/bigip01-cc.yaml
  :language: yaml
  :linenos:
  :emphasize-lines: 2,4,17,21-23

bigip02-cc.yaml

.. literalinclude:: ../../../openshift/advanced/ocp/bigip02-cc.yaml
  :language: yaml
  :linenos:
  :emphasize-lines: 2,4,17,21-23

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f  bigip01-cc.yaml
     deployment "bigip01-ctlr" created
     [root@ose-mstr01 ocp]# oc create -f  bigip02-cc.yaml
     deployment "bigip02-ctlr" created

**Step 4.4:** Verify Pod creation

Verify the deployment and pods that are created

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get deployment
     NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
     bigip01-ctlr   1         1         1            1           42s
     bigip02-ctlr   1         1         1            1           36s

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get deployment bigip01-ctlr
     NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
     bigip01-ctlr   1         1         1            1           1m

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get pods
     NAME                           READY     STATUS    RESTARTS   AGE
     bigip01-ctlr-242733768-dbwdm   1/1       Running   0          1m
     bigip02-ctlr-66171581-q87kb    1/1       Running   0          1m
     [root@ose-mstr01 ocp]#

You can also use the web conole in OpenShift to view the bigip controller. Go the kube-system project

.. image:: /_static/class5/kube-system.png
    :align: center

Upload the Deployments
----------------------

**Step 4.5:** Upload the Deployments to the OpenShift API server. Use the pool-only configmap to configuration project namespace: f5demo on the bigip

pool-only.yaml

.. literalinclude:: ../../../openshift/advanced/ocp/pool-only.yaml
  :language: yaml
  :linenos:
  :emphasize-lines: 1,11,14,34

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f pool-only.yaml
     configmap "k8s.poolonly" created
     [root@ose-mstr01 ocp]#

**Step 4.5:** Check bigip01 and bigip02 to make sure the pool got created (make sure you are looking at the "ocp" partition). Validate that both bigip01 and bigip02 can reach the pool members. Pool members should show green

.. image:: /_static/class5/pool-members.png
    :align: center

**Step 4.6:** Increase the replication of the f5demo project pods

.. code-block:: console

       [root@ose-mstr01 ocp]# oc scale --replicas=10 deployment/f5demo -n f5demo
       deployment "f5demo" scaled
       [root@ose-mstr01 ocp]#

.. image:: /_static/class5/10-containers.png
    :align: center

Validate that bigip01 and bigip02 are updated with the additional pool members and they health monitor works. If the monitor is failing check the tunnel and selfIP.

Validation and Troubleshooting
------------------------------

Now that you have HA configured and uploaded the deployment its time to generate traffic through bigip. 

**Step 5.1:** Create a virtual IP address for the deployment

Add a virtual IP to the the configmap. You can edit the pool-only.yaml configmap. There are multuple ways to edit the configmap which will be covered in module 3. In this task remove the deployment, edit the yaml file and re-apply the deployment

.. code-block:: console

     [root@ose-mstr01 ocp]# oc delete -f pool-only.yaml
     configmap "k8s.poolonly" deleted
     [root@ose-mstr01 ocp]#
  
.. code-block:: console

Edit the pool-only.yaml and add the bindAddr 

vi pool-only.yaml

.. code-block:: console

     "frontend": {
          "virtualAddress": {
            "port": 80,
            "bindAddr": "10.10.201.220"

.. tip:: Don't forget the "," at the end of the ""port": 80," line.

Create the modified pool-only deployment

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f pool-only.yaml
     configmap "k8s.poolonly" created
     [root@ose-mstr01 ocp]#

Connect to the virtual server at http://10.10.201.220. Does the connection work If not, try the following troubleshooting options:

  1) Capture the http request to see if the connection is established with the bigip
  2) Follow the following network troubleshooting section

Network Troubleshooting
-----------------------

How do I verify connectivity between the BIG-IP VTEP and the OSE Node?
``````````````````````````````````````````````````````````````````````

#. Ping the Node's VTEP IP address.

   Use the ``-s`` flag to set the MTU of the packets to allow for VxLAN encapsulation.

   .. code-block:: console

      [root@bigip01:Standby:Changes Pending] config # ping -s 1600 -c 4 10.10.199.101
      PING 10.10.199.101 (10.10.199.101) 1600(1628) bytes of data.
      1608 bytes from 10.10.199.101: icmp_seq=1 ttl=64 time=2.94 ms
      1608 bytes from 10.10.199.101: icmp_seq=2 ttl=64 time=2.21 ms
      1608 bytes from 10.10.199.101: icmp_seq=3 ttl=64 time=2.48 ms
      1608 bytes from 10.10.199.101: icmp_seq=4 ttl=64 time=2.47 ms
      
      --- 10.10.199.101 ping statistics ---
      4 packets transmitted, 4 received, 0% packet loss, time 3006ms
      rtt min/avg/max/mdev = 2.210/2.527/2.946/0.267 ms

#. Ping the Pod's IP address (use the output from looking at the pool members in the previous steps).

   Use the ``-s`` flag to set the MTU of the packets to allow for VxLAN encapsulation.

   .. code-block:: console

      [root@bigip01:Standby:Changes Pending] config # ping -s 1600 -c 4 10.128.0.54
      PING 10.128.0.54 (10.128.0.54) 1600(1628) bytes of data.
      
      --- 10.128.0.54 ping statistics ---
      4 packets transmitted, 0 received, 100% packet loss, time 12999ms
      
   Now change the MTU

   .. code-block:: console

      [root@bigip01:Standby:Changes Pending] config # ping -s 1400 -c 4 10.128.0.54
      PING 10.128.0.54 (10.128.0.54) 1400(1428) bytes of data.
      1408 bytes from 10.128.0.54: icmp_seq=1 ttl=64 time=1.74 ms
      1408 bytes from 10.128.0.54: icmp_seq=2 ttl=64 time=2.43 ms
      1408 bytes from 10.128.0.54: icmp_seq=3 ttl=64 time=2.77 ms
      1408 bytes from 10.128.0.54: icmp_seq=4 ttl=64 time=2.25 ms
      
      --- 10.128.0.54 ping statistics ---
      4 packets transmitted, 4 received, 0% packet loss, time 3005ms
      rtt min/avg/max/mdev = 1.748/2.303/2.774/0.372 ms
      
   .. note:: When pinging the VTEP IP directly the BIG-IP was L2 adjacent to the device and could send a large MTU.  In the second example the packet is dropped across the VxLAN tunnel.  In the third example the packet is able to traverse the VxLAN tunnel.

#. In a TMOS shell, output the REST requests from the BIG-IP logs.

   - Do a ``tcpdump`` of the underlay network.
      
    Example showing two-way communication between the BIG-IP VTEP IP and the OSE node VTEP IPs. 
      
    Example showing traffic on the overlay network; at minimum, you should see BIG-IP health monitors for the Pod IP addresses.

   .. code-block:: console

      [root@bigip01:Standby:Changes Pending] config # tcpdump -i ocp-tunnel -c 10 -nnn
      tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
      listening on ocp-tunnel, link-type EN10MB (Ethernet), capture size 65535 bytes
      09:05:55.962408 IP 10.131.0.98.53404 > 10.128.0.54.8080: Flags [S], seq 1597206142, win 29200, options [mss 1460,sackOK,TS val 441031289 ecr 0,nop,wscale 7], length 0 out slot1/tmm0 lis=
      09:05:55.963532 IP 10.128.0.54.8080 > 10.131.0.98.53404: Flags [S.], seq 1644640677, ack 1597206143, win 27960, options [mss 1410,sackOK,TS val 3681001 ecr 441031289,nop,wscale 7], length 0 in slot1/tmm1 lis=
      09:05:55.964361 IP 10.131.0.98.53404 > 10.128.0.54.8080: Flags [.], ack 1, win 229, options [nop,nop,TS val 441031291 ecr 3681001], length 0 out slot1/tmm0 lis=
      09:05:55.964367 IP 10.131.0.98.53404 > 10.128.0.54.8080: Flags [P.], seq 1:10, ack 1, win 229, options [nop,nop,TS val 441031291 ecr 3681001], length 9: HTTP: GET / out slot1/tmm0 lis=
      09:05:55.965630 IP 10.128.0.54.8080 > 10.131.0.98.53404: Flags [.], ack 10, win 219, options [nop,nop,TS val 3681003 ecr 441031291], length 0 in slot1/tmm1 lis=
      09:05:55.975754 IP 10.128.0.54.8080 > 10.131.0.98.53404: Flags [P.], seq 1:1337, ack 10, win 219, options [nop,nop,TS val 3681013 ecr 441031291], length 1336: HTTP: HTTP/1.1 200 OK in slot1/tmm1 lis=
      09:05:55.975997 IP 10.128.0.54.8080 > 10.131.0.98.53404: Flags [F.], seq 1337, ack 10, win 219, options [nop,nop,TS val 3681013 ecr 441031291], length 0 in slot1/tmm1 lis=
      09:05:55.976108 IP 10.131.0.98.53404 > 10.128.0.54.8080: Flags [.], ack 1337, win 251, options [nop,nop,TS val 441031302 ecr 3681013], length 0 out slot1/tmm0 lis=
      09:05:55.976114 IP 10.131.0.98.53404 > 10.128.0.54.8080: Flags [F.], seq 10, ack 1337, win 251, options [nop,nop,TS val 441031303 ecr 3681013], length 0 out slot1/tmm0 lis=
      09:05:55.976488 IP 10.131.0.98.53404 > 10.128.0.54.8080: Flags [.], ack 1338, win 251, options [nop,nop,TS val 441031303 ecr 3681013], length 0 out slot1/tmm0 lis=
      10 packets captured
      10 packets received by filter
      0 packets dropped by kernel

#. In a TMOS shell, view the MAC address entries for the OSE tunnel. This will show the mac address and IP addresses of all of the OpenShift endpoints.

   .. code-block:: console

      root@(bigip02)(cfg-sync In Sync)(Active)(/Common)(tmos)# show /net fdb tunnel ocp-tunnel

      ----------------------------------------------------------------
      Net::FDB
      Tunnel      Mac Address        Member                    Dynamic
      ----------------------------------------------------------------
      ocp-tunnel  0a:0a:0a:0a:c7:64  endpoint:10.10.199.100%0  no
      ocp-tunnel  0a:0a:0a:0a:c7:65  endpoint:10.10.199.101%0  no
      ocp-tunnel  0a:0a:0a:0a:c7:66  endpoint:10.10.199.102%0  no
      ocp-tunnel  0a:58:0a:80:00:60  endpoint:10.10.199.101    yes

#. In a TMOS shell, view the ARP entries.

   .. note:: run the command "tmsh"  if you do not see "(tmos)" in your shell.

   This will show all of the ARP entries; you should see the VTEP entries on the :code:`ocpvlan` and the Pod IP addresses on :code:`ose-tunnel`.

   .. code-block:: console

      root@(bigip02)(cfg-sync In Sync)(Active)(/Common)(tmos)# show /net arp

      --------------------------------------------------------------------------------------------
      Net::Arp
      Name           Address        HWaddress          Vlan                Expire-in-sec  Status
      --------------------------------------------------------------------------------------------
      10.10.199.100  10.10.199.100  2c:c2:60:49:b2:9d  /Common/internal    41             resolved
      10.10.199.101  10.10.199.101  2c:c2:60:58:62:64  /Common/internal    70             resolved
      10.10.199.102  10.10.199.102  2c:c2:60:51:65:a0  /Common/internal    41             resolved
      10.10.202.98   10.10.202.98   2c:c2:60:1f:74:62  /Common/ha          64             resolved
      10.128.0.96    10.128.0.96    0a:58:0a:80:00:60  /Common/ocp-tunnel  7              resolved

      root@(bigip02)(cfg-sync In Sync)(Active)(/Common)(tmos)#

#. Validate floating traffic for ocp-tunnel self-ip

   Check if the configuration is correct from step 3.6. Make sure the floating IP is set to traffic-group-1 floating. A floating traffic group is request for the response traffic from the pool-member. If the traffic is local change to floating

   .. image:: /_static/class5/non-floating.png
      :align: center

   change to floating

   .. image:: /_static/class5/floating.png
      :align: center

   Connect to the viutal IP address

   .. image:: /_static/class5/success.png
      :align: center

#. Test failover and make sure you can connect to the virtual. 

**Congraulation** for completeing the HA clusterting setup. Before moving to the next module cleanup the deployed resource:

.. code-block:: console

    [root@ose-mstr01 ocp]# oc delete -f pool-only.yaml
    configmap "k8s.poolonly" created
    [root@ose-mstr01 ocp]#
