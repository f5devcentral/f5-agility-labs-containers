Lab 2.3 - Deploy Hello-World (ConfigMap w/ AS3)
===============================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-clusterip.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/f5-hello-world-service-clusterip.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,8-10,17

#. Create a file called ``f5-hello-world-configmap.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/f5-hello-world-configmap.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,8,27,30

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f f5-hello-world-deployment.yaml
      kubectl create -f f5-hello-world-service-clusterip.yaml
      kubectl create -f f5-hello-world-configmap.yaml

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
   BIG-IP configuration.  From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the proper partition. Previously we
      checked the "kubernetes" partition. In this case we need to look at
      the "AS3" partition. This partition was auto created by AS3 and named
      after the Tenant which happens to be "AS3".

   Here you can see a new Virtual Server, "serviceMain" was created,
   listening on 10.1.1.4:80 in partition "AS3".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

   Check the Pools to see a new pool and the associated pool members:
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
   performed. In addion to deleteing the previously created configmap a "blank"
   declaration needs to be sent to completly remove the application:
   
   .. literalinclude:: ../kubernetes/f5-hello-world-delete-configmap.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,19

   .. code-block:: bash

      kubectl delete -f f5-hello-world-configmap.yaml
      kubectl delete -f f5-hello-world-service-clusterip.yaml
      kubectl delete -f f5-hello-world-deployment.yaml
      
      kubectl create -f f5-hello-world-delete-configmap.yaml
      kubectl delete -f f5-hello-world-delete-configmap.yaml

.. attention:: This concludes **Class 1 - CIS and Kubernetes**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
