Appendix 9: Build an Openshift v4 Cluster 
=========================================

.. important:: These instructions are for OKD 4.7.0.

   `Client tools for OpenShift <https://github.com/openshift/okd/releases/tag/4.7.0-0.okd-2021-09-19-013247>`_

In this module, we will use Terraform to deploy a 5 node cluster (3x master
and 2x nodes) on AWS utilizing Fedora CoreOS server images.

As a reminder, in this module, our cluster setup is:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Role**
   * - okd-master1
     - 10.1.1.10
     - Master
   * - okd-node1
     - 10.1.1.11
     - Node
   * - okd-node2
     - 10.1.1.12
     - Node

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
