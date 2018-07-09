Class 1: Docker
===============

The purpose of this lab is to give you more visibility on

* Overview of Docker and its key components
* How to install Docker on Ubuntu
* How to launch application on Docker

.. toctree::
   :maxdepth: 1
   :caption: Contents:
   :glob:

   module*/module*

Lab Setup
---------

Here is the setup we will leverage to work on the Kubernetes environment.

In the existing environment, here is the setup you're working within:

.. list-table::
  :header-rows: 1

  * - **Hostname**
    - **IP-ADDR**
    - **VLAN**
    - **Credentials**
  * - jumphost
    - 10.1.1.250
    - mgmt: 10.1.1.0/24
    - user/Student!Agility!
  * - bigip1
    - 10.1.1.245

      10.1.10.60

    - mgmt: 10.1.1.0/24

      external-kube 10.1.10.0/24

    - GUI: admin/admin

      SSH: root/default
  * - kube-master1
    - 10.1.10.11
    - external-kube: 10.10.199.0/24
    - SSH: root/default
  * - kube-node1
    - 10.1.10.21
    - external-kube: 10.10.199.0/24
    - SSH: root/default
  * - kube-node2
    - 10.1.10.22
    - external-kube: 10.10.199.0/24
    - SSH: root/default
