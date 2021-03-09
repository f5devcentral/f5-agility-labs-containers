Lab 4.1 - Configure F5 IngressLink with Kubernetes
==================================================

BIG-IP Setup
------------

As previouly stated vxlan should be configured. In addition to that config
Proxy Protocol is required by NGINX to provide the applications PODs with the
original client IPs. Use the following steps to configure the
Proxy_Protocol_iRule

#. Login to BigIP GUI
#. On the Main tab go to :menuselection:`Local Traffic --> iRules`
#. Click Create.
#. In the Name field, type name as "Proxy_Protocol_iRule".
#. In the Definition field, Copy the following definition

   .. literalinclude:: ../kubernetes/ingresslink/Proxy_Protocol_iRule
      :language: tcl
      :caption: Proxy_Protocol_iRule
      :linenos:

#. Click Finished

Configure CIS
-------------

On the jumphost open a terminal and start an SSH session with kube-master1.

.. note:: You should already have an open SSH session with kube-master1 from
   the previous module. If not follow the instructions below.

#. Change to the default working directory with all the yaml files

   .. code-block:: bash

      cd ~/agilitydocs/docs/class1/kubernetes/

#. Ensure the previously deployed "CIS ClusterIP deployment" is deleted

   .. code-block:: bash

      kubectl delete -f cluster-deployment.yaml

   .. attention:: This was most likely done in a previous step but we need to
      ensure the previous deployment is removed. It does not hurt to run the
      command again so do so now.

#. Review the CIS IngressLink dustom resource definition schema

   .. literalinclude:: ../kubernetes/ingresslink/ingresslink-customresourcedefinition.yaml
      :language: yaml
      :caption: ingresslink-customresourcedefinition.yaml
      :linenos:
      :emphasize-lines: 2,4,6

#. Create the CIS IngressLink custom resource definition

   .. code-block:: bash

      kubectl create -f ingresslink/ingresslink-customresourcedefinition.yaml

#. Create a service for the Ingress Controller pods for ports 80 and 443

   .. code-block:: bash

      kubectl create -f ingresslink/nginx-service.yaml

#. Verify the service

   .. code-block:: bash

      kubectl describe svc nginx-ingress-ingresslink -n nginx-ingress

#. The default nginx config needs to be updated with proxy-protocol. This is
   necesary for IngressLink to properly operate.

   .. literalinclude:: ../kubernetes/ingresslink/nginx-config.yaml
      :language: yaml
      :caption: nginx-config.yaml
      :linenos:
      :emphasize-lines: 7-9

#. Apply the config changes to nginx ingress

   .. code-block:: bash

      kubectl apply -f ingresslink/nginx-config.yaml

   .. hint:: The use of "apply" allows us to modify an already running object.

#. Inspect the deployment yaml file
   
   .. note:: To enable IngressLink you'll notice two additional "args"

      .. code-block:: bash

         "--custom-resource-mode=true",
         "--ingress-link-mode=true",

   You'll see this difference in the deployment file

   .. literalinclude:: ../kubernetes/ingresslink/ingresslink-deployment.yaml
      :language: yaml
      :caption: ingresslink-deployment.yaml
      :linenos:
      :emphasize-lines: 2,7,20,37,39-41

#. Create CIS deployment

   .. code-block:: bash

      kubectl create -f ingresslink/ingresslink-deployment.yaml

Create an IngressLink Resource
------------------------------

#. Inspect the ingresslink resource

   .. note:: Ensure the IP ADDR in the IngressLink resource match the required IP.
      In this lab we're using 10.1.1.4 for the VIP. This ip-address will be used
      to configure the BIG-IP device to load balance among the Ingress Controller
      pods.

   .. literalinclude:: ../kubernetes/ingresslink/vs-ingresslink.yaml
      :language: yaml
      :caption: vs-ingresslink.yaml
      :linenos:
      :emphasize-lines: 2,4,7,12

   .. important:: The name of the app label selector in the IngressLink resource
      should match the labels of the nginx-ingress service created in module3,
      where we deployed nginx.
   
#. Create the ingress link

   .. code-block:: bash

      kubectl create -f ingresslink/vs-ingresslink.yaml
