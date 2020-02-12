Lab 1.1 - BIG-IP 1 & 2 Configuration
====================================

The purpose of this lab is not to cover BIG-IP High Availability (HA) in depth
but focus on OpenShift configuration with BIG-IP. Some prior BIG-IP HA
knowledge is required. Below is the initial configuration used on
each BIG-IP:

HA Config
---------

**bigip1**

.. code-block:: bash

   tmsh create net self external-self address 10.1.10.4/24 vlan external allow-service default
   tmsh create net self internal-self address 10.1.20.4/24 vlan internal allow-service default
   tmsh modify cm device bigip1 configsync-ip 10.1.20.4
   tmsh modify cm device bigip1 unicast-address {{ip 10.1.20.4} {ip management-ip}}
   tmsh modify cm device bigip1 mirror-ip 10.1.20.4
   tmsh modify cm trust-domain Root add-device { device-ip 10.1.1.5 device-name bigip2 username admin password admin ca-device true }
   tmsh create cm device-group device-group-common devices add { bigip1 bigip2 } type sync-failover auto-sync disabled
   tmsh run cm config-sync to-group device-group-common
   tmsh save sys config

**bigip2**

.. code-block:: bash

   tmsh create net self external-selfip address 10.1.10.5/24 vlan external allow-service default
   tmsh create net self internal-selfip address 10.1.20.5/24 vlan internal allow-service default
   tmsh modify cm device bigip2 configsync-ip 10.1.20.5
   tmsh modify cm device bigip2 unicast-address {{ip 10.1.20.5} {ip management-ip}}
   tmsh modify cm device bigip2 mirror-ip 10.1.20.5
   tmsh save sys config

.. attention:: If **bigip2** is the "Active" device be sure to force bigip2 to
   "Standby". We want **bigip1** to be "Active".

.. important:: Before adding the BIG-IP devices to OpenShift make sure your
   High Availability (HA) device trust group, license, selfIP, vlans are
   configured correctly.

VXLAN Config
------------

.. important:: Create all objects using the /Common partition unless otherwise
   directed.

**bigip1**

.. code-block:: bash

   tmsh create net self okd-float-10 address 10.1.10.60/24 vlan external traffic-group traffic-group-1 allow-service default
   tmsh create net self okd-float-20 address 10.1.10.61/24 vlan external traffic-group traffic-group-1 allow-service default
   tmsh create net tunnels vxlan okd-vxlan flooding-type multipoint
   tmsh run cm config-sync to-group device-group-common
   tmsh create net tunnels tunnel okd-tunnel-10 key 0 profile okd-vxlan local-address 10.1.10.60 secondary-address 10.1.10.4 traffic-group traffic-group-1
   tmsh create net tunnels tunnel okd-tunnel-20 key 1 profile okd-vxlan local-address 10.1.10.61 secondary-address 10.1.10.4 traffic-group traffic-group-1
   tmsh create net route-domain okd10 id 10 vlans replace-all-with { okd-tunnel-10 }
   tmsh create net route-domain okd20 id 20 vlans replace-all-with { okd-tunnel-20 }
   tmsh create auth partition okd10 default-route-domain 10
   tmsh create auth partition okd20 default-route-domain 20
   tmsh create net self okd-vxlan-selfip-10 address 10.131.0.1%10/14 vlan okd-tunnel-10 allow-service all
   tmsh create net self okd-vxlan-selfip-20 address 10.131.0.1%20/14 vlan okd-tunnel-20 allow-service all
   tmsh create net self okd-vxlan-float-10 address 10.131.4.1%10/14 vlan okd-tunnel-10 traffic-group traffic-group-1 allow-service all
   tmsh create net self okd-vxlan-float-20 address 10.131.4.1%20/14 vlan okd-tunnel-20 traffic-group traffic-group-1 allow-service all
   #Create the objects on "bigip2" below before syncing device group
   tmsh run cm config-sync to-group device-group-common

**bigip2**

.. code-block:: bash

   tmsh create net tunnels tunnel okd-tunnel-10 key 0 profile okd-vxlan local-address 10.1.10.60 secondary-address 10.1.10.5 traffic-group traffic-group-1
   tmsh create net tunnels tunnel okd-tunnel-20 key 1 profile okd-vxlan local-address 10.1.10.61 secondary-address 10.1.10.5 traffic-group traffic-group-1
   tmsh create net route-domain okd10 id 10 vlans replace-all-with { okd-tunnel-10 }
   tmsh create net route-domain okd20 id 20 vlans replace-all-with { okd-tunnel-20 }
   tmsh create net self okd-vxlan-selfip-10 address 10.131.2.1%10/14 vlan okd-tunnel-10 allow-service all
   tmsh create net self okd-vxlan-selfip-20 address 10.131.2.1%20/14 vlan okd-tunnel-20 allow-service all
