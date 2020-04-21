Module 2: CIS Using ClusterIP Mode
==================================

Overview
--------

The F5 Integration for Kubernetes overview describes how the BIG-IP Controller
works with Kubernetes. Because OpenShift has a native Kubernetes integration,
the BIG-IP Controller works essentially the same in both environments. It does
have a few OpenShift-specific prerequisites.

.. Attention:: In this module we'll use **ClusterIP Mode** to communicate
   with CIS.

.. seealso:: The official F5 documentation is here:
   `F5 Container Connector - OpenShift <https://clouddocs.f5.com/containers/v2/openshift/>`_

Prerequisites
-------------

Before being able to use F5 CIS, you need to confirm the following:

- You must have a fully active/licensed BIG-IP (SDN must be licensed)
- A BIG-IP partition needs to be setup for exclusive use by CIS
- You need a user with administrative access to this partition
- Your openshift environment must be up and running

.. toctree::
   :maxdepth: 1
   :glob:
   
   lab*
