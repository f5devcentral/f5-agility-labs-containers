Lab 2.3 - Deploy Hello-World (ConfigMap w/ AS3)
===============================================

Now that CIS is up and running, let's deploy an application and leverage our
new service.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

To deploy our application, we will need to do the following:

#. Define a Deployment: this will launch our application running in a
   container.

#. Define a Service: this is an abstraction which defines a logical set of
   *pods* and a policy by which to access them. Expose the *service* on a port
   on each node of the cluster (the same port on each *node*). You’ll be able
   to contact the service on any <NodeIP>:NodePort address. If you set the type
   field to "NodePort", the Kubernetes master will allocate a port from a
   flag-configured range **(default: 30000-32767)**, and each Node will proxy
   that port (the same port number on every Node) into your *Service*.

#. Define a ConfigMap: this can be used to store fine-grained information like
   individual properties or coarse-grained information like entire config files
   or JSON blobs. It will contain the BIG-IP configuration we need to push.

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-nodeport.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/f5-hello-world-service-nodeport.yaml
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
      kubectl create -f f5-hello-world-service-nodeport.yaml
      kubectl create -f f5-hello-world-configmap.yaml

   .. image:: ../images/f5-container-connector-launch-app.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      kubectl get pods -o wide

      # This can take a few seconds to a minute to create these hello-world containers to running state.

   .. image:: ../images/f5-hello-world-pods.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-container-connector-check-app-definition.png

#. To understand and test the new app you need to pay attention to:

   **The NodePort value**, that's the port used by Kubernetes to give you
   access to the app from the outside. Here it's "32188", highlighted above.

   **The Endpoints**, that's our 2 instances (defined as replicas in our
   deployment file) and the port assigned to the service: port 8080.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration. From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the "kubernetes" partition or you'll
      see nothing.

   Here you can see a new Virtual Server, "default_f5-hello-world" was created,
   listening on 10.1.1.4:81 in partition "kubernetes".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig.png

   Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "cfgmap_default_f5-hello-world_f5-hello-world"
   --> Members

   .. image:: ../images/f5-container-connector-check-app-bigipconfig2.png

   .. note:: You can see that the pool members listed are all the kubernetes
      nodes on the node port 32188. (**NodePort mode**)

#. Now you can try to access your application via the BIG-IP VS/VIP: UDF-URL

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list -->
   cfgmap_default_f5-hello-world_f5-hello-world --> Statistics to see that
   traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats.png

#. Scale the f5-hello-world app

   .. code-block:: bash

      kubectl scale --replicas=10 deployment/f5-hello-world -n default

#. Check that the pods were created

   .. code-block:: bash

      kubectl get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on BIG-IP:

   .. image:: ../images/f5-hello-world-pool-scale10.png

   .. attention:: Why do we still only show 3 pool members?

#. Delete Hello-World and Remove CIS

   .. code-block:: bash

      kubectl delete -f f5-hello-world-configmap.yaml
      kubectl delete -f f5-hello-world-service-nodeport.yaml
      kubectl delete -f f5-hello-world-deployment.yaml
      kubectl delete -f f5-nodeport-deployment.yaml

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.
