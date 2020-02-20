Lab 3.3 - Deploy Hello-World (ConfigMap w/ AS3)
===============================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **okd-master1** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-cluster.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-service-clusterip.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,8-10,17

#. Create a file called ``f5-hello-world-configmap.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-configmap.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,8,27,30

#. We can now launch our application:

   .. code-block:: bash

      oc create -f f5-hello-world-deployment.yaml
      oc create -f f5-hello-world-service-cluster.yaml
      oc create -f f5-hello-world-configmap.yaml

   .. image:: ../images/f5-container-connector-launch-app.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      oc get pods -o wide

   .. image:: ../images/f5-hello-world-pods.png

   .. code-block:: bash

      oc describe svc f5-hello-world
        
   .. image:: ../images/f5-container-connector-check-app-definition.png

#. To understand and test the new app you need to pay attention to:

   **The Endpoints**, this shows our 2 instances (defined as replicas in our
   deployment file) and the overlay IP assigned to the pod.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration.  From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the "okd" partition or you'll see
      nothing.

   Here you can see a new Virtual Server, "default_f5-hello-world" was created,
   listening on 10.1.1.4:80 in partition "okd".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig.png

   Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "cfgmap_default_f5-hello-world_f5-hello-world"
   --> Members

   .. image:: ../images/f5-container-connector-check-app-bigipconfig3.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Now you can try to access your application via the BIG-IP VS/VIP: UDF-URL

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list -->
   cfgmap_default_f5-hello-world_f5-hello-world -->
   Statistics to see that traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats-clusterip.png

#. Scale the f5-hello-world app

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-hello-world-web -n default

#. Check the pods were created

   .. code-block:: bash

      oc get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on BIG-IP:

   .. image:: ../images/f5-hello-world-pool-scale10-clusterip.png

   .. attention:: Now we show 10 pool members vs. 2 in the previous lab, why?

#. Delete f5-hello-world

   .. code-block:: bash

      oc delete -f f5-hello-world-configmap.yaml

.. attention:: This concludes **Class 2 - CIS and OpenShift**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
