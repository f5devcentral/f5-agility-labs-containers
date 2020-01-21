Appendix 1: Build an Openshift Cluster
======================================

.. attention:: **THE CLASS BLUEPRINT IS PRE-CONFIGURED WITH A WORKING CLUSTER.
   THIS APPENDIX IS FOR DOCUMENTION PURPOSES ONLY.**

In this module, we will build a 3 node cluster (1x master and 2x nodes) 
utilizing CentOS server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - okd-master1
     - 10.1.1.10
     - Master
   * - okd-node1
     - 10.1.1.11
     - Node
   * - okd-node2
     - 10.1.1.12
     - Node

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
