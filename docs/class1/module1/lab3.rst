Lab 1.3 - Deploy Hello-World Using ConfigMap w/ AS3
===================================================

Just like the previous lab we'll deploy the f5-hello-world docker container.
But instead of using the Ingress resource we'll use ConfigMap.

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

- Define the **ConfigMap** resource: this can be used to store fine-grained
  information like individual properties or coarse-grained information like
  entire config files  or JSON blobs. It will contain the BIG-IP configuration
  we need to push.

.. attention:: The steps are generally the same as the previous lab, the big
   difference is the two resource types. Your **Deployment** and **Service**
   definitions are the same file.

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
      :emphasize-lines: 2,8-10,17

#. Create a file called ``configmap-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/configmap-hello-world.yaml
      :language: yaml
      :caption: configmap-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,5,7,8,19,21,27,30,32

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f deployment-hello-world.yaml
      kubectl create -f nodeport-service-hello-world.yaml
      kubectl create -f configmap-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-configmap-app.png

#. To check the status of our deployment, you can run the following commands:

   .. note:: This can take a few seconds to a minute to create these
      hello-world containers to running state.

   .. code-block:: bash

      kubectl get pods -o wide

   .. image:: ../images/f5-hello-world-pods2.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-container-connector-check-app-definition-configmap.png

   .. attention:: To understand and test the new app pay attention to the
      **NodePort value**, that's the port used to give you access to the app
      from the outside. Here it's "32734", highlighted above.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on BIG-IP1. Switch back to the open management session on
   firefox.

   .. warning:: Don't forget to select the proper partition. Previously we
      checked the "kubernetes" partition. In this case we need to look at
      the "**AS3**" partition. This partition was auto created by AS3 and named
      after the Tenant which happens to be "**AS3**".

   Browse to :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see a new Virtual Server, "**serviceMain**" was created,
   listening on **10.1.1.4:80** in partition "**AS3**".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

#. Check the Pools to see a new pool and the associated pool members.

   Browse to: :menuselection:`Local Traffic --> Pools` and select the
   "web_pool" pool. Click the Members tab.

   .. image:: ../images/f5-container-connector-check-app-pool-as3.png

   .. note:: You can see that the pool members listed are all the cluster
      node IPs on port 32734. (**NodePort mode**)

#. Access your web application via **Firefox** on the **superjump**.

   .. note:: Select the "Hello, World" shortcut or type http://10.1.1.4 in the
      URL field.

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** TMUI window

   Browse to: :menuselection:`Local Traffic --> Pools --> Pool list -->
   "web_pool" --> Statistics` to see that traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats-as3.png

   .. note:: Why is all the traffic directed to one pool member? The answer can
      be found by instpecting the "serviceMain" virtual service...

#. Scale the f5-hello-world app

   .. code-block:: bash

      kubectl scale --replicas=10 deployment/f5-hello-world-web -n default

#. Check that the pods were created

   .. code-block:: bash

      kubectl get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on BIG-IP1. Browse to: :menuselection:`Local Traffic
   --> Pools` and select the "web_pool" pool. Click the Members tab.

   .. image:: ../images/f5-hello-world-pool-scale10-as3.png

   .. attention:: Why do we still only show 3 pool members?

#. Remove Hello-World from BIG-IP.

   .. attention:: In older versions of AS3 a "blank AS3 declaration" was
      required to completely remove the application/declaration from BIG-IP. In
      AS3 v2.20 and newer this is no longer a requirement.

   .. code-block:: bash

      kubectl delete -f configmap-hello-world.yaml
      kubectl delete -f nodeport-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml

   .. note:: Be sure to verify the virtual server and "AS3" partition were
      removed from BIG-IP. This can take up to 30s.

#. Remove CIS:

   .. important:: Verify the AS3 partition is removed before running the
      following command.

   .. code-block:: bash

      kubectl delete -f nodeport-deployment.yaml

.. important:: Do not skip these clean-up steps. Instead of reusing these
   objects, the next lab we will re-deploy them to avoid conflicts and errors.
