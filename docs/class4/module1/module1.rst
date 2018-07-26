Module 1: F5 Container Connector with RedHat OpenShift
======================================================

Red Hat’s OpenShift Origin is a containerized application platform with a native Kubernetes integration. The BIG-IP Controller for Kubernetes enables use of a BIG-IP device as an edge load balancer, proxying traffic from outside networks to pods inside an OpenShift cluster. OpenShift Origin uses a pod network defined by the OpenShift SDN.

The F5 Integration for Kubernetes overview describes how the BIG-IP Controller works with Kubernetes. Because OpenShift has a native Kubernetes integration, the BIG-IP Controller works essentially the same in both environments. It does have a few OpenShift-specific prerequisites.

Today we are going to go through a prebuilt OpenShift environment with some locally deployed yaml files.  

.. toctree::
   :maxdepth: 1
   :glob:
   
   lab*
