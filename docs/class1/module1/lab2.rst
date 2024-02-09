Lab 1.2 - Deploy Hello-World Using Ingress
==========================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

To deploy our application, we will need the following definitions:

- Define the **Deployment** resource: this will launch our application running
  in a container.

- Define the **Service** resource: this is an abstraction which defines a
  logical set of pods and a policy by which to access them, and exposes the service
  on a port on each node of the cluster (the same port on each node). You’ll
  be able to contact the service on any <NodeIP>:NodePort address. When you set
  the type field to "NodePort", the master will allocate a port from a
  flag-configured range (default: 30000-32767), and each Node will proxy that
  port (the same port number on every Node) for your Service.

- Define the **Ingress** resource: this is used to add the necesary annotations
  to define the virtual server settings.

  .. seealso::
     `Supported Ingress Annotations <https://clouddocs.f5.com/products/connectors/k8s-bigip-ctlr/v1.11/#ingress-resources>`_

App Deployment
--------------

Back to the terminal and SSH session on **kube-master1** we will create all the
required files and launch them.

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/deployment-hello-world.yaml
      :language: yaml
      :caption: deployment-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``nodeport-service-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/nodeport-service-hello-world.yaml
      :language: yaml
      :caption: nodeport-service-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,17

#. Create a file called ``ingress-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/ingress-hello-world.yaml
      :language: yaml
      :caption: ingress-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7-9,23,24

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f deployment-hello-world.yaml
      kubectl create -f nodeport-service-hello-world.yaml
      kubectl create -f ingress-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-ingress-app.png

#. To check the status of our deployment, you can run the following commands:

   .. note:: This can take a few seconds to a minute to create these
      hello-world containers to running state.

   .. code-block:: bash

      kubectl get pods -o wide

   .. image:: ../images/f5-hello-world-pods.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-container-connector-check-app-definition-ingress.png

   .. attention:: To understand and test the new app pay attention to the
      **NodePort value**, that's the port used to give you access to the app
      from the outside. In this example it's "32722", highlighted above.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on bigip1. Switch back to the open management session on
   firefox.

   .. warning:: Don't forget to select the "kubernetes" partition or you'll
      see nothing.

   GoTo: :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see a new Virtual Server, "ingress_10.1.1.4_80" was created,
   listening on 10.1.1.4:80 in partition "kubernetes".

   .. image:: ../images/f5-container-connector-check-app-ingress.png

#. Check the Pools to see a new pool and the associated pool members.

   GoTo: :menuselection:`Local Traffic --> Pools` and select the
   "ingress_default_f5-hello-world-web" pool. Click the Members tab.

   .. image:: ../images/f5-container-connector-check-app-ingress-pool.png

   .. note:: You can see that the pool members listed are all the cluster
      node IPs on port 32722. (**NodePort mode**)

#. Access your web application via firefox on the jumpbox.

   .. note:: Open a new tab and select the "Hello, World" shortcut or type
      http://10.1.1.4 in the URL field.

   .. image:: ../images/f5-container-connector-access-app.png

#. To check traffic distribution, hit Refresh many times on your open browser
   session. Then go back to the management console open on firefox.

   GoTo: :menuselection:`Local Traffic --> Pools --> Pool list -->
   ingress_default_f5-hello-world-web --> Statistics`

   .. image:: ../images/f5-container-connector-check-app-ingress-stats.png

   .. note:: Are you seeing traffic distribution as shown in the image above?
      If not why? (HINT: Check the virtual server settings.)

#. Delete Hello-World

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.

   .. code-block:: bash

      kubectl delete -f ingress-hello-world.yaml
      kubectl delete -f nodeport-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml

   .. attention:: Validate the objects are removed via the management console.
      :menuselection:`Local Traffic --> Virtual Servers`
