Lab 1.2 - Deploy Hello-World Using Route
========================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

To deploy our application, we will need the following definitions:

- Define the **Deployment** resource: this will launch our application running
  in a container.

- Define the **Service** resource: this is an abstraction which defines a
  logical set of pods and a policy by which to access them. Expose the service
  on a port on each node of the cluster (the same port on each node). You’ll
  be able to contact the service on any <NodeIP>:NodePort address. When you set
  the type field to "NodePort", the master will allocate a port from a
  flag-configured range (default: 30000-32767), and each Node will proxy that
  port (the same port number on every Node) for your Service.

- Define the **Route** resource: this is used to add the necesary annotations
  to define the virtual server settings.

  .. seealso:: 
     `Supported Route Annotations <https://clouddocs.f5.com/products/connectors/k8s-bigip-ctlr/v1.11/#supported-route-annotations>`_
  
App Deployment
--------------

On **okd-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/deployment-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``nodeport-service-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/nodeport-service-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,17

#. Create a file called ``route-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/route-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7-9,23,24

#. We can now launch our application:

   .. code-block:: bash

      oc create -f deployment-hello-world.yaml
      oc create -f nodeport-service-hello-world.yaml
      oc create -f route-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-app-route.png

#. To check the status of our deployment, you can run the following commands:

   .. note:: This can take a few seconds to a minute to create these
      hello-world containers to running state.

   .. code-block:: bash

      oc get pods -o wide

   .. image:: ../images/f5-hello-world-pods-route.png

   .. code-block:: bash

      oc describe svc f5-hello-world

   .. image:: ../images/f5-container-connector-check-app-definition-route.png

   .. attention:: To understand and test the new app pay attention to the
      **NodePort value**, that's the port used to give you access to the app
      from the outside. Here it's "30444", highlighted above.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on bigip1. We should still have access to TMUI via UDF go back
   to the open session.

   .. warning:: Don't forget to select the "okd" partition or you'll
      see nothing.

   Goto :menuselection:`Local Traffic --> Virtual Servers`

   With "Route" you'll seee two virtual servers defined. "okd_http_vs" and
   "okd_https_vs", listening on port 80 and 443.

   .. image:: ../images/f5-container-connector-check-app-route-bigipconfig.png

   These Virtuals uses an LTM Policy to direct traffic based on the host header.
   You can view this from the BIG-IP GUI at :menuselection:`Local Traffic -->
   Virtual Servers --> Policies` and click the Published Policy,
   "openshift_insecure_routes".

   .. image:: ../images/f5-check-ltm-policy-route.png

#. Check the Pools to see a new pool and the associated pool members:
   :menuselection:`Local Traffic --> Pools --> 
   "openshift_default_f5-hello-world-web" --> Members`

   .. image:: ../images/f5-container-connector-check-app-route-pool.png

   .. note:: You can see that the pool members listed are all the cluster
      nodes on the node port 30444. (**NodePort mode**)

#. To view the application from a browser, you'll need to update your local
   host file, pointing the assigned public IP at "mysite.f5demo.com".

   .. note:: This step can be skipped.

#. Delete Hello-World

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.

   .. code-block:: bash

      oc delete -f route-hello-world.yaml
      oc delete -f nodeport-service-hello-world.yaml
      oc delete -f deployment-hello-world.yaml
   
   .. attention:: Validate the objects are removed via bigip1 TMUI.
