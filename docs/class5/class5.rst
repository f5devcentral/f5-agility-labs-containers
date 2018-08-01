Class 5: Advanced Labs for Red Hat OpenShift Container Platform (OCP)
======================================================================

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
  * - Windows Jumpbox
    - 10.10.200.199
    - student/Student!Agility!
  * - BIG-IP
    - 10.10.200.98
    - GUI: admin/admin

      SSH: root/default
  * - ose-master
    - 10.10.199.100
    - ssh: root/default
  * - ose-node01
    - 10.10.199.101
    - ssh: root/default
  * - ose-node02
    - 10.10.199.102
    - ssh: root/default
