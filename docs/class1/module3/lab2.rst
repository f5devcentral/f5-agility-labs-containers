Lab 3.2 - Deploy Hello-World (Again)
====================================

In the previous modules we deployed f5-hello-world behind CIS using NodePort
and ClusterIP with Ingress and ConfigMap w/ AS3. In this lab we will deploy
the f5-hello-world yet again but behind the NGINX kubernetes ingress
controller using ClusterIP.

App Deployment
--------------

As before all the necesary files are on **kube-master1** in 
~/agilitydocs/docs/class1/kubernetes

#. Start SSH session to kube-master1 if not already done so.

   .. note:: You should have an open session from previous lab.

#. Change working directory to the yaml file repository.

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
      before. We're simply reusing the same service for Nginx Ingress to create
      the proper endpoints.

   .. literalinclude:: ../kubernetes/clusterip-service-hello-world.yaml
      :language: yaml
      :caption: clusterip-service-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,4

#. Review hello-world nginx service ``nginx-ingress-hello-world.yaml``

   .. note:: This create's our app on Nginx. You can see in line 14 and 15 how
      we reference the previouly created hello-world service by name and port.
      On line 9 we define the expected host header. Just as before this host is
      in the local host file (/etc/hosts) and will be needed to access to the
      app.

   .. literalinclude:: ../kubernetes/nginx-ingress-hello-world.yaml
      :language: yaml
      :caption: nginx-ingress-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,9,14,15

#. We can now launch our application:

   .. code-block:: bash

      kubectl create -f deployment-hello-world.yaml
      kubectl create -f clusterip-service-hello-world.yaml
      kubectl create -f nginx-ingress-hello-world.yaml

   .. image:: ../images/nginx-ingress-launch-app.png

#. We can view the status of our deployment on the Nginx dashboard via firefox
   on the jumpbox.

   .. attention:: The port in the URL will differ from my example. To find the
      correct port run the following command:

      .. code-block:: bash

         kubectl describe svc nginx-ingress-dashboard -n nginx-ingress

      .. image:: ../images/nginx-dashboard-port.png

   Open firefox and browse to http://10.1.1.7:32837/dashboard.html. On the
   "HTTP Zones" and HTTP Upstreams" pages we can see the newly deployed web
   app.

   .. image:: ../images/nginx-hello-world.png

CIS Service & Deployment
------------------------

In order to deploy the virtual service on BIG-IP we need to create and deploy
two files, a service and configmap.

#. Review cis service file ``cis-service.yaml``

   .. note:: In this case the labels are important and must match our configmap
      declaration.

   .. important:: The namespace of this service and deploymnent below must
      match due to changes in CIS v2.1.

   .. literalinclude:: ../kubernetes/cis-service.yaml
      :language: yaml
      :caption: cis-service.yaml
      :linenos:
      :emphasize-lines: 2,5,7-9,18

#. Review CIS configmap file ``cis-configmap.yaml``

   .. note:: In this case the labels are important and must match our configmap
      declaration.

   .. important:: The namespace of this deploymnent and service above must
      match due to changes in CIS v2.1.

   .. important:: In all of our AS3 examples you'll notice the declaration is
      the same. This make the use of AS3 highly portable.

   .. literalinclude:: ../kubernetes/cis-configmap.yaml
      :language: yaml
      :caption: cis-configmap.yaml
      :linenos:
      :emphasize-lines: 2,5,19,21,32

#. Create the service and deployment

   .. code-block:: bash

      kubectl create -f cis-service.yaml
      kubectl create -f cis-configmap.yaml

#. To check the status of our deployment, run the following command:

   .. code-block:: bash

      kubectl describe svc nginx-ingress-hello-world -n nginx-ingress

   .. image:: ../images/nginx-ingress-endpoint.png

   .. attention:: As the previous modules pointed out we need to focus on the
      **Endpoints value**, this shows our one NGINX instance (defined as
      replicas in our nginx deployment file) and the flannel IP assigned to the
      pod. To confirm the nginx endpoint IP use the following command:

      .. code-block:: bash

         kubectl get pod -n nginx-ingress -o wide

      .. image:: ../images/nginx-pod-ip.png

#. Now that we have deployed our application sucessfully, we can check the
   configuration on bigip1. Switch back to the open management session on
   firefox.

   .. warning:: Don't forget to select the proper partition. In this case we
      need to look at the "AS3" partition because we're using AS#. This
      partition was auto created by AS3 and named after the Tenant which
      happens to be "AS3".

   GoTo: :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see a new Virtual Server, "serviceMain" was created,
   listening on 10.1.1.4:80 in partition "AS3".

   .. image:: ../images/f5-container-connector-check-app-bigipconfig-as3.png

#. Check the Pools to see a new pool and the associated pool members.

   GoTo: :menuselection:`Local Traffic --> Pools` and select the
   "web_pool" pool. Click the Members tab.

   .. image:: ../images/nginx-cis-web_pool.png

   .. note:: You can see that the pool members IP addresse is the nginx pod IP.

#. Access your web application via firefox on the jumpbox.

   .. note:: Select the "mysite.f5demo.com" shortcut.

   .. image:: ../images/nginx-access-app.png

   .. attention:: In this case you can't simply type the IP for the URL. Nginx
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

#. Before starting the next class exit the session from kube-master1 and go
   back to the jumpbox.

   .. code-block:: bash

      exit

.. attention:: This concludes **Class 1 - CIS and Kubernetes**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
