Lab 2.3 - Route - Blue/Green Testing
====================================

The F5 Container Connector supports Blue/Green application testing e.g testing
two different versions of the same application, by using the **weight**
parameter of OpenShift Routes.  The **weight** parameter allows you to
establish relative ratios between application **Blue** and application
**Green**. So, for example, if the first route specifies a weight of 20 and
the second a weight of 10, the application associated with the first route
will get twice the number of requests as the application associated with the
second route.

Just as in the previous exercise, the F5 Container Connector reads the Route
resource and creates a virtual server, node(s), a pool per route path and
pool members.

However, in order to support Blue/Green testing using OpenShift Routes, the
Container Connector creates an iRule and a datagroup on the BIG-IP. The iRule
handles the connection routing based on the assigned weights.

.. note:: At smaller request volumes, the ratio of requests to the **Blue**
   application and the requests to the **Green** application may not match the
   relative weights assigned in the OpenShift Route.  However, as the number of
   requests increases, the ratio of requests between the **Blue** application
   and the **Green** application should closely match the weights assigned in
   the OpenShift Route.

#. Deploy version 1 and version 2 of demo application and their associated
   Services

   From ose-master1, review the following deployment:
   f5-demo-app-bg-deployment.yaml

   .. literalinclude:: ../openshift/advanced/apps/module2/f5-demo-app-bg-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,36,38,59,61,93,95

   Now that you have reviewed the Deployment, you need to actually create it by
   deploying it to OpenShift by using the **oc create** command:

   .. code-block:: bash

      oc create -f f5-demo-app-bg-deployment.yaml -n f5demo

#. Create OpenShift Route for Blue/Green Testing

   The basic Route example from the previous exercise only included one path.
   In order to support Blue/Green application testing, a Route must be created
   that has two paths. In OpenShift, the second (and subsequent) path is
   defined in the **alternateBackends** section of a Route resource.

   From ose-master1, review the following Route: f5-demo-app-bg-route.yaml

   .. literalinclude:: ../openshift/advanced/apps/module2/f5-demo-app-bg-route.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,21,26,28,30

   .. note:: How the Route resource refers to two different services: The first
      service is for the **Blue** application with a weight of 20 and the second
      service is for the **Green** application with a weight of 10.

   .. attention:: *Knowledge Check: How many requests will the **Blue**
      application receive relative to the **Green** application?*

   Now that you have reviewed the Route, you need to actually create it by
   deploying it to OpenShift by using the **oc create** command:

   .. code-block:: bash

      oc create -f f5-demo-app-bg-route.yaml

   Verify that the Route was successfully creating by using the OpenShift
   **oc get route** command. Note that, under the **SERVICES** column, the two
   applications are listed along with their request distribution percentages.

   .. code-block:: bash

      oc get route -n f5demo

   .. image:: images/oc-get-route.png

   .. attention:: *Knowledge Check: What would the Route percentages be if the
      weights were 10 and 40?*

#. Review BIG-IP configuration. Examine the BIG-IP configuration for changes
   made by the Container Connector after the the OpenShift Route was deployed.

   Using the Chrome web browser, navigate to :menuselection:`Local Traffic -->
   Pools --> Pool List` and change the partition to **ocp** using the dropdown
   in the upper right.

   .. image:: images/bigip01-route-bg-pool.png

   .. note:: There are two pools defined: one pool for the **Blue** application
      and a second pool for the **Green** application. Additionally, the
      Container Connector also creates an iRule and a datagroup that the BIG-IP
      uses to distribute traffic based on the weights assigned in the OpenShift
      Route.

#. Test the application. Use the Chrome browser to access blue and green
   applications you previously deployed.

   Because the Route resource you created specifies a hostname for the path,
   you will need to use a hostname instead of an IP address to access the demo
   application. Open a new browser tab and enter the hostname
   **http://mysite-bg.f5demo.com** in to the address bar

   Refresh the browser periodically and you should see the web page change from
   the **Blue** application to the **Green** application and back to the
   **Blue** application as noted by the colors on the page.

   .. image:: images/f5-demo-app-blue.png

   .. image:: images/f5-demo-app-green.png

#. Generate some request traffic. Use the Linux **curl** utility to send a
   large volume of requests to the application.

   As the number of requests increases, the relative number of requests between
   the **Blue** application and the **Green** application begins to approach
   the weights that have been defined in the OpenShift Route.

   From the ose-master1 server, run the following command to make 1000 requests
   to the application:

   .. code-block:: bash

      for i in {1..1000}; do curl -s -o /dev/null http://mysite-bg.f5demo.com; done

#. Review the BIG-IP configuration

   In the previous step, you used the **curl** utility to generate a large
   volume of requests. In this step, you will review the BIG-IP pool statistics
   to see how the requests were distributed between the **Blue** application
   and the **Green** application.

   Using the Chrome web browser, navigate to :menuselection:`Local Traffic -->
   Pools --> Statistics` and change the partition to **ocp** using the dropdown
   in the upper right.

   .. image:: images/bigip-blue-green-pool-stats.png

#. Cleanup deployed resources. Remove the Deployment, Service and Route
   resources you created in the previous steps using the OpenShift
   **oc delete** command.

   From ose-master1 server, run the following commands:

   .. code-block:: bash

      oc delete -f f5-demo-app-bg-route.yaml -n f5demo
      oc delete -f f5-demo-app-bg-deployment.yaml -n f5demo
