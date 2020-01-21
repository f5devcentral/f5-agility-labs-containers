Lab 1.3 - F5 Container Connector Setup
======================================

Take the steps below to deploy a contoller for each BIG-IP device in the
cluster.

Set up RBAC
-----------

The F5 BIG-IP Controller requires permission to monitor the status of the
OpenSfhift cluster.  The following will create a "role" that will allow it to
access specific resources.

You can create RBAC resources in the project in which you will run your BIG-IP
Controller. Each Controller that manages a device in a cluster or
active-standby pair can use the same Service Account, Cluster Role, and
Cluster Role Binding.

#. Create bigip login secret

   .. code-block:: bash

      oc create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin

#. Create a Service Account for the BIG-IP Controller.

   .. code-block:: bash

      oc create serviceaccount bigip-ctlr -n kube-system

#. Create a Cluster Role and Cluster Role Binding with the required
   permissions.

   .. note:: The following file has already being created
      **f5-kctlr-openshift-clusterrole.yaml** which is located in
      **/home/centos/agilitydocs/openshift/advanced/ocp** on **ose-master1**

   .. literalinclude:: ../../../../openshift/advanced/ocp/f5-kctlr-openshift-clusterrole.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 3,23

   .. code-block:: bash

      oc create -f f5-kctlr-openshift-clusterrole.yaml

Create & Verify CC Deployment
-----------------------------

#. Create an OpenShift Deployment for each Controller (one per BIG-IP device).
   You need to deploy a controller for both f5-bigip-node1 and f5-bigip-node2

   * Provide a unique metadata.name for each Controller.
   * Provide a unique --bigip-url in each Deployment (each Controller manages a
     separate BIG-IP device).
   * Use the same --bigip-partition in all Deployments.

   bigip1-cc.yaml

   .. literalinclude:: ../../../../openshift/advanced/ocp/bigip1-cc.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,17,21-23

   bigip2-cc.yaml

   .. literalinclude:: ../../../../openshift/advanced/ocp/bigip2-cc.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,17,21-23

   .. code-block:: bash

      oc create -f bigip1-cc.yaml
      oc create -f bigip2-cc.yaml

#. Verify the deployment and pods that are created

   .. code-block:: bash

      oc get deployment -n kube-system

   .. note:: Check in your lab that you have your two controllers as 
      **AVAILABLE**. If Not, you won't be able to do the lab. It may take up to
      10 minutes for them to be available.

   .. image:: images/oc-get-deployment.png

   .. code-block:: bash

      oc get pods -n kube-system

   .. image:: images/oc-get-pods.png

   You can also use the web console in OpenShift (https://ose-master1:8443/) to
   view the bigip controller (login: **centos**, password: **centos**). Go to
   the kube-system project

   .. image:: images/kube-system.png
