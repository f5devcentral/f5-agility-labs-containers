Lab 4.1 - Configure F5 IngressLink with Kubernetes
=============================================

The F5 IngressLink is addressing modern app delivery at scale/large. IngressLink is a resource definition defined between BIG-IP and Nginx using F5 Container Ingress Service and Nginx Ingress Service. The purpose of this lab is to demonstrates the configuration and steps required to Configure Ingresslink

F5 IngressLink is the first true integration between BIG-IP and NGINX technologies. F5 IngressLink was built to support customers with modern, container application workloads that use both BIG-IP Container Ingress Services and NGINX Ingress Controller for Kubernetes. It’s an elegant control plane solution that offers a unified method of working with both technologies from a single interface—offering the best of BIG-IP and NGINX and fostering better collaboration across NetOps and DevOps teams.

.. This architecture diagram demonstrates the IngressLink solution

.. image:: ../images/ingresslink-architecture-diagram.png

Prep the Kubernetes Cluster
---------------------------

#. On the jumphost open a terminal and start an SSH session with kube-master1.

   .. You should already have an open SSH session with kube-master1 from
      the previous module

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

#. Create CIS IngressLink Custom Resource definition schema as follows:

.. code:: bash

    kubectl create -f ingresslink-customresourcedefinition.yaml

#. Deploy CIS Deployment

   .. note:: Follow Lab 2.1 - Install & Configure CIS in ClusterIP

* Add the following statements to the CIS deployment arguments for Ingresslink

  .. code:: bash

    - "--custom-resource-mode=true"
    - "--ingress-link-mode=true"

   .. code:: bash

      kubectl create -f f5-cis-deployment.yaml


NGINX IC Deployment for IngressLink
--------------

### Nginx-Controller Installation

   #. Create NGINX IC custom resource definitions for VirtualServer and VirtualServerRoute, TransportServer and Policy resources:

   .. code-block:: bash

      kubectl apply -f k8s.nginx.org_virtualservers.yaml
      kubectl apply -f k8s.nginx.org_virtualserverroutes.yaml
      kubectl apply -f k8s.nginx.org_transportservers.yaml
      kubectl apply -f k8s.nginx.org_policies.yaml

#. Create a namespace and a service account for the Ingress controller:

   .. code:: bash
   
      kubectl apply -f nginx-config/ns-and-sa.yaml
   
#. Create a cluster role and cluster role binding for the service account:

   .. code:: bash
   
      kubectl apply -f nginx-config/rbac.yaml
   
#. Create a secret with a TLS certificate and a key for the default server in NGINX:

   .. code:: bash

      kubectl apply -f nginx-config/default-server-secret.yaml
    
#. Create a config map for customizing NGINX configuration:

   .. code:: bash

      kubectl apply -f nginx-config/nginx-config.yaml
    
   Create an IngressClass resource (for Kubernetes >= 1.18):  
    
    kubectl apply -f nginx-config/ingress-class.yaml

#. Use a Deployment. When you run the Ingress Controller by using a Deployment, by default, Kubernetes     
   will create one Ingress controller pod.

   .. code:: bash
    
      kubectl apply -f nginx-config/nginx-ingress.yaml
  
#. Create a service for the Ingress Controller pods for ports 80 and 443 as follows:

   .. code:: bash

      kubectl apply -f nginx-config/nginx-service.yaml

Verify the deployment
-------------------
   
#. Verify the deployment

   .. code:: bash

      kubectl get pods -n nginx-ingress
   
   You should see output similar to:

   .. image:: ../images/nginx-deployment.png

Create an IngressLink Resource
-------------------

#. Update the ip-address in IngressLink resource and iRule which is created in Step-1. This ip-address 
   will be used to configure the BIG-IP device to load balance among the Ingress Controller pods.

   .. code:: bash

      kubectl apply -f vs-ingresslink.yaml

   .. note: The name of the app label selector in IngressLink resource should match the labels of the nginx-ingress service created in step-3.