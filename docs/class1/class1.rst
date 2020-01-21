Class 1: Introduction to CIS & Kubernetes
=========================================

This introductory class covers the following topics:

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*
   appendix*/appendix*

Expected time to complete: **1 hour**

Lab Setup
---------

We will leverage the following setup to configure the Kubernetes environment.

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

       10.1.10.60

     - admin/admin

       root/default
   * - kube-master1
     - 10.1.10.21
     - ubuntu/ubuntu

       root/default
   * - kube-node1
     - 10.1.10.22
     - ubuntu/ubuntu

       root/default
   * - kube-node2
     - 10.1.10.23
     - ubuntu/ubuntu

       root/default
