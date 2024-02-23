Lab 2.2 - Deploy Hello-World Using Ingress
==========================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/deployment-hello-world.yaml
      :language: yaml
      :caption: deployment-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``clusterip-service-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/clusterip-service-hello-world.yaml
      :language: yaml
      :caption: clusterip-service-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,17

#. Create a file called ``ingress-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class1/kubernetes

   .. literalinclude:: ../kubernetes/ingress-hello-world.yaml
      :language: yaml
      :caption: ingress-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7-9,29,31

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f deployment-hello-world.yaml
      kubectl create -f clusterip-service-hello-world.yaml
      kubectl create -f ingress-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-app-ingress2.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      kubectl get pods -o wide

   .. image:: ../images/f5-hello-world-pods3.png

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/f5-cis-describe-clusterip-service2.png

   .. attention:: To understand and test the new app pay attention to the
      **Endpoints value**, this shows our 2 instances (defined as replicas in
      our deployment file) and the flannel IP assigned to the pod.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on BIG-IP1. Go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   and connect to **BIG-IP1** using the **TMUI** access method.

   .. image:: ../images/TMUI.png

#. Login with username: **admin** and password: **admin**.

   .. image:: ../images/TMUILogin.png

#. Browse to: :menuselection:`Local Traffic --> Virtual Servers`

   .. warning:: Don't forget to select the "kubernetes" partition or you'll
      see nothing.

   Here you can see a new Virtual Server, "**ingress_10.1.1.4_80**" was created,
   listening on **10.1.1.4:80** in partition "**kubernetes**".

   .. image:: ../images/f5-container-connector-check-app-ingress2.png

#. Check the Pools to see a new pool and the associated pool members.

   Browse to: :menuselection:`Local Traffic --> Pools` and select the
   "**ingress_default_f5-hello-world-web**" pool. Click the Members tab.

   .. image:: ../images/f5-container-connector-check-app-ingress-pool2.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Access your web application via **Firefox** on the **superjump**.

   .. note:: Select the "Hello, World" shortcut or type http://10.1.1.4 in the
      URL field.

   .. image:: ../images/f5-container-connector-access-app.png

#. To check traffic distribution, hit Refresh many times on your open browser
   session. Then go back to the open BIG-IP TMUI management console on firefox.

   Browse to: :menuselection:`Local Traffic --> Pools --> Pool list --> ingress_default_f5-hello-world-web --> Statistics`

   .. image:: ../images/f5-container-connector-check-app-bigip-stats-ingress-clusterip.png

   .. note:: Are you seeing traffic distribution as shown in the image above?
      If not why? (HINT: Check the virtual server settings.)

#. Delete Hello-World

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.

   .. code-block:: bash

      kubectl delete -f ingress-hello-world.yaml
      kubectl delete -f clusterip-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml

   .. attention:: Validate the objects are removed via the management console.
      :menuselection:`Local Traffic --> Virtual Servers`
