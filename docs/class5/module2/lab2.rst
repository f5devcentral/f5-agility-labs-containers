Lab 2.2 - Route - Basic
=======================

An OpenShift Route is one of the resource types that the F5 Container Connector
watches for. A Route defines a hostname or URI mapping to an application. For
example, the hostname "customer.example.com" could map to the application
"customer", hostname "catalog.example.com", might map to the application
"catalog", etc.

Similarly, a Route can refer to a URI path so, for example, the URI path
"/customer" might map to the application called "customer" and URI path
"/catalog", might map to the application called "catalog". If a Route only
specifies URI paths, the Route applies to all HTTP request hostnames.

Additionally, a Route can refer to both a hostname and a URI path such as
mycompany.com/customer or mycompany.com/catalog

The F5 Container Connector reads the Route resource and creates a virtual
server, node(s), a pool per route path and pool members.  Additionally, the
Container Connector creates a layer 7 BIG-IP traffic policy and associates it
with the virtual server.  This layer 7 traffic policy evaluates the hostname
or URI path from the request and forwards the traffic to the pool associated
with that path.

A **Route** points to a **Service** which points to one or more **Pods** where
the application is running.

.. attention:: All Route resources share two virtual servers:

   * **ose-vserver** for HTTP traffic, and
   * **https-ose-vserver** for HTTPS traffic

   The Container Connector assigns the names shown above by default. To set
   custom names, define **route-http-vserver** and **route-https-vserver** in
   the BIG-IP Container Connector Deployment.  Please see the documentation
   at: http://clouddocs.f5.com for more details.

#. Deploy demo application and its associated Service.

   In the previous lab, you created the Deployment and Service separately. This
   step demonstrates creating both the Deployment and the Service from single
   configuration file. A separator of 3 dashes (``---``) is used to separate
   one resource definition from the next resource definition. 

   From ose-master1, review the following deployment:
   f5-demo-app-route-deployment.yaml

   .. literalinclude:: ../../../openshift/advanced/apps/module2/f5-demo-app-route-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,20

   Now that you have reviewed the Deployment, you need to actually create it by
   deploying it to OpenShift by using the **oc create** command:

   .. code-block:: bash

      oc create -f f5-demo-app-route-deployment.yaml -n f5demo

#. Create OpenShift Route

   From ose-master1 server, review the following Route:
   f5-demo-app-route-route.yaml

   .. literalinclude:: ../../../openshift/advanced/apps/module2/f5-demo-app-route-route.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2

   .. attention:: *Knowledge Check: How does the Container Connector know what
      application the Route refers to?*

   Now that you have reviewed the Route, you need to actually create it by
   deploying it to OpenShift by using the **oc create** command:

   .. code-block:: bash

      oc create -f f5-demo-app-route-route.yaml -n f5demo

#. Review the BIG-IP configuration. Examine the BIG-IP configuration for
   changes that occured after the the OpenShift Route was deployed.

   Using the Chrome browser, navigate to :menuselection:`Local Traffic -->
   Network Map` and change the partition to **ocp** using the dropdown in the
   upper right.

   .. image:: images/bigip01-network-map-route.png
      :align: center

   The network map view shows two virtual servers that were created by the
   Container Connector when it procssed the Route resource created in the
   previous step. One virtual server is for HTTP client traffic and the other
   virtual server is for HTTPS client traffic.

   To view the IP address of the virtual server, hover your cursor over the
   virtual server named **ocp-vserver**

   .. image:: images/bigip01-route-vs-hover.png
      :align: center

   .. attention:: *Knowledge Check: Which OpenShift resource type defines the
      names of the two virtual servers?*

#. View the traffic policy that was created by the Container Connector when it
   processed the OpenShift Route.

   Navigate to :menuselection:`Local Traffic --> Policies --> Policy List` and
   change the partition to **ocp** using the drop down in the upper right.

   .. image:: images/bigip01-route-policy-list.png
      :align: center

   Click on the traffic policy listed uner **Published Policies** to view the
   policy page for the selected policy:

   .. image:: images/bigip01-route-policy.png
      :align: center

   Click on the rule name listed under the **Rules** section of the policy page
   to view the rule page for the selected rule:

   .. warning:: Due to the version of TMOS used in this lab you will not see the
      correct "hostname" due to a GUI issue.

   .. image:: images/bigip01-route-rule.png
      :align: center

   On the rule page, review the configuration of the rule and note the match
   condition and rule action settings.

   .. attention:: *Knowledge Check: Which OpenShift resource type defines the
      hostname to match against?*

#. Test the application. Use the Chrome browser to access the application you
   previously deployed.

   .. important:: Because the Route resource you created specifies a hostname
      for the path, you will need to use a hostname instead of an IP address to
      access the demo application.

   Open a new Chrome browser tab and enter the hostname **mysite.f5demo.com**
   in to the address bar:

   .. image:: images/f5-demo-app-route.png
      :align: center

   .. note:: On the application page, the **Server IP** is the pool member
      (pod) IP address; the **Server Port** is the port of the virtual server;
      and the **Client IP** is the floating Self-IP address of the Big-IP.

#. Remove the Deployment, Service and Route resources you created in the
   previous steps using the OpenShift **oc delete** command.

   From ose-master1 server, issue the following commands:

   .. code-block:: bash

      oc delete -f f5-demo-app-route-route.yaml -n f5demo
      oc delete -f f5-demo-app-route-deployment.yaml -n f5demo
