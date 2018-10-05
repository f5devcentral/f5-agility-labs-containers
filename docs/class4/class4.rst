Class 4: Introduction to RedHat OpenShift
=========================================

This introductory class covers the following topics:

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*

Expected time to complete: **30 minutes**

.. attention:: **MODULE 1: BUILD AN OPENSHIFT CLUSTER CAN BE SKIPPED. THE
   BLUEPRINT IS PRE-CONFIGURED WITH A WORKING CLUSTER. THIS MODULE IS FOR
   DOCUMENTION PURPOSES ONLY.**

Lab Setup
---------

We will leverage the following setup to configure the OpenShift environment.

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
