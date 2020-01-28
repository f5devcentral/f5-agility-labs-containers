Appendix 1: Build a Kubernetes Cluster
======================================

.. attention:: **THE CLASS BLUEPRINT IS PRE-CONFIGURED WITH A WORKING CLUSTER.
   THIS APPENDIX IS FOR DOCUMENTION PURPOSES ONLY.**

In this module, we will build a 3 node cluster (1x master and 2x nodes) 
utilizing Ubuntu server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - kube-master1
     - 10.1.1.7
     - Master
   * - kube-node1
     - 10.1.1.8
     - Node
   * - kube-node2
     - 10.1.1.9
     - Node

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
