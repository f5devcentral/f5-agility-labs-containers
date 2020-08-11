Lab 3.1 - Deploy the NGINX Ingress Controller
=============================================

.. important:: The Kubernetes project also has an "NGINX Ingress Controller"
   that is **DIFFERENT** than the "NGINX Ingress Controller" that
   is being used in this lab. The Kubernetes `project`_ "NGINX Ingress
   Controller" is **NOT** supported/developed by NGINX (F5). The
   "`NGINX Ingress Controller`_" from NGINX (F5) is.

.. note:: In the lab environment NGINX+ has been already built into an
   container image and is installed on the worker nodes.

   In a customer environment, an NGINX+ container would need to be built using
   a cert and key from the `NGINX Customer Portal`_.

NGINX Ingress Controller runs two processes. One is a management plane process
that subscribes to Kubernetes API events and updates the NGINX configuration
file and/or API (for NGINX+) as needed. The second process is the data plane
NGINX or NGINX+ process.

.. note:: In this lab we are using NGINX+ for the data plane. NGINX Ingress
   can also use open source NGINX with diminished capabilities (lacks enhanced
   health checks; faster updating of pods).

.. seealso:: The following steps are adapted from
   "`Installing the Ingress Controller`_".

Prep the Kubernetes Cluster
---------------------------

#. On the jumphost open a terminal and start an SSH session with kube-master1.

   .. image:: ../images/start-term.png

   .. code-block:: bash

      # If directed to, accept the authenticity of the host by typing "yes" and hitting Enter to continue.

      ssh kube-master1

   .. image:: ../images/sshtokubemaster1.png

#. "git" the NGINX ingress controller repo

   .. code-block:: bash

      git clone https://github.com/nginxinc/kubernetes-ingress/ ~/kubernetes-ingress

#. Change to the "deployments" directory of the newly cloned repo

   .. code:: bash

      cd ~/kubernetes-ingress/deployments/

Configure RBAC
--------------

#. Create NameSpace and Service Account

   The NGINX Ingress Controller runs in an isolated NameSpace and uses a separate 
   ServiceAccount for accessing the Kubernetes API. Run this command to create the
   "nginx-ingress" namespace and service account:

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

Create a Deployment
-------------------

We will be deploying NGINX+ as a deployment. There are two options:

- Deployment. Use a Deployment if you plan to dynamically change the number of
  Ingress controller replicas.
- DaemonSet. Use a DaemonSet for deploying the Ingress controller on every node
  or a subset of nodes.

#. Modify nginx-plus-ingress.yaml to use local copy of nginx+

   .. code:: bash

      vim deployment/nginx-plus-ingress.yaml

   .. note:: This lab came pre-configured with a working licensed copy of
      NGINX+. In your environment you **MUST** modify this file to use your
      working licensed copy of NGINX+, otherwise deploying will fail.

#. Deploy NGINX

   .. code:: bash

      kubectl apply -f deployment/nginx-plus-ingress.yaml
   
#. Verify the deployment

   .. code:: bash

      kubectl get po -n nginx-ingress
   
   You should see output similar to:

   .. code:: bash
   
      NAME                            READY   STATUS    RESTARTS   AGE
      nginx-ingress-56454fb6d-c5hl6   1/1     Running   0          44m
  
Expose NGINX+ via NodePort
--------------------------

Finally we need to enable external access to the Kubernetes cluster by defining
a ``service``. We will create a NodePort service to enable access from outside
the cluster. This will create an ephemeral port that will map to port 80/443 on
the NGINX+ Ingress Controller.

#. Create NodePort service

   .. code:: bash

      kubectl create -f service/nodeport.yaml

#. Retrieve NodePort 

   .. code:: bash

      kubectl get svc -n nginx-ingress

   You should see output similar to the following (your port values will be
   different):

   .. code:: bash

      ubuntu@kube-master1:~/kubernetes-ingress/deployments$ kubectl get svc -n nginx-ingress
      NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
      nginx-ingress   NodePort   10.96.35.249   <none>        80:32164/TCP,443:32562/TCP   6s

   In the example above port 32164 maps to port 80 on NGINX+.

   .. important:: You will have a different port value! Record the value for
      the next lab exercise.

Access NGINX+ From Outside the Cluster
--------------------------------------

#. From the Jumpbox open up the Chrome browser and browse to "kube-master1"
   host IP and the previously recorded port.

   ``http://10.1.1.7:32164``

   .. warning:: You will have a different port value!

   You should see something like this:

   .. image:: ../images/nginx-plus-nodeport.png

   .. note:: NGINX docs state "The default server returns the Not Found page
      with the 404 status code for all requests for domains for which there are
      no Ingress rules defined." We've not yet configured any services to use
      the NGINX+ Ingress Controller.

.. _`NGINX Customer Portal`: https://cs.nginx.com
.. _`Installing the Ingress Controller`: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
.. _`available`: https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/configmap-and-annotations.md
.. _`project`: https://github.com/kubernetes/ingress-nginx
.. _`NGINX Ingress Controller`: https://github.com/nginxinc/kubernetes-ingress
