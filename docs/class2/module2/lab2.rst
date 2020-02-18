Lab 2.2 - Deploy Hello-World (Route)
====================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

To deploy our application, we will need the following definitions:

- Define a **Deployment**: this will launch our application running in a
  container.

- Define a **Service**: this is an abstraction which defines a logical set of
  pods and a policy by which to access them. Expose the service on a port
  on each node of the cluster (the same port on each node). You’ll be able
  to contact the service on any <NodeIP>:NodePort address. When you set the
  type field to "NodePort", the master will allocate a port from a
  flag-configured range (default: 30000-32767), and each Node will proxy
  that port (the same port number on every Node) for your Service.

- Define a **Route**: this is used to add the necesary annotations to define
  the virtual server settings.

  .. seealso:: 
     `Supported Route Annotations <https://clouddocs.f5.com/products/connectors/k8s-bigip-ctlr/v1.11/#supported-route-annotations>`_
  
App Deployment
--------------

On **okd-master1** we will create all the required files:

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
      :emphasize-lines: 2,17

#. Create a file called ``f5-hello-world-route.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-route.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7-9,23,24

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f f5-hello-world-deployment.yaml
      kubectl create -f f5-hello-world-service-nodeport.yaml
      kubectl create -f f5-hello-world-route.yaml

   .. image:: ../images/f5-container-connector-launch-app.png

#. To check the status of our deployment, you can run the following commands:

   .. note:: This can take a few seconds to a minute to create these
      hello-world containers to running state.

   .. code-block:: bash

      kubectl get pods -o wide

   .. image:: ../images/f5-hello-world-pods.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-container-connector-check-app-definition.png

#. To understand and test the new app you need to pay attention to:

   **The NodePort value**, that's the port used to give you access to the app
   from the outside. Here it's "32188", highlighted above.

   **The Endpoints**, that's our 2 instances (defined as replicas in our
   deployment file) and the port assigned to the service: port 8080.

   Now that we have deployed our application sucessfully, we can check our
   BIG-IP configuration. From the browser open https://10.1.1.4

   .. warning:: Don't forget to select the "okd" partition or you'll
      see nothing.

   Here you can see a new Virtual Server, "ingress_10.1.1.4_81" was created,
   listening on 10.1.1.4:81 in partition "okd".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig.png

   Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "ingress_default_f5-hello-world-web"
   --> Members

   .. image:: ../images/f5-container-connector-check-app-bigipconfig2.png

   .. note:: You can see that the pool members listed are all the cluster
      nodes on the node port 32188. (**NodePort mode**)

#. Now you can try to access your application via the BIG-IP VS/VIP: UDF-URL

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI, go to Local
   Traffic --> Pools --> Pool list --> ingress_default_f5-hello-world-web -->
   Statistics to see that traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats.png

#. Delete Hello-World

   .. code-block:: bash

      kubectl delete -f f5-hello-world-route.yaml
      kubectl delete -f f5-hello-world-service-nodeport.yaml
      kubectl delete -f f5-hello-world-deployment.yaml

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.
