Lab 4.1 - Configure F5 IngressLink with Kubernetes
=============================================

The F5 IngressLink is addressing modern app delivery at scale/large. IngressLink is a resource definition defined between BIG-IP and Nginx using F5 Container Ingress Service and Nginx Ingress Service. The purpose of this lab is to demonstrates the configuration and steps required to Configure Ingresslink

F5 IngressLink is the first true integration between BIG-IP and NGINX technologies. F5 IngressLink was built to support customers with modern, container application workloads that use both BIG-IP Container Ingress Services and NGINX Ingress Controller for Kubernetes. It’s an elegant control plane solution that offers a unified method of working with both technologies from a single interface—offering the best of BIG-IP and NGINX and fostering better collaboration across NetOps and DevOps teams.

.. attention:: This architecture diagram demonstrates the IngressLink solution

.. image:: ../images/ingresslink-architecture-diagram.png

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

As before all the necessary files are on **kube-master1** in 
~/agilitydocs/docs/class4/lab-files

BIG-IP Setup
------------

This lab is using the same BIG-IP setup from Lab 2.1 - Install & Configure CIS in ClusterIP. With ClusterIP we're utilizing VXLAN to communicate with the NGINX pods. 

#. Add proxy-protocol irule to BIG-IP

   Proxy Protocol is required by NGINX to provide the applications PODs with the original client IPs. Use the following steps to configure the Proxy_Protocol_iRule

   * Login to BigIp GUI 
   * On the Main tab, click Local Traffic > iRules.
   * Click Create.
   * In the Name field, type name as "Proxy_Protocol_iRule".
   * In the Definition field, Copy the definition from "Proxy_Protocol_iRule" file. Click Finished

CIS Deployment for IngressLink
--------------

#. Install the CIS Controller for IngressLink

Create CIS IngressLink Custom Resource definition schema as follows:

    kubectl create -f ingresslink-customresourcedefinition.yaml

cis-crd-schema [repo](https://github.com/mdditt2000/kubernetes-1-19/blob/master/cis%202.3/ingresslink/cis/ingresslink/cis-crd-schema/ingresslink-customresourcedefinition.yaml)

Update the bigip address, partition and other details(image, imagePullSecrets, etc) in CIS deployment file and Install CIS Controller in ClusterIP mode as follows:

* Add the following statements to the CIS deployment arguments for Ingresslink

    - "--custom-resource-mode=true"
    - "--ingress-link-mode=true"



   Follow tLab 2.1 - Install & Configure CIS in ClusterIP

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

#. Create an IngressClass resource

   .. code:: bash

      kubectl apply -f common/ingress-class.yaml

   .. warning:: The Ingress Controller will fail to start without an
      IngressClass resource.
   
   .. note:: For Kubernetes >= 1.18

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
