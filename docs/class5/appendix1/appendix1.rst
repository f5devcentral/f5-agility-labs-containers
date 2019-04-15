Appendix 1: BIG-IP / OpenShift Multi-Pod Deployment
===================================================

In this appendix we will configuring an HA pair of BIG-IP's to work with two
OpenShift pods. These pods will use the same internal IP space. To handle this
use case BIG-IP will require route-domains.

.. attention:: This use case and following lab config is not part of the
   current Ravello Agility blueprint.

The following is an overview of our lab setup configuration:

.. list-table::
   :header-rows: 1

   * - **Hostname**
     - **IP-ADDR**
     - **Credentials**
   * - jumpbox (Windows)
     - 10.1.1.18
     - Administrator/ncq3Ck6sf
   * - bigip1
     - 10.1.1.4

       10.1.10.4

     - admin/admin

       root/default
   * - bigip2
     - 10.1.1.5

       10.1.10.5

     - admin/admin

       root/default
   * - ose-master1
     - 10.1.10.7
     - centos/centos
   * - ose-node1
     - 10.1.10.8
     - centos/centos
   * - ose-node2
     - 10.1.10.9
     - centos/centos
   * - ose-master2
     - 10.1.10.10
     - centos/centos
   * - ose-node3
     - 10.1.10.11
     - centos/centos
   * - ose-node4
     - 10.1.10.12
     - centos/centos

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
