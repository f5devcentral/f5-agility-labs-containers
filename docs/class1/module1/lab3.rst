Lab 1.3 - Deploy Hello-World Using ConfigMap w/ AS3
===================================================

Just like the previous lab we'll deploy the f5-hello-world docker container.
But instead of using the Ingress resource we'll use ConfigMap.

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

- Define the **ConfigMap** resource: this can be used to store fine-grained
  information like individual properties or coarse-grained information like
  entire config files  or JSON blobs. It will contain the BIG-IP configuration
  we need to push.

.. attention:: The steps are generally the same as the previous lab, the big
   difference is the two resource types. Your **Deployment** and **Service**
   definitions are the same file.

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/deployment-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``nodeport-service-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/nodeport-service-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,8-10,17

#. Create a file called ``configmap-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/configmap-hello-world.yaml
      :language: yaml
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

   .. image:: ../images/f5-hello-world-pods.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-container-connector-check-app-definition-configmap.png

   .. attention:: To understand and test the new app pay attention to the
      **NodePort value**, that's the port used to give you access to the app
      from the outside. Here it's "31233", highlighted above.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on bigip1. We should still have access to TMUI via UDF go back
   to the open session.

   .. warning:: Don't forget to select the proper partition. Previously we
      checked the "kubernetes" partition. In this case we need to look at
      the "AS3" partition. This partition was auto created by AS3 and named
      after the Tenant which happens to be "AS3".

   Goto :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see a new Virtual Server, "serviceMain" was created,
   listening on 10.1.1.4:80 in partition "AS3".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

#. Check the Pools to see a new pool and the associated pool members:
   :menuselection:`Local Traffic --> Pools --> "web_pool" --> Members`

   .. image:: ../images/f5-container-connector-check-app-pool-as3.png

   .. note:: You can see that the pool members listed are all the cluster
      nodes on the node port 31233. (**NodePort mode**)

#. Access your web application via UDF-URL.

   .. note:: This URL can be found on the UDF student portal

   .. image:: ../images/f5-container-connector-access-app.png

#. Hit Refresh many times and go back to your **BIG-IP** UI

   Goto: :menuselection:`Local Traffic --> Pools --> Pool list -->
   "web_pool" --> Statistics` to see that traffic is distributed as expected.

   .. image:: ../images/f5-container-connector-check-app-bigip-stats-as3.png

   .. note:: Why is all the traffic directed to one pool member?
   
#. Scale the f5-hello-world app

   .. code-block:: bash

      kubectl scale --replicas=10 deployment/f5-hello-world-web -n default

#. Check that the pods were created

   .. code-block:: bash

      kubectl get pods

   .. image:: ../images/f5-hello-world-pods-scale10.png

#. Check the pool was updated on bigip1

   .. image:: ../images/f5-hello-world-pool-scale10-as3.png

   .. attention:: Why do we still only show 3 pool members?

#. Remove Hello-World from BIG-IP. 

   .. important:: When using AS3 an extra step needs to be performed. In
      addition to deleting the application configmap, a "blank AS3 declaration"
      is required to completely remove the application from BIG-IP.
   
   "Blank AS3 Declartion"
   
   .. literalinclude:: ../kubernetes/delete-hello-world.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,19

   .. code-block:: bash

      kubectl delete -f configmap-hello-world.yaml
      kubectl delete -f nodeport-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml

      kubectl create -f delete-hello-world.yaml
      kubectl delete -f delete-hello-world.yaml

   .. note:: Be sure to verify the virtual server and "AS3" partition were
      removed from BIG-IP.

#. Remove CIS:

   .. code-block:: bash

      kubectl delete -f nodeport-deployment.yaml

.. important:: Do not skip these clean-up steps. Instead of reusing these
   objects, the next lab we will re-deploy them to avoid conflicts and errors.
