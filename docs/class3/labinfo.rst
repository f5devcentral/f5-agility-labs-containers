Lab Setup
~~~~~~~~~

Here is the setup we will leverage to work on the RedHat OpenShift environment.

In the existing environment, here is the setup you're working within:

==================   ==================  =============================
    Hostname              Mgt IP            Login / Password
==================   ==================  =============================
    Master 1              10.10.199.100     ssh: root/default
    Agent  1              10.10.199.101     ssh: root/default
    Agent  2              10.10.199.102     ssh: root/default
 Windows Jumpbox          10.10.200.199     student/Student!Agility!
    BIG-IP                10.10.200.98      GUI: admin/admin
    BIG-IP                10.10.200.98      ssh: root/admin
==================   ==================  =============================

In case you don't use the Ravello BluePrint, here are a few things to know
that could be useful (if you want to reproduce this in another environment)

Here are the different things to take into accounts during this installation
guide:

* We are using RHEL in this blueprint
* We updated on all the nodes the /etc/hosts file so that each node is reachable via its name

  Example of our hosts file:

  .. code-block:: console

     [root@ose-node01 ~]# cat /etc/hosts
     127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
     10.10.199.100 ose-mstr01 ose-mstr01.f5.local
     10.10.199.101 ose-node01 ose-node01.f5.local
     10.10.199.102 ose-node02 ose-node02.f5.local

* On ose-mstr01, we created some ssh keys for user that we copied on all the
  nodes. This way you can use ose-mstr01 as needed to connect to all nodes without
  authentication if wanting to jump around using ssh i.e. ssh root@10.10.199.101 from ose-mstr01
