Lab 3.2 - Deploy Hello-World (Again)
====================================

In the previous modules we deployed f5-hello-world behind CIS using NodePort
and ClusterIP modes with Ingress and ConfigMap resources. In this lab we will
deploy the f5-hello-world, yet again, but behind the NGINX kubernetes ingress
controller using ClusterIP.

App Deployment
--------------

As before all the necesary files are on **kube-master1** in
~/agilitydocs/docs/class1/kubernetes

#. Go back to the Web Shell session you opened in the previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   to connect to **kube-master1** using the **Web Shell** access method, then switch to the **ubuntu** 
   user account using the "**su**" command:

   .. image:: ../images/WEBSHELL.png

   .. image:: ../images/WEBSHELLroot.png

   .. code-block:: bash

      su ubuntu

#. Set the working directy with the yaml file repository with the following "**cd**" command. 

   .. code-block:: bash

      cd ~/agilitydocs/docs/class1/kubernetes

#. Review hello-world deployment ``deployment-hello-world.yaml``

   .. note:: In all our examples we've used the same deployment to create our
      pods.

   .. literalinclude:: ../kubernetes/deployment-hello-world.yaml
      :language: yaml
      :caption: deployment-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Review hello-world service ``clusterip-service-hello-world.yaml``

   .. note:: Here we're not interested in the CIS annotation of the file as
      before. We're simply reusing the same service for NGINX Ingress to create
      the proper endpoints.

   .. literalinclude:: ../kubernetes/clusterip-service-hello-world.yaml
      :language: yaml
      :caption: clusterip-service-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,4

#. Review hello-world NGINX service ``nginx-ingress-hello-world.yaml``

   .. note:: This create's our app on NGINX. You can see in line 16 and 18 how
      we reference the previouly created hello-world service by name and port.
      On line 9 we define the expected host header. Just as before this host is
      in the local host file (/etc/hosts) and will be needed to access to the
      app.

   .. literalinclude:: ../kubernetes/nginx-ingress-hello-world.yaml
      :language: yaml
      :caption: nginx-ingress-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,9,16,18

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f deployment-hello-world.yaml
      kubectl create -f clusterip-service-hello-world.yaml
      kubectl create -f nginx-ingress-hello-world.yaml

   .. image:: ../images/nginx-ingress-launch-app.png

#. At this point hello-world is not externally accessible but we can check the
   status of our service.

   .. code-block:: bash

      kubectl describe svc f5-hello-world

   .. image:: ../images/hello-world-svc.png

CIS Service & Deployment
------------------------

In order to deploy the virtual service on BIG-IP we need to create and deploy
two files, a service and configmap.

#. Review cis service file ``cis-service.yaml``

   .. note:: In this case the labels are important and must match our configmap
      declaration.

   .. important:: The namespace of this service and deployment below must
      match due to changes in CIS v2.1.

   .. important:: Starting with CIS v2.2.2, AS3 ConfigMap expects servicePort
      to match the port (not the nodeport) exposed in the service definition.
      See line 13 here and line 39 in the AS3 declaration below.

   .. literalinclude:: ../kubernetes/cis-service.yaml
      :language: yaml
      :caption: cis-service.yaml
      :linenos:
      :emphasize-lines: 2,5,7-9,13,18

#. Review CIS configmap file ``cis-configmap.yaml``

   .. note:: In this case the labels are important and must match our configmap
      declaration.

   .. important:: The namespace of this deploymnent and service above must
      match due to changes in CIS v2.1.

   .. tip:: In all of our AS3 examples you'll notice the declaration is
      the same. This make the use of AS3 highly portable.

   .. literalinclude:: ../kubernetes/cis-configmap.yaml
      :language: yaml
      :caption: cis-configmap.yaml
      :linenos:
      :emphasize-lines: 2,5,19,21,32,39

#. Create the service and deployment

   .. code-block:: bash

      kubectl create -f cis-service.yaml
      kubectl create -f cis-configmap.yaml

#. To check the status of our service run the following command:

   .. code-block:: bash

      kubectl describe svc nginx-ingress-hello-world -n nginx-ingress

   .. image:: ../images/nginx-ingress-endpoint.png

   .. attention:: As the previous modules pointed out we need to focus on the
      **Endpoints value**, this shows our one NGINX instance (defined as
      replicas in our NGINX deployment file) and the flannel IP assigned to the
      pod. To confirm the NGINX endpoint IP use the following command:

      .. code-block:: bash

         kubectl get pods -n nginx-ingress -o wide

      .. image:: ../images/nginx-pod-ip.png

#. Now that we have deployed our application sucessfully, we can check the
   configuration on BIG-IP1. 
   Go back to the TMUI session you opened in a previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   and connect to **BIG-IP1** using the **TMUI** access method (*username*: **admin** and *password*: **admin**)

   .. image:: ../images/TMUI.png

   .. image:: ../images/TMUILogin.png

#. Browse to: :menuselection:`Local Traffic --> Virtual Servers`

   .. warning:: Don't forget to select the proper partition. In this case we
      need to look at the "**AS3**" partition because we're using AS3. This
      partition was auto created by AS3 and named after the Tenant which
      happens to be "**AS3**".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

   Here you can see a new Virtual Server, "**serviceMain**" was created,
   listening on **10.1.1.4:80** in partition "**AS3**".

#. Check the Pools to see a new pool and the associated pool members.

   Browse to: :menuselection:`Local Traffic --> Pools` and select the
   "web_pool" pool. Click the Members tab.

   .. image:: ../images/nginx-cis-web_pool.png

   .. note:: You can see that the pool members IP address is the NGINX pod IP.

#. Access your web application via **Firefox** on the **superjump**.

   .. note:: Select the "mysite.f5demo.com" shortcut.

   .. image:: ../images/nginx-access-app.png

   .. attention:: In this case you can't simply type the IP for the URL. NGINX
      is looking for a specific HOST header to properly direct the traffic to
      the right application pod.

#. Remove Hello-World from BIG-IP.

   .. code-block:: bash

      kubectl delete -f cis-configmap.yaml
      kubectl delete -f cis-service.yaml

   .. note:: Be sure to verify the virtual server and "AS3" partition were
      removed from BIG-IP.

#. Remove Hello-World from NGINX

   .. code-block:: bash

      kubectl delete -f nginx-ingress-hello-world.yaml
      kubectl delete -f clusterip-service-hello-world.yaml
      kubectl delete -f deployment-hello-world.yaml

#. Remove CIS

   .. code-block:: bash

      kubectl delete -f cluster-deployment.yaml

.. important:: Do not skip these clean-up steps. Instead of reusing these
   objects, the next lab we will re-deploy them to avoid conflicts and errors.
