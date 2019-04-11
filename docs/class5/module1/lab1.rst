Lab 1.1 - Initial BIG-IP HA Setup
=================================

.. important:: Each Container Connector monitors the BIG-IP partition it
   manages for configuration changes. If its configuration changes, the
   Connector re-applies its own configuration to the BIG-IP. F5 does not
   recommend making configuration changes to objects in any partition managed
   by a F5 Container Connector via any other means (for example, the
   configuration utility, TMOS, or by syncing configuration from another
   device or service group). Doing so may result in disruption of service or
   unexpected behavior. 

   The Container Connector for OpenShift uses FDB entries and ARP records to
   identify the Cluster resources associated with BIG-IP Nodes. Because BIG-IP
   config sync doesn’t include FDB entries or ARP records, F5 does not
   recommend using automatic configuration sync when managing a BIG-IP HA pair
   or cluster with the F5 Container Connector. You must disable config sync
   when using tunnels.

The purpose of this lab is not to cover BIG-IP High Availability (HA) in depth
but focus on OpenShift configuration with BIG-IP. Some prior BIG-IP HA
knowledge is required. We have created the BIG-IPs base configuration for
bigip1 and bigip2 to save time. Below is the initial configuration used on
each BIG-IP:

.. attention:: The following is provided for informational purposes. You do
   **NOT** need to run these commands for the lab.

**bigip1.agility-labs.io**

.. code-block:: bash

   tmsh modify sys global-settings hostname bigip1.agility-labs.io
   tmsh modify sys global-settings mgmt-dhcp disabled
   tmsh create sys management-ip 10.1.1.245/24
   tmsh create sys management-route 10.1.1.1
   tmsh create net vlan external-ose interfaces add {1.3}
   tmsh create net vlan ha interfaces add {1.4}
   tmsh create net self ose-selfip address 10.3.10.60/24 vlan external-ose allow-service default
   tmsh create net self ha-selfip address 192.168.1.1/24 vlan ha allow-service all
   tmsh mv cm device bigip1 bigip1.agility-labs.io
   tmsh modify cm device bigip1.agility-labs.io configsync-ip 192.168.1.1
   tmsh modify cm device bigip1.agility-labs.io unicast-address {{ip 192.168.1.1} {ip management-ip}}
   tmsh modify cm device bigip1.agility-labs.io mirror-ip 192.168.1.1
   tmsh modify cm trust-domain Root add-device { device-ip 10.1.1.246 device-name bigip2.agility-labs.io username admin password admin ca-device true }
   tmsh create cm device-group device-group-ose devices add { bigip1.agility-labs.io bigip2.agility-labs.io } type sync-failover auto-sync disabled
   tmsh run cm config-sync to-group device-group-ose
   tmsh save sys config

**bigip2.agility-labs.io**

.. code-block:: bash

   tmsh modify sys global-settings hostname bigip2.agility-labs.io
   tmsh modify sys global-settings mgmt-dhcp disabled
   tmsh create sys management-ip 10.1.1.246/24
   tmsh create sys management-route 10.1.1.1
   tmsh create net vlan external-ose interfaces add {1.3}
   tmsh create net vlan ha interfaces add {1.4}
   tmsh create net self ose-selfip address 10.3.10.61/24 vlan external-ose allow-service default
   tmsh create net self ha-selfip address 192.168.1.2/24 vlan ha allow-service all
   tmsh modify sys global-settings gui-setup disabled
   tmsh mv cm device bigip1 bigip2.agility-labs.io
   tmsh modify cm device bigip2.agility-labs.io configsync-ip 192.168.1.2
   tmsh modify cm device bigip2.agility-labs.io unicast-address {{ip 192.168.1.2} {ip management-ip}}
   tmsh modify cm device bigip2.agility-labs.io mirror-ip 192.168.1.2
   tmsh save sys config

.. attention:: If **bigip2** is the "Active" device be sure to force bigip2 to
   "Standby". We want **bigip1** to be "Active".

.. important:: Before adding the BIG-IP devices to OpenShift make sure your High
   Availability (HA) device trust group, license, selfIP, vlans are configured
   correctly.

.. note:: You have shortcuts to connect to your BIG-IPs in Chrome. Login:
   **admin**, Password: **admin**

#. Validate that SDN services license is active

   .. attention:: In your lab environment the BIG-IP VE LAB license includes
      the SDN license. The following is provided as a reference of what you may
      see in a production license. The SDN license is also included in the
      `-V16` version of the BIG-IP VE license.

   .. image:: images/license.png

#. Validate the vlan configuration on both **bigip1** & **bigip2**

   .. image:: images/vlans.png

#. Validate **bigip1** self IP configuration

   .. image:: images/self-ip-bigip01.png

#. Validate **bigip2** self IP configuration

   .. image:: images/self-ip-bigip02.png

#. Validate the device group HA settings and make sure bigip1 and bigip2 are in
   sync. If out of sync, sync the device group:

   .. image:: images/device-group-sync.png

   All synced.
   
   .. note:: The sync-failover configuration is set to manual sync

   .. image:: images/synced.png