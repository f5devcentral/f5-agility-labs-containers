Lab 3.1 - Deploy the NGINX Ingress Controller
=============================================

.. important:: The Kubernetes project also has an "NGINX Ingress Controller"
   that is **DIFFERENT** than the "NGINX Ingress Controller" being used in this
   lab. The Kubernetes `project`_ "NGINX Ingress Controller" is **NOT**
   supported/developed by NGINX (F5). The "`NGINX Ingress Controller`_" from
   NGINX (F5) is.

.. attention:: In this lab were simply using the free version of NGINX.

   In a customer environment, an NGINX+ container would need to be built using
   a cert and key from the `NGINX Customer Portal`_.

   Click here to see the `Key Differences`_

NGINX Ingress Controller runs two processes. One is a management plane process
that subscribes to Kubernetes API events and updates the NGINX configuration
file and/or API (for NGINX+) as needed. The second process is the data plane
NGINX or NGINX+ process.

.. note:: In this lab we are using NGINX for the data plane. This version has
   diminished capabilities (lacks enhanced health checks; faster updating of
   pods).

.. seealso:: The following steps are adapted from
   "`Installing the Ingress Controller`_".

Prep the Kubernetes Cluster
---------------------------

#. On the jumphost open a terminal and start an SSH session with kube-master1.

   .. note:: You should already have an open SSH session with kube-master1 from
      the previous module. If not follow the instructions below.

   .. image:: ../images/start-term.png

   .. code-block:: bash

      # If directed to, accept the authenticity of the host by typing "yes" and hitting Enter to continue.

      ssh kube-master1

   .. image:: ../images/sshtokubemaster1.png

#. "git" the NGINX ingress controller repo

   .. code-block:: bash

      git clone https://github.com/nginxinc/kubernetes-ingress/ --branch v2.4.2 ~/kubernetes-ingress

#. Change to the "deployments" directory of the newly cloned repo

   .. code:: bash

      cd ~/kubernetes-ingress/deployments/

Configure RBAC
--------------

#. Create NameSpace and Service Account

   The NGINX Ingress Controller runs in an isolated NameSpace and uses a
   separate ServiceAccount for accessing the Kubernetes API. Run this command
   to create the "nginx-ingress" namespace and service account:

   .. code:: bash

      kubectl apply -f common/ns-and-sa.yaml

#. In this lab environment RBAC is enabled and you will need to enable access
   from the NGINX Service Account to the Kubernetes API.

   .. code:: bash

      kubectl apply -f rbac/rbac.yaml

   .. note:: The ``ubuntu`` user is accessing the Kubernetes Cluster as a
      "Cluster Admin" and has privileges to apply RBAC permissions.

Create Common Resources
-----------------------

#. Create NGINX IC custom resource definitions for VirtualServer and
   VirtualServerRoute, TransportServer and Policy resources

   .. note:: This step is required for Module 4 - F5 IngressLink. It has no
      affect on this module and the basic Nginx Ingress Controller deployment
      we're creating.

   .. code-block:: bash

      kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
      kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
      kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
      kubectl apply -f common/crds/k8s.nginx.org_policies.yaml

#. The Ingress Controller will use a "default" SSL certificate for requests
   that are not configured to use an explicit certificate. The following loads
   the default certificate into Kubernetes:

   .. code:: bash

      kubectl apply -f common/default-server-secret.yaml

   .. note:: NGINX docs state "For testing purposes we include a self-signed
      certificate and key that we generated. However, we recommend that you use
      your own certificate and key."

#. Create a NGINX ConfigMap

   .. code:: bash

      kubectl apply -f common/nginx-config.yaml

   .. note:: NGINX Ingress Controller makes use of a Kubernetes ConfigMap to
      store customizations to the NGINX+ configuration. Configuration
      snippets/directives can be passed into the ``data`` section or a set of
      NGINX and NGINX+ annotations are `available`_.

#. Create an IngressClass resource

   .. code:: bash

      kubectl apply -f common/ingress-class.yaml

   .. warning:: The Ingress Controller will fail to start without an
      IngressClass resource. This applies to Kubernetes >= v1.18.

Create a Deployment
-------------------

We will be deploying NGINX as a deployment. There are two options:

- Deployment. Use a Deployment if you plan to dynamically change the number of
  Ingress controller replicas.
- DaemonSet. Use a DaemonSet for deploying the Ingress controller on every node
  or a subset of nodes.

#. Deploy NGINX

   .. code:: bash

      kubectl apply -f deployment/nginx-ingress.yaml

#. Verify the deployment

   .. code:: bash

      kubectl get pods -n nginx-ingress

   You should see output similar to:

   .. image:: ../images/nginx-deployment.png

   .. attention:: Be patient this step will talk a few minutes before the nginx
      deployment is "Running" and ready to use.

Expose NGINX via NodePort
-------------------------

Finally we need to enable external access to the Kubernetes cluster by defining
a ``service``. We will create a NodePort service to enable access from outside
the cluster. This will create an ephemeral port that will map to port 80/443 on
the NGINX Ingress Controller.

#. Create NodePort service

   .. code:: bash

      kubectl create -f service/nodeport.yaml

#. Retrieve NodePort

   .. code:: bash

      kubectl get svc -n nginx-ingress

   .. image:: ../images/nginx-service.png

   In the example above port 32251 maps to port 80 on NGINX.

   .. important:: You will have a different port value! Record the value for
      the next lab exercise.

Access NGINX From Outside the Cluster
-------------------------------------

#. From the Jumpbox open up the Chrome browser and browse to "kube-master1"
   host IP and the previously recorded port.

   ``http://10.1.1.7:32251``

   .. warning:: You will have a different port value!

   You should see something like this:

   .. image:: ../images/nginx-nodeport.png

   .. note:: NGINX docs state "The default server returns the Not Found page
      with the 404 status code for all requests for domains for which there are
      no Ingress rules defined." We've not yet configured any services to use
      the NGINX Ingress Controller.

.. _`project`: https://github.com/kubernetes/ingress-nginx
.. _`NGINX Ingress Controller`: https://github.com/nginxinc/kubernetes-ingress
.. _`NGINX Customer Portal`: https://cs.nginx.com
.. _`Key Differences`: https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/nginx-ingress-controllers.md
.. _`Installing the Ingress Controller`: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
.. _`available`: https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/configmap-resource/
