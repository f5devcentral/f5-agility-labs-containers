Lab 2.3 - Deploy Hello-World Using ConfigMap w/ AS3
===================================================

Just like the previous lab we'll deploy the f5-hello-world docker container.
But instead of using the Route resource we'll use ConfigMap.

App Deployment
--------------

On **okd-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/deployment-hello-world.yaml
      :language: yaml
      :caption: deployment-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-cluster.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/clusterip-service-hello-world.yaml
      :language: yaml
      :caption: clusterip-service-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,8-10,17

#. Create a file called ``configmap-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/configmap-hello-world.yaml
      :language: yaml
      :caption: configmap-hello-world.yaml
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
   configuration on bigip1. Switch back to the open management session on
   firefox.

   .. warning:: Don't forget to select the proper partition. Previously we
      checked the "okd" partition. In this case we need to look at the "AS3"
      partition. This partition was auto created by AS3 and named after the
      Tenant which happens to be "AS3".

   GoTo: :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see a new Virtual Server, "serviceMain" was created,
   listening on 10.1.1.4:80 in partition "AS3".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

#. Check the Pools to see a new pool and the associated pool members.

   GoTo: :menuselection:`Local Traffic --> Pools` and select the
   "web_pool" pool. Click the Members tab.

   .. image:: ../images/f5-container-connector-check-app-web-pool-as3.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Access your web application via firefox on the jumpbox.

   .. note:: Select the "Hello, World" shortcut or type http://10.1.1.4 in the
      URL field.

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI.

   Goto: :menuselection:`Local Traffic --> Pools --> Pool list -->
   "web_pool" --> Statistics` to see that traffic is distributed as expected.

   .. image:: ../images/f5-okd-check-app-bigip-stats-clusterip.png

   .. note:: Why is all the traffic directed to one pool member? The answer can
      be found by instpecting the "serviceMain" virtual service in the
      management GUI.

#. Scale the f5-hello-world app

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-hello-world-web -n default

#. Check that the pods were created

   .. code-block:: bash

      oc get pods

   .. image:: ../images/f5-hello-world-pods-scale10-2.png

#. Check the pool was updated on bigip1. GoTo: :menuselection:`Local Traffic
   --> Pools` and select the "web_pool" pool. Click the Members tab.

   .. image:: ../images/f5-hello-world-pool-scale10-clusterip.png

   .. attention:: Now we show 10 pool members. In module1 the number stayed at
      3 and didn't change, why?

#. Remove Hello-World from BIG-IP.

   .. attention:: In older versions of AS3 a "blank AS3 declaration" was
      required to completely remove the application/declaration from BIG-IP. In
      AS3 v2.20 and newer this is no longer a requirement.

   .. code-block:: bash

      oc delete -f configmap-hello-world.yaml
      oc delete -f clusterip-service-hello-world.yaml
      oc delete -f deployment-hello-world.yaml

   .. note:: Be sure to verify the virtual server and "AS3" partition were
      removed from BIG-IP.

.. attention:: This concludes **Class 2 - CIS and OpenShift**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
