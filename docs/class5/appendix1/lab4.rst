Lab 1.4 - F5 Container Connector Usage
======================================

Now that our container connector is up and running, let's deploy an
application to test both route domans / partitions.

For this lab we'll use a simple pre-configured docker image called
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

On both **ose-master1** and **ose-master2** create the following files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. literalinclude:: ../../../openshift/advanced/appendix1/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,6,14

#. Create a file called ``f5-hello-world-service.yaml``

   .. literalinclude:: ../../../openshift/advanced/appendix1/f5-hello-world-service.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,12

Now we need to creat the configmap of the application for each partition.

#. Create a file called ``f5-hello-world-configmap-10.yaml`` on **ose-master1**

   .. literalinclude:: ../../../openshift/advanced/appendix1/f5-hello-world-configmap-10.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,9,16,18

#. Create a file called ``f5-hello-world-configmap-20.yaml`` on **ose-master2**

   .. literalinclude:: ../../../openshift/advanced/appendix1/f5-hello-world-configmap-20.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,9,16,18

#. We can now launch our application:

   **ose-master1**

   .. code-block:: bash

      oc create -f f5-hello-world-deployment.yaml
      oc create -f f5-hello-world-service.yaml
      oc create -f f5-hello-world-configmap-10.yaml

   **ose-master2**
   
   .. code-block:: bash

      oc create -f f5-hello-world-deployment.yaml
      oc create -f f5-hello-world-service.yaml
      oc create -f f5-hello-world-configmap-20.yaml

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      oc get pods -o wide

   .. code-block:: bash

      oc describe svc f5-hello-world

#. To test the app you need to pay attention to: 

   **The Endpoints**, that's our 2 instances (defined as replicas in our
   deployment file) and the port assigned to the service: port 8080.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration.  From the browser open https://10.1.1.245

   .. warning:: Don't forget to select the "ose" partition or you'll see
      nothing.

#. Now access your application via the BIG-IP VIP: 10.3.10.81

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list -->
   cfgmap_default_f5-hello-world_f5-hello-world -->
   Statistics to see that traffic is distributed as expected.

#. Scale the f5-hello-world app

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-hello-world

#. Check the pods were created

   .. code-block:: bash

      oc get pods
