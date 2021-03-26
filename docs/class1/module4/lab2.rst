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

#. Access your web application via firefox on the jumpbox. Open a new tab and
   browse to one of the following URL's:

   https://cafe.example.com/tea

   https://cafe.example.com/coffee

   .. note:: If prompted with an SSL certificate warning be sure to accept the
      risk and continue.

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
