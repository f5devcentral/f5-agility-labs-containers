Section 2.1 Working with BIG-IP HA pairs or device groups
--------------------------------------------------------

Each Container Connector is uniquely suited to its specific container orchestration environment and purpose, utilizing the architecture and language appropriate for the environment. Application Developers interact with the platform’s API; the CCs watch the API for certain events, then act accordingly.

The Container Connector is stateless. The inputs are:

* the container orchestration environment’s config
* the BIG-IP device config
* the CC config (provided via the appropriate means for the container orchestration environment).

Wherever a Container Connector runs, it always watches the API and attempts to bring the BIG-IP up-to-date with the latest applicable configurations.

Managing BIG-IP HA Clusters in OpenShift
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use the F5 Container Connectors to manage a BIG-IP HA active-standby pair or device group. The deployment details vary depending on the platform. For most, the basic principle is the same: You should run one BIG-IP Controller instance for each BIG-IP device. You will deploy two BIG-IP Controller instances - one for each BIG-IP device. To help ensure Controller HA, you will deploy each Controller instance on a separate Node in the cluster.

.. image:: /_static/class5/ha-cluster.jpg

BIG-IP config sync
~~~~~~~~~~~~~~~~~~

**Important**

Each Container Connector monitors the BIG-IP partition it manages for configuration changes. If it discovers changes, the Connector reapplies its own configuration to the BIG-IP. F5 does not recommend making configuration changes to objects in any partition managed by a BIG-IP Controller via any other means (for example, the configuration utility, TMOS, or by syncing configuration from another device or service group). Doing so may result in disruption of service or unexpected behavior. 

The Container Connector for OpenShift uses FDB entries and ARP records to identify the Cluster resources associated with BIG-IP Nodes. Because BIG-IP config sync doesn’t include FDB entries or ARP records, F5 does not recommend using automatic configuration sync when managing a BIG-IP HA pair or cluster with the BIG-IP Controller. You must diable config sync when using tunnels.

Complete the steps below to set up the solution shown in the diagram. Be sure to use the correct IP addresses and subnet masks for your OpenShift Cluster

. table:: Tasks

   ===== ==================================================================================
   Step  Task
   ===== ==================================================================================
   1.    :ref:`openshift initial bigip setup ha`

   2.    :ref:`add bigip devices openshift ha`

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

   ===== ==================================================================================

.. _openshift initial bigip setup ha:

**Step 1:** Openshift initial bigip setup ha

The purpose of this lab is not to cover BIG-IP High Availability (HA) in depth but focus on OpenShift configuration with BIG-IP. Some prior BIG-IP HA knowledge is required. We have created the BIG-IPs base configuration for bigip01 and bigip02 to save time. Below is the initial configuration used on each BIG-IP:

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

.. image:: /_static/class5/license.png

Validate the vlan configuration

.. image:: /_static/class5/vlans.png

Validate bigip01 self IP configuration

.. image:: /_static/class5/self-ip-bigip01.png

Validate bigip02 self IP configuration

.. image:: /_static/class5/self-ip-bigip02.png

Validate the device group HA settings and make sure bigip01 and bigip02 are in sync. If out of sync, sync the bigip

.. image:: /_static/class5/device-group-sync.png

All synced. Note the sync-failover configuration is set to manual sync

.. image:: /_static/class5/synced.png

The diagram below displays the BIG-IP deployment with the OpenShift cluster in High Availability (HA) active-standby pair or device group. Note this solution applies to BIG-IP devices v13.x and later only. To accomplish High Availability (HA) active-standby pair or device group with OpenShift the BIG-IP needs to create a floating vxlan tunnel address with is currently only available in BIG-IP 13.x and later.

.. _openshift upload hostsubnets ha:

Upload the HostSubnet files to the OpenShift API server
```````````````````````````````````````````````````````

**Step 2:** Create a new OpenShift HostSubnet

HostSubnets must use valid YAML. You can upload the files individually using separate oc create commands. Create one HostSubnet for each BIG-IP device. These will handle health monitor traffic. Also create one HostSubnet to pass client traffic. You will create the floating IP address for the active device in this subnet as shown in the diagram above. We have create the YAML files to save time. The files are located at **/root/agility2018/ocp**

Define HostSubnets
``````````````````

hs-bigip01.yaml

.. code-block:: console

     {
        "apiVersion": "v1",
        "host": "openshift-f5-bigip01",
        "hostIP": "10.10.199.98",
        "kind": "HostSubnet",
        "metadata": {
            "name": "openshift-f5-bigip01"
        },
        "subnet": "10.131.0.0/23"
    }

hs-bigip02.yaml

.. code-block:: console

     {
        "apiVersion": "v1",
        "host": "openshift-f5-bigip02",
        "hostIP": "10.10.199.99",
        "kind": "HostSubnet",
        "metadata": {
            "name": "openshift-f5-bigip02"
        },
        "subnet": "10.131.2.0/23"
    }

hs-bigip-float.yaml

.. code-block:: console

     {
        "apiVersion": "v1",
        "host": "openshift-f5-bigip-float",
        "hostIP": "10.10.199.200",
        "kind": "HostSubnet",
        "metadata": {
            "name": "openshift-f5-bigip-float"
        },
        "subnet": "10.131.4.0/23"
    }

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

Set up the VXLAN on the BIG-IP devices
--------------------------------------

**Step 3.1: ****Create a new partition on your BIG-IP system**

The BIG-IP OpenShift Controller cannot manage objects in the /Common partition. Its recommended to create all HA using the /Common partition

* ssh root@10.10.200.98 tmsh create auth partition ocp
* ssh root@10.10.200.99 tmsh create auth partition ocp

**Step 3.2: **Creating ocp-profile**

* ssh root@10.10.200.98 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint
* ssh root@10.10.200.99 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint

**Step 3.3: **Creating floating IP for underlay network**

* ssh root@10.10.200.98 tmsh create net self 10.10.199.200/24 vlan internal traffic-group traffic-group-1
* ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

***Step 3.4: *Creating vxlan tunnel ocp-tunnel**

* ssh root@10.10.200.98 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.98 traffic-group traffic-group-1
* ssh root@10.10.200.99 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.99 traffic-group traffic-group-1

**Step 3.5: **Creating overlay self-ip**

* ssh root@10.10.200.98 tmsh create net self 10.131.0.98/14 vlan ocp-tunnel
* ssh root@10.10.200.99 tmsh create net self 10.131.2.99/14 vlan ocp-tunnel

***Step 3.6: *Creating floating IP for overlay network**

* ssh root@10.10.200.98 tmsh create net self 10.131.4.200/14 vlan ocp-tunnel
* ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

**Step 3.7: **Saving configuration**

* ssh root@10.10.200.98 tmsh save sys config
* ssh root@10.10.200.99 tmsh save sys config

Before adding the BIG-IP contrller to OpenShift validate the partition and tunnel configuration

Validate that the OCP bigip partition was created

.. image:: /_static/class5/partition.png

Validate bigip01 self IP configuration

Note: On the active device, there is floating IP address in the subnet assigned by the OpenShift SDN.

.. image:: /_static/class5/self-ip-bibip01-ha.png

Validate bigip02 self IP configuration

.. image:: /_static/class5/self-ip-bibip02-ha.png

Check the ocp-tunnel configuration. Note the local-address 10.10.199.200 and secondary-address are  10.10.199.98 for bigip01 and 10.10.199.99 for bigip02

.. image:: /_static/class5/bigip01-tunnelip.png

.. _openshift deploy kctlr ha: