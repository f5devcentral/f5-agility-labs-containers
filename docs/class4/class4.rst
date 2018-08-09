Class 4: Introduction to RedHat OpenShift
=========================================

This introductory class covers the following topics:

.. toctree::
  :maxdepth: 1
  :glob:

  module*/module*

Expected time to complete: **30 minutes**

Lab Setup
---------

We will leverage the following setup to configure the OpenShift environment.

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

      10.10.199.60

    - mgmt: 10.1.1.0/24

      external-ose 10.10.199.0/24
    - admin/admin

      root/default
  * - ose-mstr01
    - 10.10.199.100
    - external-ose: 10.10.199.0/24
    - root/default
  * - ose-node01
    - 10.10.199.101
    - external-ose: 10.10.199.0/24
    - root/default
  * - ose-node02
    - 10.10.199.102
    - external-ose: 10.10.199.0/24
    - root/default

In case you don't use the Ravello BluePrint, here are a few things to know
that could be useful (if you want to reproduce this in another environment)

Here are the different things to take into account during this installation
guide:

* We are using RHEL in this blueprint
* We updated on all the nodes the /etc/hosts file so that each node is reachable via its name

  Example of our hosts file:

  .. code-block:: console

    [root@ose-node01 ~]# cat /etc/hosts
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
    10.10.199.100 ose-mstr01 ose-mstr01.f5.local
    10.10.199.101 ose-node01 ose-node01.f5.local
    10.10.199.102 ose-node02 ose-node02.f5.local

* On ose-mstr01, we created some ssh keys for user that we copied on all the nodes. This way you can use ose-mstr01 as needed to connect to all nodes without authentication if wanting to jump around using ssh i.e. ssh root@10.10.199.101 from ose-mstr01
