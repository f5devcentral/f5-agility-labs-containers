Lab 1.2 - F5 Container Connector Usage
======================================

Now that our container connector is up and running, let's deploy an
application and leverage our F5 CC.

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

On the **ose-master** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in /root/f5-agility-labs-containers/openshift

   .. literalinclude:: ../../../openshift/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,6,14

#. Create a file called ``f5-hello-world-configmap.yaml``

   .. tip:: Use the file in /root/f5-agility-labs-containers/openshift

   .. literalinclude:: ../../../openshift/f5-hello-world-configmap.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,7,9,16,18

#. Create a file called ``f5-hello-world-service.yaml``

   .. tip:: Use the file in /root/f5-agility-labs-containers/openshift

   .. literalinclude:: ../../../openshift/f5-hello-world-service.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,12

#. We can now launch our application:

   .. code-block:: bash

      oc create -f f5-hello-world-deployment.yaml
      oc create -f f5-hello-world-configmap.yaml
      oc create -f f5-hello-world-service.yaml

   .. image:: images/f5-container-connector-launch-app.png
      :align: center

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      oc get pods -o wide

   .. image:: images/f5-hello-world-pods.png
      :align: center

   .. code-block:: bash

      oc describe svc f5-hello-world
        
   .. image:: images/f5-container-connector-check-app-definition.png
      :align: center

#. To test the app you need to pay attention to: 

   **The Endpoints**, that's our 2 instances (defined as replicas in our
   deployment file) and the port assigned to the service: port 8080.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration.  From the browser open https://10.1.1.245

   .. warning:: Don't forget to select the "ose" partition or you'll see
      nothing.

   Here you can see a new Virtual Server, "default_f5-hello-world" was created,
   listening on 10.10.199.81 in partition "ose".

   .. image:: images/f5-container-connector-check-app-bigipconfig.png
      :align: center

   Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "cfgmap_default_f5-hello-world_f5-hello-world"
   --> Members

   .. image:: images/f5-container-connector-check-app-bigipconfig2.png
      :align: center

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Now you can try to access your application via your BIG-IP VIP: 10.10.199.81

   .. image:: images/f5-container-connector-access-app.png
      :align: center

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list -->
   cfgmap_default_f5-hello-world_f5-hello-world -->
   Statistics to see that traffic is distributed as expected.

   .. image:: images/f5-container-connector-check-app-bigip-stats.png
      :align: center

#. Scale the f5-hello-world app

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-hello-world

#. Check the pods were created

   .. code-block:: bash

      oc get pods

   .. image:: images/f5-hello-world-pods-scale10.png
      :align: center

#. Check the pool was updated on big-ip

   .. image:: images/f5-hello-world-pool-scale10.png
        :align: center

   .. attention:: What networks were the IPs allocated from?
