Lab 2.3 - Deploy Hello-World Using ConfigMap w/ AS3
===================================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **okd-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/deployment-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-cluster.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/clusterip-service-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,8-10,17

#. Create a file called ``configmap-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/configmap-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,8,27,30

#. We can now launch our application:

   .. code-block:: bash

      oc create -f deployment-hello-world.yaml
      oc create -f clusterip-service-hello-world.yaml
      oc create -f configmap-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-app.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      oc get pods -o wide

   .. image:: ../images/f5-okd-hello-world-pods.png

   .. code-block:: bash

      oc describe svc f5-hello-world
        
   .. image:: ../images/f5-okd-check-app-definition.png

   .. attention:: To understand and test the new app pay attention to the
      **Endpoints value**,  this shows our 2 instances (defined as replicas in
      our deployment file) and the overlay network IP assigned to the pod.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on bigip1. We should still have access to TMUI via UDF. Go
   back to the open session.

   .. warning:: Don't forget to select the proper partition. Previously we
      checked the "okd" partition. In this case we need to look at the "AS3"
      partition. This partition was auto created by AS3 and named after the
      Tenant which happens to be "AS3".

   GoTo: :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see a new Virtual Server, "serviceMain" was created,
   listening on 10.1.1.4:80 in partition "AS3".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

#. Check the Pools to see a new pool and the associated pool members.

   GoTo: :menuselection:`Local Traffic --> Pools --> "web_pool" --> Members`

   .. image:: ../images/f5-container-connector-check-app-web-pool-as3.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Access your web application via UDF-URL.

   .. note:: This URL can be found on the UDF student portal

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI.

   Goto: :menuselection:`Local Traffic --> Pools --> Pool list -->
   "web_pool" --> Statistics` to see that traffic is distributed as expected.

   .. image:: ../images/f5-okd-check-app-bigip-stats-clusterip.png

   .. note:: Why is all the traffic directed to one pool member?

#. Scale the f5-hello-world app

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-hello-world-web -n default

#. Check the pods were created

   .. code-block:: bash

      oc get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on BIG-IP:

   .. image:: ../images/f5-hello-world-pool-scale10-clusterip.png

   .. attention:: Now we show 10 pool members vs. 3 in the previous lab, why?

#. Remove Hello-World from BIG-IP.

   .. important:: When using AS3 an extra step needs to be performed. In
      addition to deleting the application configmap, a "blank AS3 declaration"
      is required to completely remove the application from BIG-IP.

   "Blank AS3 Declartion"
   
   .. literalinclude:: ../openshift/delete-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,19

   .. code-block:: bash

      oc delete -f configmap-hello-world.yaml
      oc delete -f clusterip-service-hello-world.yaml
      oc delete -f deployment-hello-world.yaml
      
      oc create -f delete-hello-world.yaml
      oc delete -f delete-hello-world.yaml

.. attention:: This concludes **Class 2 - CIS and OpenShift**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
