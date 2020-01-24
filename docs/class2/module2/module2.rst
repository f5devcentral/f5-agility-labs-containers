Module 2: F5 Container Ingress Service and OpenShift
====================================================

Overview
--------

The F5 Integration for Kubernetes overview describes how the BIG-IP Controller
works with Kubernetes. Because OpenShift has a native Kubernetes integration,
the BIG-IP Controller works essentially the same in both environments. It does
have a few OpenShift-specific prerequisites.

.. seealso:: The official F5 documentation is here:
   `F5 Container Connector - OpenShift <https://clouddocs.f5.com/containers/v2/openshift/>`_

Architecture
------------

CIS for Kubernetes comprises the *f5-k8s-controller* and user-defined “F5
resources”. The *f5-k8s-controller* is a Docker container that can run in a
*Kubernetes Pod*. The “F5 resources” are *Kubernetes ConfigMap* resources that
pass encoded data to the f5-k8s-controller. These resources tell the
f5-k8s-controller:

- What objects to configure on your BIG-IP.

- What *Kubernetes Service* the BIG-IP objects belong to (the frontend and
  backend properties in the *ConfigMap*, respectively).

The f5-k8s-controller watches for the creation and modification of F5 resources
in Kubernetes. When it discovers changes, it modifies the BIG-IP accordingly.
For example, for an F5 virtualServer resource, CIS - Kubernetes does the
following:

- Creates objects to represent the virtual server on the BIG-IP in the
  specified partition.
- Creates pool members for each node in the Kubernetes cluster, using the
  NodePort assigned to the service port by Kubernetes.
- Monitors the F5 resources and linked Kubernetes resources for changes and
  reconfigures the BIG-IP accordingly.
- The BIG-IP then handles traffic for the Service on the specified virtual
  address and load-balances to all nodes in the cluster.
- Within the cluster, the allocated NodePort is load-balanced to all pods for
  the Service.

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
