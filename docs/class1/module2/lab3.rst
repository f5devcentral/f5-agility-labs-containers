Lab 2.3 - F5 CIS Usage & ClusterIP Mode
=======================================

Now that our container connector is up and running, let's deploy an application
and leverage our F5 CC.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

To deploy our application, we will need to do the following:

#. Define a Deployment: this will launch our application running in a
   container.

#. Define a ConfigMap: this can be used to store fine-grained information like
   individual properties or coarse-grained information like entire config files
   or JSON blobs. It will contain the BIG-IP configuration we need to push.

#. Define a Service: this is an abstraction which defines a logical set of
   *pods* and a policy by which to access them. Expose the *service* on a port
   on each node of the cluster (the same port on each *node*). You’ll be able
   to contact the service on any <NodeIP>:NodePort address. If you set the type
   field to "NodePort", the Kubernetes master will allocate a port from a
   flag-configured range **(default: 30000-32767)**, and each Node will proxy
   that port (the same port number on every Node) into your *Service*.

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in /home/ubuntu/agilitydocs/kubernetes

   .. literalinclude:: ../../../kubernetes/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,14

#. Create a file called ``f5-hello-world-configmap.yaml``

   .. tip:: Use the file in /home/ubuntu/agilitydocs/kubernetes

   .. attention:: The schema version below (for example 1.7) comes from the releases
      of big-ip-controller.  For more information, head over to the following
      link for a quick review:
      https://clouddocs.f5.com/containers/v2/releases_and_versioning.html#schema-table


   .. literalinclude:: ../../../kubernetes/f5-hello-world-configmap.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,9,16,18

#. Create a file called ``f5-hello-world-service.yaml``

   .. tip:: Use the file in /home/ubuntu/agilitydocs/kubernetes

   .. literalinclude:: ../../../kubernetes/f5-hello-world-service.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,12

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f f5-hello-world-deployment.yaml
      kubectl create -f f5-hello-world-configmap.yaml
      kubectl create -f f5-hello-world-service.yaml

   .. image:: images/f5-container-connector-launch-app.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      kubectl get pods -o wide

      # This can take a few seconds to a minute to create these hello-world containers to running state.

   .. image:: images/f5-hello-world-pods.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: images/f5-container-connector-check-app-definition.png

#. To test the app you need to pay attention to:

   **The NodePort value**, that's the port used by Kubernetes to give you
   access to the app from the outside. Here it's "30507", highlighted above.

   **The Endpoints**, that's our 2 instances (defined as replicas in our
   deployment file) and the port assigned to the service: port 8080.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration.  From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the "kubernetes" partition or you'll
      see nothing.

   Here you can see a new Virtual Server, "default_f5-hello-world" was created,
   listening on 10.1.1.4:81.

   .. image:: images/f5-container-connector-check-app-bigipconfig.png

   Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "cfgmap_default_f5-hello-world_f5-hello-world"
   --> Members

   .. image:: images/f5-container-connector-check-app-bigipconfig2.png

   .. note:: You can see that the pool members listed are all the kubernetes
      nodes. (**NodePort mode**)

#. Now you can try to access your application via your BIG-IP VIP: 10.1.1.4:81

   .. image:: images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list -->
   cfgmap_default_f5-hello-world_f5-hello-world --> Statistics to see that
   traffic is distributed as expected.

   .. image:: images/f5-container-connector-check-app-bigip-stats.png

#. How is traffic forwarded in Kubernetes from the <node IP>:30507 to the
   <container IP>:8080? This is done via iptables that is managed via the
   kube-proxy instances. On either of the nodes, SSH in and run the following
   command:

   .. code-block:: bash

      sudo iptables-save | grep f5-hello-world

   This will list the different iptables rules that were created regarding our
   service.

   .. image:: images/f5-container-connector-list-frontend-iptables.png

#. Scale the f5-hello-world app

   .. code-block:: bash

      kubectl scale --replicas=10 deployment/f5-hello-world -n default

#. Check that the pods were created

   .. code-block:: bash

      kubectl get pods

   .. image:: images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on big-ip

   .. image:: images/f5-hello-world-pool-scale10.png

   .. attention:: Why are there only 2 pool members?
