Module 2: CIS NodePort Mode
===========================

Overview
--------

The CIS makes L4-L7 services available to users deploying microservices-based
applications in a containerized infrastructure. CIS - Kubernetes allows you
to expose a Kubernetes Service outside the cluster as a virtual server on a
BIG-IP device entirely through the Kubernetes API.

.. Attention:: In this module we'll use **NodePort Mode** to communicate
   with CIS.

.. seealso:: The official F5 documentation is here:
   `F5 Container Ingress Services - Kubernetes <http://clouddocs.f5.com/containers/v2/kubernetes/>`_

Prerequisites
-------------

Before being able to use F5 CIS, you need to confirm the following:

- You must have a fully active/licensed BIG-IP (SDN must be licensed)
- A BIG-IP partition needs to be setup for exclusive use by CIS
- You need a user with administrative access to this partition
- Your kubernetes environment must be up and running

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
