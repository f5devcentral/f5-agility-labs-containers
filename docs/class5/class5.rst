Class 5: Advanced Labs for Red Hat OpenShift Container Platform (OCP)
=====================================================================

The purpose of this lab is to give you more visibility on

.. toctree::
  :maxdepth: 1
  :glob:

  module*/*

Expected time to complete: **3 hours**

Lab Setup
---------

In the environment, there is a three-node OpenShift cluster with one master and two nodes. There is a pair of BIG-IPs setup in an HA configuration:

.. list-table::
  :header-rows: 1

  * - **Hostname**
    - **Mgt-IP**
    - **Login / Password**
  * - jumpbox
    - 10.10.200.199
    - user/Student!Agility!
  * - bigip01
    - 10.10.200.98
    - admin/admin

      root/default
  * - bigip02
    - 10.10.200.99
    - admin/admin

      root/default
  * - ose-mstr01
    - 10.10.199.100
    - root/default
  * - ose-node01
    - 10.10.199.101
    - root/default
  * - ose-node02
    - 10.10.199.102
    - root/default
