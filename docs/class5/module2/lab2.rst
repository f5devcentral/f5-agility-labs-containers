Section 2.1 Working with BIG-IP HA pairs or device groups
--------------------------------------------------------

Each Container Connector is uniquely suited to its specific container orchestration environment and purpose, utilizing the architecture and language appropriate for the environment. Application Developers interact with the platform’s API; the CCs watch the API for certain events, then act accordingly.

The Container Connector is stateless. The inputs are:

* the container orchestration environment’s config,
* the BIG-IP device config, and
* the CC config (provided via the appropriate means for the container orchestration environment).

This means an instance of a Container Connector can be readily discarded. Migrating a CC is as easy as destroying it in one place and spinning up a new one somewhere else. Wherever a Container Connector runs, it always watches the API and attempts to bring the BIG-IP up-to-date with the latest applicable configurations.

Managing BIG-IP HA Clusters in OpenShift
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use the F5 Container Connectors to manage a BIG-IP HA active-standby pair or device group. The deployment details vary depending on the platform. For most, the basic principle is the same: You should run one BIG-IP Controller instance for each BIG-IP device. You will deploy two BIG-IP Controller instances - one for each BIG-IP device. To help ensure Controller HA, you will deploy each Controller instance on a separate Node in the cluster.

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

   2.    add bigip devices openshift ha

         openshift create hostsubnets ha
         openshift upload hostsubnets ha
         openshift verify hostsubnets ha

   3.    openshift vxlan setup ha

         openshift create vxlan profile ha
         openshift create vxlan tunnel ha
         openshift vxlan selfIP ha
         openshift vxlan floatingip ha

   4.    openshift deploy kctlr ha

         openshift rbac ha
         openshift create deployment ha
         openshift upload deployment ha

   ===== ==================================================================================

.. _openshift initial bigip setup ha:

**Step 1:** Openshift initial bigip setup ha

The purpose of this lab is not to cover BIG-IP High Availability (HA) in depth but focus on OpenShift configuration with BIG-IP. Some prior BIG-IP HA knowledge is required. We have created the BIG-IPs base configuration for bigip01 and bigip02 to save time. Below is the initial configuration used on each BIG-IP:

**bigip01.f5.local**

.. code-block:: console

     tmsh modify sys global-settings hostname bigip01.f5.local
     && tmsh modify sys global-settings mgmt-dhcp disabled
     && tmsh create sys management-ip 10.10.200.98/24
     && tmsh create sys management-route 10.10.200.1
     && tmsh create net vlan external interfaces add {1.1}
     && tmsh create net vlan internal interfaces add {1.2}
     && tmsh create net vlan ha interfaces add {1.3}
     && tmsh create net self 10.10.199.98/24 vlan internal
     && tmsh create net self 10.10.201.98/24 vlan external
     && tmsh create net self 10.10.202.98/24 vlan ha allow-service default
     && tmsh create net route default gw 10.10.201.1
     tmsh mv cm device bigip1 bigip01.f5.local
     && tmsh modify cm device bigip01.f5.local configsync-ip 10.10.202.98
     && tmsh modify cm device bigip01.f5.local unicast-address {{ip 10.10.202.98} {ip management-ip}}
     tmsh modify cm trust-domain ca-devices add {10.10.200.99} username admin password admin
     tmsh create cm device-group ocp-devicegroup devices add {bigip01.f5.local bigip02.f5.local} type sync-failover auto-sync disabled
     tmsh run cm config-sync to-group ocp-devicegroup
     tmsh save sys config

**bigip02.f5.local**

. code-block:: console

     tmsh modify sys global-settings hostname bigip02.f5.local
     && tmsh modify sys global-settings mgmt-dhcp disabled
     && tmsh create sys management-ip 10.10.200.99/24
     && tmsh create sys management-route 10.10.200.1
     && tmsh create net vlan external interfaces add {1.1}
     && tmsh create net vlan internal interfaces add {1.2}
     && tmsh create net vlan ha interfaces add {1.3}
     && tmsh create net self 10.10.199.99/24 vlan internal
     && tmsh create net self 10.10.201.99/24 vlan external
     && tmsh create net self 10.10.202.99/24 vlan ha allow-service default
     && tmsh create net route default gw 10.10.201.1
     && tmsh modify sys global-settings gui-setup disabled
     tmsh mv cm device bigip1 bigip02.f5.local
     tmsh modify cm device bigip02.f5.local configsync-ip 10.10.202.99
     tmsh modify cm device bigip02.f5.local unicast-address {{ip 10.10.202.99} {ip management-ip}}
     tmsh save sys config

Before adding the BIG-IP devices to OpenShift make sure your High Availability (HA) device trust group is configured correctly

Initial BIG-IP Device Setup
---------------------------

.. include:: /_static/reuse/bigip-admin-permissions-reqd.rst

.. include:: /_static/reuse/kctlr-initial-setup.rst

.. _add bigip devices openshift ha:

The diagram below displays the BIG-IP deployment with the OpenShift cluster in High Availability (HA) active-standby pair or device group. Note this solution applies to BIG-IP devices v13.x and later only. To accomplish High Availability (HA) active-standby pair or device group with OpenShift the BIG-IP needs to create a floating vxlan tunnel address with is currently only available in BIG-IP 13.x and later.

.. _openshift initial bigip setup ha:

what host subnests are created on OpenShift:

.. code-block:: console

     [root@ose-mstr01 ~]# oc get hostsubnets
     NAME                  HOST                  HOST IP         SUBNET          EGRESS IPS
     ose-mstr01.f5.local   ose-mstr01.f5.local   10.10.199.100   10.130.0.0/23   []
     ose-node01            ose-node01            10.10.199.101   10.128.0.0/23   []
     ose-node02            ose-node02            10.10.199.102   10.129.0.0/23   []
     [root@ose-mstr01 ~]#

.. image:: /_static/class5/ha-cluster.jpg

The BIG-IP OpenShift Controller cannot manage objects in the /Common partition. Its recommended to create all HA using the /Common partition.
