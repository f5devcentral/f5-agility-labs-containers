Appendix 6: Build a Mesos / Marathon Cluster
============================================

.. attention:: **THE CLASS BLUEPRINT IS PRE-CONFIGURED WITH A WORKING CLUSTER.
   THIS APPENDIX IS FOR DOCUMENTION PURPOSES ONLY.**

In this module, we will build a 3 node cluster (1x master and 2x nodes)
utilizing Ubuntu server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - mesos-master1
     - 10.2.10.21
     - Master
   * - mesos-agent1
     - 10.2.10.22
     - Agent
   * - mesos-agent2
     - 10.2.10.23
     - Agent

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
