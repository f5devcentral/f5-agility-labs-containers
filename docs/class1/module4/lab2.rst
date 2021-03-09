Lab 4.2 - Deploy the Cafe Application
=====================================

#. Create the coffee and tea deployments and services

   .. code-block:: bash

      kubectl create -f cafe-example/cafe.yaml

#. Create a secret with an SSL CERT and KEY for the Cafe app

   .. code-block:: bash

      kubectl create -f cafe-example/cafe-secret.yaml

#. Create the Ingress resource

   .. code-block:: bash

      kubectl create -f cafe-example/cafe-ingress.yaml

Test the Application
--------------------

To access the application we'll use the browser on the jumpbox.

#. First we'll verify the pool member consist of one IP and it matches the
   NGINX ingress controller. To find the IP run the following command and take
   note of the Endpoint IP.

   .. code-block:: bash

      kubectl describe svc nginx-ingress-ingresslink -n nginx-ingress

   .. image:: ../images/nginx-ingresslink-svc.png

   .. note:: Your Endpoint/IP will most likely be different.

#. Switch back to the jumpbox and start Firefox. Open the BIGIP mgmt console.

   .. warning:: Don't forget to select the "kubernetes" partition or you'll
      see nothing.

   GoTo: :menuselection:`Local Traffic --> Virtual Servers`

   Here you can see two new Virtual Servers, "ingress_link_crd_10.1.1.4_80" and
   "ingress_link_crd_10.1.1.4_443" was created, in partition "kubernetes".

   .. image:: ../images/ingress-link-vs.png

#. Check the Pools to see a new pool and the associated pool members.

   GoTo: :menuselection:`Local Traffic --> Pools` and select either 
   "nginx_ingress_nginx_ingress_ingresslink" pool. Both have the same pool
   member but are running on different ports. Click the Members tab.

   .. image:: ../images/ingress-link-pool.png

   .. note:: You can see that the pool member listed is the same Endpoint/IP
      discovered in the earlier step above.

#. Access your web application via firefox on the jumpbox. Open a new tab and
   browse to one of the following URL's:

   https://cafe.example.com/tea
   
   https://cafe.example.com/coffee

   You should see something similar to the following:

   .. image:: ../images/cafe-example-com-cofee.png

   .. image:: ../images/cafe-example-com-tea.png

   .. attention::
      
      Server address: The application pod IP

      Remote addr: The NGINX Ingress IP

      X-Real-IP: The client IP making the request

#. Before starting the next class exit the session from kube-master1 and go
   back to the jumpbox.
   
   .. code-block:: bash
   
      exit
   
.. attention:: This concludes **Class 1 - CIS and Kubernetes**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
