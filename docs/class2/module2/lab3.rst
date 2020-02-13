Lab 2.3 - Deploy Hello-World (ConfigMap w/ AS3)
===============================================

Just like the previous lab we'll deploy the f5-hello-world docker container.
But instead of using the Ingress resource we'll use ConfigMap.

To deploy our application, we will need the following definitions:

#. Define a **Deployment**: this will launch our application running in a
   container.

- Define a **Service**: this is an abstraction which defines a logical set of
  pods and a policy by which to access them. Expose the service on a port
  on each node of the cluster (the same port on each node). You’ll be able
  to contact the service on any <NodeIP>:NodePort address. When you set the
  type field to "NodePort", the Kubernetes master will allocate a port from a
  flag-configured range (default: 30000-32767), and each Node will proxy
  that port (the same port number on every Node) for your Service.

- Define a **ConfigMap**: this can be used to store fine-grained information
  like individual properties or coarse-grained information like entire config
  files  or JSON blobs. It will contain the BIG-IP configuration we need to
  push.

.. attention:: The steps are generally the same as the previous lab, the big
   difference is the two resource types. Your **Deployment** and **Service**
   definitions are the same file.

App Deployment
--------------

On the **okd-master1** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-nodeport.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-service-nodeport.yaml
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
      oc create -f f5-hello-world-service-nodeport.yaml
      oc create -f f5-hello-world-configmap.yaml
      
   .. image:: ../images/f5-container-connector-launch-app.png

#. To check the status of our deployment, you can run the following commands:

   .. note:: This can take a few seconds to a minute to create these
      hello-world containers to running state.

   .. code-block:: bash

      oc get pods -o wide

   .. image:: ../images/f5-hello-world-pods.png

   .. code-block:: bash

      oc describe svc f5-hello-world
        
   .. image:: ../images/f5-container-connector-check-app-definition-node.png

#. To understand and test the new app you need to pay attention to: 

   **The NodePort value**, that's the port used by Kubernetes to give you
   access to the app from the outside. Here it's "31268", highlighted above.

   **The Endpoints**, that's our 2 instances (defined as replicas in our
   deployment file) and the port assigned to the service: port 8080.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration.  From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the "okd" partition or you'll see
      nothing.

   Here you can see a new Virtual Server, "default_f5-hello-world" was created,
   listening on 10.1.1.4:81 in partition "okd".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig.png

   Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "cfgmap_default_f5-hello-world_f5-hello-world"
   --> Members

   .. image:: ../images/f5-container-connector-check-app-bigipconfig2.png

   .. note:: You can see that the pool members listed are all from the
      openshift nodes on the port 31268. (**NodePort mode**)

#. Now you can try to access your application via the BIG-IP VS/VIP: UDF-URL

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list -->
   cfgmap_default_f5-hello-world_f5-hello-world -->
   Statistics to see that traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats.png

#. Scale the f5-hello-world app

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-hello-world

#. Check the pods were created

   .. code-block:: bash

      oc get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on BIG-IP:

   .. image:: ../images/f5-hello-world-pool-scale10-node.png

   .. attention:: Why do we still only show 3 pool members?

#. Delete Hello-World and Remove CIS

   .. code-block:: bash

      oc delete -f f5-hello-world-configmap.yaml
      oc delete -f f5-hello-world-service-nodeport.yaml
      oc delete -f f5-hello-world-deployment.yaml
      oc delete -f f5-nodeport-deployment.yaml

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.
