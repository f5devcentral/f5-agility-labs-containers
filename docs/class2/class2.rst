Class 2: OpenShift with F5 Container Ingress Service
====================================================

This introductory class covers the following topics:

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*

Expected time to complete: **1 hour**

Lab Setup
---------

We will leverage the following setup to configure the OpenShift environment.

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Credentials**
   * - superjump
     - 10.1.1.6
     - ubuntu/HelloUDF
   * - bigip1
     - 10.1.1.4
     - admin/admin
   * - okd-master1
     - 10.1.1.10
     - centos/centos

       root/default
   * - okd-node1
     - 10.1.1.11
     - centos/centos

       root/default
   * - okd-node2
     - 10.1.1.12
     - centos/centos

       root/default
