Lab 1.4 - F5 Container Connector Usage
======================================

Now that our container connector is up and running, let's deploy an application
to test both route domans / partitions.

For this lab we'll use a simple pre-configured docker image called
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

To deploy "f5-hello-world" on **ose-master1** and **ose-master2** create the
following files:

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

Now we need to creat the f5 configmap of the application for each partition.

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
      oc describe svc f5-hello-world

#. To test the app you need to pay attention to connect to the jumphost, open
   browser and got http://10.1.10.80 and http://10.1.10.81
   