Class 3: Introduction to Mesos / Marathon
=========================================

This introductory class covers the following topics:

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*

Expected time to complete: **1 hours**

Lab Setup
---------

We will leverage the following setup to configure the Mesos / Marathon
environment.

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
   * - mesos-master1
     - 10.2.10.21
     - external-mesos: 10.2.10.0/24
     - ubuntu/ubuntu
    
       root/default
   * - mesos-agent1
     - 10.2.10.22
     - external-mesos: 10.2.10.0/24
     - ubuntu/ubuntu
      
       root/default
   * - mesos-agent2
     - 10.2.10.23
     - external-mesos: 10.2.10.0/24
     - ubuntu/ubuntu
    
       root/default
