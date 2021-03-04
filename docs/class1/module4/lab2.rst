Lab 4.2 - Deploy the Cafe Application
=============================================

#. Create the coffee and the tea deployments and services:

   .. code:: bash

      kubectl create -f cafe.yaml

#.  Configure Load Balancing for the Cafe Application. Create a secret with an SSL certificate and a key:

   .. code:: bash

      kubectl create -f cafe-secret.yaml

#. Create an Ingress resource:

   .. code:: bash

      kubectl create -f cafe-ingress.yaml

Test the Application
=============================================

#. To access the application, curl the coffee and the tea services. We'll use curl's --insecure option to 
   turn off certificate verification of our self-signed certificate and the --resolve option to set the Host header of a request with cafe.example.com

#. To get coffee:

   .. code:: bash

      $ curl --resolve cafe.example.com:$IC_HTTPS_PORT:$IC_IP https://cafe.example.com:$IC_HTTPS_PORT/coffee --insecure
      Server address: 10.12.0.18:80
      Server name: coffee-7586895968-r26zn
      If your prefer tea:

      $ curl --resolve cafe.example.com:$IC_HTTPS_PORT:$IC_IP https://cafe.example.com:$IC_HTTPS_PORT/tea --insecure
      Server address: 10.12.0.19:80
      Server name: tea-7cd44fcb4d-xfw2x
      Get the cafe-ingress resource to check its reported address:

.. code:: bash

      $ kubectl get ing cafe-ingress
      NAME           HOSTS              ADDRESS         PORTS     AGE
      cafe-ingress   cafe.example.com   35.239.225.75   80, 443   115s
      As you can see, the Ingress Controller reported the BIG-IP IP address (configured in IngressLink resource) in the ADDRESS field of the Ingress status