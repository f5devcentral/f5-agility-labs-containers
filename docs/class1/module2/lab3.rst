Lab 2.3 - Deploy Hello-World Using ConfigMap w/ AS3
===================================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/deployment-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``clusterip-service-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/clusterip-service-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,8-10,17

#. Create a file called ``configmap-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/configmap-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,8,27,30

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f deployment-hello-world.yaml
      kubectl create -f clusterip-service-hello-world.yaml
      kubectl create -f configmap-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-app-clusterip.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      kubectl get pods -o wide

   .. image:: ../images/f5-hello-world-pods-clusterip.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-cis-describe-clusterip2-service.png

#. To understand and test the new app pay attention to the **Endpoints value**,
   this shows our 2 instances (defined as replicas in our deployment file) and
   the flannel IP assigned to the pod.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration. From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the proper partition. Previously we
      checked the "kubernetes" partition. In this case we need to look at
      the "AS3" partition. This partition was auto created by AS3 and named
      after the Tenant which happens to be "AS3".

   Here you can see a new Virtual Server, "serviceMain" was created,
   listening on 10.1.1.4:80 in partition "AS3".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

#. Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "web_pool" --> Members

   .. image:: ../images/f5-container-connector-check-app-pool-cluster-as3.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Now you can try to access your application via the BIG-IP VS/VIP: UDF-URL

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list --> web_pool --> Statistics to see that
   traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats-cluster-as3.png

#. Scale the f5-hello-world app

   .. code-block:: bash

      kubectl scale --replicas=10 deployment/f5-hello-world-web -n default

#. Check that the pods were created

   .. code-block:: bash

      kubectl get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on BIG-IP:

   .. image:: ../images/f5-hello-world-pool-scale10-as3-clusterip.png

   .. attention:: Now we show 10 pool members vs. 2 in the previous lab, why?

#. Remove Hello-World from BIG-IP. When using AS3 an extra steps need to be
   performed. In addition to deleting the previously created configmap a
   "blank" declaration needs to be sent to completly remove the application:
   
   .. literalinclude:: ../kubernetes/delete-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,19

   .. code-block:: bash

      kubectl delete -f configmap-hello-world.yaml
      kubectl delete -f clusterip-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml
      
      kubectl create -f delete-hello-world.yaml
      kubectl delete -f delete-hello-world.yaml

.. attention:: This concludes **Class 1 - CIS and Kubernetes**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
