Lab 1.3 - F5 Container Connector Setup
======================================

Take the steps below to deploy a contoller for each BIG-IP device in the
cluster.

Set up RBAC
-----------

The F5 BIG-IP Controller requires permission to monitor the status of the
OpenSfhift cluster. The following will create a bigip login secret, Service
Account, and Cluster Role:

.. code-block:: bash

   oc create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin
   oc create serviceaccount bigip-ctlr -n kube-system
   oc create clusterrolebinding bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:bigip-ctlr


Create & Verify CC Deployment
-----------------------------

#. Create an OpenShift Deployment for **POD1** (one per BIG-IP device). You
   need to deploy a controller for both bigip1 and bigip2.

   cc-bigip1-10.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/cc-bigip1-10.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,17,34,35,38

   cc-bigip2-10.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/cc-bigip2-10.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,17,34,35,38

   .. code-block:: bash

      oc create -f cc-bigip1-10.yaml
      oc create -f cc-bigip2-10.yaml

#. Verify the deployment and pods that are created

   .. code-block:: bash

      oc get deployment -n kube-system

   .. code-block:: bash

      oc get pods -n kube-system

#. Create an OpenShift Deployment for **POD2** (one per BIG-IP device). You
   need to deploy a controller for both bigip1 and bigip2.

   cc-bigip1-20.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/cc-bigip1-20.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,17,34,35,38

   cc-bigip2-20.yaml

   .. literalinclude:: ../../../openshift/advanced/appendix1/cc-bigip2-20.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,17,34,35,38

   .. code-block:: bash

      oc create -f cc-bigip1-20.yaml
      oc create -f cc-bigip2-20.yaml

#. Verify the deployment and pods that are created

   .. code-block:: bash

      oc get deployment -n kube-system
      oc get pods -n kube-system
      oc logs 
