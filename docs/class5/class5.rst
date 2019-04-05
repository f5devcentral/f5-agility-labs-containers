Class 5: Advanced Red Hat OpenShift
===================================

The purpose of this lab is to give you more visibility on

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*
   appendix*/appendix*

Expected time to complete: **3 hours**

Lab Setup
---------

In the environment, there is a three-node OpenShift cluster with one master
and two nodes. There is a pair of BIG-IPs setup in an HA configuration:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Credentials**
   * - jumpbox
     - 10.1.1.250
     - user/Student!Agility!
   * - bigip1
     - 10.1.1.245

       10.3.10.60

     - admin/admin

       root/default
   * - bigip1
     - 10.1.1.246

       10.3.10.61

     - admin/admin

       root/default
   * - ose-master1
     - 10.3.10.21
     - centos/centos

       root/default
   * - ose-node1
     - 10.3.10.22
     - centos/centos

       root/default
   * - ose-node2
     - 10.3.10.23
     - centos/centos

       root/default
