Module 2: Build a Kubernetes Cluster
====================================

In this module, we will build a 3 node cluster (1x master and 2x nodes) 
utilizing Ubuntu server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - kube-master
     - 10.1.10.21
     - Master
   * - kube-node1
     - 10.1.10.22
     - node
   * - kube-node2
     - 10.1.10.23
     - node

.. toctree::
   :maxdepth: 1
   :glob:

   lab*