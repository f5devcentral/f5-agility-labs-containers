Section 2.1 Working with BIG-IP HA pairs or device groups
--------------------------------------------------------

Each Container Connector is uniquely suited to its specific container orchestration environment and purpose, utilizing the architecture and language appropriate for the environment. Application Developers interact with the platform’s API; the CCs watch the API for certain events, then act accordingly.

The Container Connector is stateless. The inputs are:

* the container orchestration environment’s config,
* the BIG-IP device config, and
* the CC config (provided via the appropriate means for the container orchestration environment).

This means an instance of a Container Connector can be readily discarded. Migrating a CC is as easy as destroying it in one place and spinning up a new one somewhere else. Wherever a Container Connector runs, it always watches the API and attempts to bring the BIG-IP up-to-date with the latest applicable configurations.

Working with BIG-IP HA pairs or device groups
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use the F5 Container Connectors to manage a BIG-IP HA active-standby pair or device group. The deployment details vary depending on the platform. For most, the basic principle is the same: You should run one BIG-IP Controller instance for each BIG-IP device. You will deploy two BIG-IP Controller instances - one for each BIG-IP device. To help ensure Controller HA, you will deploy each Controller instance on a separate Node in the cluster.

what host subnests are created on OpenShift:

.. code-block:: console

     [root@ose-mstr01 ~]# oc get hostsubnets
     NAME                  HOST                  HOST IP         SUBNET          EGRESS IPS
     ose-mstr01.f5.local   ose-mstr01.f5.local   10.10.199.100   10.130.0.0/23   []
     ose-node01            ose-node01            10.10.199.101   10.128.0.0/23   []
     ose-node02            ose-node02            10.10.199.102   10.129.0.0/23   []
     [root@ose-mstr01 ~]#

.. image:: /_static/class5/ha-cluster.jpg

BIG-IP config sync
~~~~~~~~~~~~~~~~~~

**Important**

Each Container Connector monitors the BIG-IP partition it manages for configuration changes. If it discovers changes, the Connector reapplies its own configuration to the BIG-IP. F5 does not recommend making configuration changes to objects in any partition managed by a BIG-IP Controller via any other means (for example, the configuration utility, TMOS, or by syncing configuration from another device or service group). Doing so may result in disruption of service or unexpected behavior. 

The Container Connector for OpenShift uses FDB entries and ARP records to identify the Cluster resources associated with BIG-IP Nodes. Because BIG-IP config sync doesn’t include FDB entries or ARP records, F5 does not recommend using automatic configuration sync when managing a BIG-IP HA pair or cluster with the BIG-IP Controller. You must diable config sync when using tunnels.