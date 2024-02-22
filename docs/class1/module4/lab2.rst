Lab 4.2 - Deploy the Cafe Application
=====================================

#. Go back to the Web Shell session you opened in the previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   to connect to **kube-master1** using the **Web Shell** access method, then switch to the **ubuntu** 
   user account using the "**su**" command:

   .. image:: ../images/WEBSHELL.png

   .. image:: ../images/WEBSHELLroot.png

   .. code-block:: bash

      su ubuntu

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

Now let's test access to the new web application "*through*"" **Firefox** on **superjump**.

#. Go back to the Firefox session you opened in a previous task. If you need to open a new session,
   browse back to the **Deployment** tab of your UDF lab session at
   https://udf.f5.com and connect to **superjump** using the **Firefox** access method.

   .. note:: The web application is not directly accessible from the public Internet.
      But since the **superjump** system is connected to the same internal virtual lab network 
      we can use the **Firefox** access method because it provides *browser-in-a-browser*
      functionality that allows remote browsing to this new private web site.

   .. image:: ../images/udffirefox.png

#. Open a new tab an browse to one of the following URL's:

   - https://cafe.example.com/tea

   - https://cafe.example.com/coffee

   .. note:: If prompted with an SSL certificate warning be sure to accept the
      risk and continue.

   You should see something similar to the following:

   .. image:: ../images/cafe-example-com-cofee.png

   .. image:: ../images/cafe-example-com-tea.png

   .. attention::

      Server address: The application pod IP

      Remote addr: The NGINX Ingress IP

      X-Real-IP: The client IP making the request

#. Before starting the next class run the following commands to clean-up the BIG-IP and exit the session from kube-master1.

   .. code-block:: bash

      kubectl delete -f ingresslink/vs-ingresslink.yaml
      kubectl delete -f ingresslink/ingresslink-deployment.yaml
      
.. attention:: This is a **CRITICAL** step if you're moving on to the next lab.

.. attention:: This concludes **Class 1 - CIS and Kubernetes**. Feel free to
   experiment with any of the settings. The lab will be destroyed at the end of
   the class/day.
