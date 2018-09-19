Build a Mesos / Marathon Cluster
================================

.. important:: This section is a step by step resource to build a Mesos /
   Marathon Cluster from scratch.  Our lab is pre-built, therefor this is only
   for documentation purposes.

In this module, we will build a 5 node cluster (3x masters and 2x nodes)
utilizing Ubuntu server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - f5-mesos-master1
     - 10.2.10.10
     - Master
   * - f5-mesos-master2
     - 10.2.10.20
     - Master
   * - f5-mesos-master3
     - 10.2.10.30
     - Master
   * - f5-mesos-agent1
     - 10.2.10.40
     - Slave
   * - f5-mesos-agent2
     - 10.2.10.50
     - Slave

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
