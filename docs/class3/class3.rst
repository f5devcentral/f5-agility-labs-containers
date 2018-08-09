Class 3: Introduction to Mesos / Marathon
=========================================

This introductory class covers the following topics:

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*
   setup/setup

Expected time to complete: **30 minutes**

Lab Setup
---------

We will leverage the following setup to configure the Mesos / Marathon environment.

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

      10.2.10.60

    - mgmt: 10.1.1.0/24

      external-mesos 10.2.10.0/24
    - admin/admin

      root/default
  * - f5-mesos-master1
    - 10.2.10.10
    - external-mesos: 10.2.10.0/24
    - admin/admin
    
      root/default
  * - f5-mesos-master2
    - 10.2.10.20
    - external-mesos: 10.2.10.0/24
    - admin/admin
    
      root/default
  * - f5-mesos-master3
    - 10.2.10.30
    - external-mesos: 10.2.10.0/24
    - admin/admin
    
      root/default
  * - f5-mesos-agent1
    - 10.2.10.40
    - external-mesos: 10.2.10.0/24
    - admin/admin
      
      root/default
  * - f5-mesos-agent2
    - 10.2.10.50
    - external-mesos: 10.2.10.0/24
    - admin/admin
    
      root/default

Here are a few things to know that could be useful (if you want to reproduce this in another environment)

* We used Ubuntu xenial (16.04) in this lab
* We updated the /etc/hosts file on all the nodes so that each node is reachable via its name.  You should see the following:

  .. code-block:: console
    
    user@master1:~$ cat /etc/hosts
    127.0.0.1     localhost
    10.2.10.10    f5-mesos-master1 f5-mesos-master1.agility-labs.io
    10.2.10.20    f5-mesos-master2 f5-mesos-master2.agility-labs.io
    10.2.10.30    f5-mesos-master3 f5-mesos-master3.agility-labs.io
    10.2.10.40    f5-mesos-agent1 f5-mesos-agent1.agility-labs.io
    10.2.10.50    f5-mesos-agent2 f5-mesos-agent2.agility-labs.io

* On f5-mesos-master1, we created some ssh keys for user that we copied on all the nodes. This way you can use f5-mesos-master1 to connect to all nodes without authentication.
* We enabled user to do sudo commands without authentication. This was done via the visudo command to specify that we allow passwordless sudo command for this user (here is a thread talking about how to do it: `visudo  <http://askubuntu.com/questions/504652/adding-nopasswd-in-etc-sudoers-doesnt-work/504666/>`_)
