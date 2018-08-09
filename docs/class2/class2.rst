Class 2: Introduction to Kubernetes
===================================

This introductory class covers the following topics:

.. toctree::
  :maxdepth: 1
  :glob:

  module*/module*
  appendix

Expected time to complete: **1 hours**

Lab Setup
---------

We will leverage the following setup to configure the Kubernetes environment.

.. list-table::
  :header-rows: 1

  * - **Hostname**
    - **IP-ADDR**
    - **VLAN**
    - **Credentials**
  * - jumpbox
    - 10.1.1.250
    - mgmt: 10.1.1.0/24
    - user/Student!Agility!
  * - bigip1
    - 10.1.1.245

      10.1.10.60

    - mgmt: 10.1.1.0/24

      external-kube 10.1.10.0/24

    - admin/admin

      root/default
  * - kube-master1
    - 10.1.10.21
    - external-kube: 10.1.10.0/24
    - ubuntu/ubuntu

      root/default
  * - kube-node1
    - 10.1.10.22
    - external-kube: 10.1.10.0/24
    - ubuntu/ubuntu

      root/default
  * - kube-node2
    - 10.1.10.23
    - external-kube: 10.1.10.0/24
    - ubuntu/ubuntu

      root/default
