Class 1: Kubernetes with F5 Container Ingress Service
=====================================================

This introductory class covers the following topics:

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*

Expected time to complete: **1 hour**

Lab Setup
---------

We will leverage the following setup to configure the Kubernetes environment.

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Credentials**
   * - superjump
     - 10.1.1.6
     - ubuntu/ubuntu
   * - bigip1
     - 10.1.1.4
     - admin/F5site02@
   * - kube-master1
     - 10.1.1.11
     - ubuntu/ubuntu

       root/default
   * - kube-node1
     - 10.1.1.12
     - ubuntu/ubuntu

       root/default
   * - kube-node2
     - 10.1.1.13
     - ubuntu/ubuntu

       root/default
