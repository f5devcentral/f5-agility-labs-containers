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

We will use the command line on **kube-master1** to create all the
required files and launch them.

#. Go back to the Web Shell session you opened in the previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   to connect to **kube-master1** using the **Web Shell** access method, then switch to the **ubuntu** 
   user account using the "**su**" command:

   .. image:: ../images/WEBSHELL.png

   .. image:: ../images/WEBSHELLroot.png

   .. code-block:: bash

      su ubuntu


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
   configuration on BIG-IP1.
   Go back to the TMUI session you opened in a previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   and connect to **BIG-IP1** using the **TMUI** access method (*username*: **admin** and *password*: **admin**)

   .. image:: ../images/TMUI.png

   .. image:: ../images/TMUILogin.png

#. Browse to: :menuselection:`Local Traffic --> Virtual Servers` and select the **kubernetes** partition.

   .. warning:: Don't forget to select the "kubernetes" partition or you'll
      see nothing.

   Here you can see a new Virtual Server, "ingress_10.1.1.4_80" was created,
   listening on 10.1.1.4:80 in partition "kubernetes".

   .. image:: ../images/f5-container-connector-check-app-ingress.png

#. Check the Pools to see a new pool and the associated pool members.

   Browse to: :menuselection:`Local Traffic --> Pools` and select the
   "ingress_default_f5-hello-world-web" pool. Click the Members tab.

   .. image:: ../images/f5-container-connector-check-app-ingress-pool.png

   .. note:: You can see that the pool members listed are all the cluster
      node IPs on port 32722. (**NodePort mode**)

#. Now let's test access to the new web application "*through*"" **Firefox** on **superjump**.
   To do this, browse back to the **Deployment** tab of your UDF lab session at
   https://udf.f5.com and connect to **superjump** using the **Firefox** access method.

   .. note:: The web application is not directly accessible from the public Internet.
      But since the **superjump** system is connected to the same internal virtual lab network 
      we can use the **Firefox** access method because it provides *browser-in-a-browser*
      functionality that allows remote browsing to this new private web site.

   .. image:: ../images/udffirefox.png

#. The *Firefox* application installed on the superjump system's will appear in your browser (i.e., a *browser-in-a-browser*).
   Find and click on the "**Hello, World**" bookmark/shortcut, or type http://10.1.1.4 in the appropriate URL field.

   .. image:: ../images/ffhelloworld.png

   .. image:: ../images/f5-container-connector-access-app.png

#. To check traffic distribution, hit *Refresh* many times on your open browser
   session. Then go back to the BIG-IP TMUI management console.

   Browse to: :menuselection:`Local Traffic --> Pools --> Pool list -->
   ingress_default_f5-hello-world-web --> Statistics`

   .. image:: ../images/f5-container-connector-check-app-ingress-stats.png

   .. note:: Are you seeing traffic distribution as shown in the image above?
      If not why? (**HINT**: *Check the virtual server settings... Resources tab...*)

#. Delete Hello-World with the following commands in the **kube-master1** Web Shell window:

   .. code-block:: bash

      kubectl delete -f ingress-hello-world.yaml
      kubectl delete -f nodeport-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml

   .. important:: **Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.**

#. Validate the objects are removed via the BIG-IP TMUI management console:
      :menuselection:`Local Traffic --> Virtual Servers`
