Module 1: Build an Openshift Cluster
====================================

.. attention:: **THIS MODULE CAN BE SKIPPED. THE BLUEPRINT IS PRE-CONFIGURED
   WITH A WORKING CLUSTER. THIS MODULE IS FOR DOCUMENTION PURPOSES ONLY.**

In this module, we will build a 3 node cluster (1x master and 2x nodes) 
utilizing CentOS server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - ose-master1
     - 10.3.10.21
     - Master
   * - ose-node1
     - 10.3.10.22
     - Node
   * - ose-node2
     - 10.3.10.23
     - Node

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
