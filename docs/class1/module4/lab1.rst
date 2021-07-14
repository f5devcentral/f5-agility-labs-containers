Lab 4.1 - Configure F5 IngressLink with Kubernetes
==================================================

BIG-IP Setup
------------

When we configure CIS below, NGINX requires "Proxy-Protocol" to provide the
application POD with the original client IP. BIG IP will pass the original
client IP to NGINX via PROXY PROTOCOL, and NGINX will pass the client IP to the
application POD via X-Real-IP HTTP header. The following iRule provides the
necessary header with IP information.

#. Login to BigIP GUI
#. On the Main tab go to :menuselection:`Local Traffic --> iRules`
#. Click Create.
#. In the Name field, type name as "Proxy_Protocol_iRule".

   .. important:: Be sure to use the name as shown. The IngressLink Resource
      will reference that specific name.

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

#. Create the CIS IngressLink custom resource definition. The schema is used
   to validate the JSON data during creation and updates so that it can
   prevent invalid data, or moreover, malicious attacks.

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

   .. note:: BIG IP will pass the original client IP to NGINX via PROXY
      PROTOCOL, and NGINX will pass the client IP to the application POD via
      X-Real-IP HTTP header.

   .. literalinclude:: ../kubernetes/ingresslink/nginx-config.yaml
      :language: yaml
      :caption: nginx-config.yaml
      :linenos:
      :emphasize-lines: 7-9

#. Apply the config changes to nginx ingress

   .. code-block:: bash

      kubectl apply -f ingresslink/nginx-config.yaml

   .. hint:: The use of "apply" allows us to modify an already running object.

#. Inspect the deployment yaml

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

#. Create the CIS deployment

   .. code-block:: bash

      kubectl create -f ingresslink/ingresslink-deployment.yaml

#. Verify the new CIS pod is "Running"

   .. code-block:: bash

      kubectl get pods -A

   You should see something similar to the following. Verify a new pod named
   "K8s-bigip-ctrl..." has started.

   .. image:: ../images/k8s-ingresslink.png

   .. hint:: Note the use of "-A" for all namespaces in the kubectl command.

Create an IngressLink Resource
------------------------------

#. Inspect the IngressLink resource

   .. attention:: Ensure the IP ADDR in the IngressLink resource matches the
      required IP. In this lab we're using 10.1.1.4 as the virtual IP. This
      IP ADDR will be used to configure the BIG-IP device to load balance the
      Ingress Controller resources.

   .. literalinclude:: ../kubernetes/ingresslink/vs-ingresslink.yaml
      :language: yaml
      :caption: vs-ingresslink.yaml
      :linenos:
      :emphasize-lines: 2,4,7,12

   .. important:: The name of the app label selector in the IngressLink
      resource should match the labels of the nginx-ingress service created in
      module 3 where we deployed NGINX.

#. Create the IngressLink

   .. code-block:: bash

      kubectl create -f ingresslink/vs-ingresslink.yaml

#. To validate IngressLink deployment we'll verify the pool member created on
   BIGIP consist of one IP and it matches the NGINX ingress controller. To find
   the IP run the following command and take note of the Endpoint IP.

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

   GoTo: :menuselection:`Local Traffic --> Pools` and select either of the
   "nginx_ingress_nginx_ingress_ingresslink" pool objects. Both have the same
   pool member but are running on different ports. Click the Members tab.

   .. image:: ../images/ingress-link-pool.png

   .. note:: You can see that the pool member listed is the same Endpoint/IP
      discovered in the earlier step above.
