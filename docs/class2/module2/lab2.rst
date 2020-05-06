Lab 2.2 - Deploy Hello-World Using Route
========================================

Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``deployment-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/deployment-hello-world.yaml
      :language: yaml
      :caption: deployment-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``clusterip-service-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/clusterip-service-hello-world.yaml
      :language: yaml
      :caption: clusterip-service-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,17

#. Create a file called ``route-hello-world.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/route-hello-world.yaml
      :language: yaml
      :caption: route-hello-world.yaml
      :linenos:
      :emphasize-lines: 2,7-9,23,24

#. We can now launch our application:

   .. code-block:: bash

      oc create -f deployment-hello-world.yaml
      oc create -f clusterip-service-hello-world.yaml
      oc create -f route-hello-world.yaml

   .. image:: ../images/f5-container-connector-launch-app-clusterip-route.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      oc get pods -o wide

   .. image:: ../images/f5-hello-world-cluster-route-pods.png

   .. code-block:: bash

      oc describe svc f5-hello-world

   .. image:: ../images/f5-cis-describe-clusterip-route-service.png

   .. attention:: To understand and test the new app pay attention to the
      **Endpoints value**, this shows our 2 instances (defined as replicas in
      our deployment file) and the overlay network IP assigned to the pod.

#. Now that we have deployed our application sucessfully, we can check the
   configuration on bigip1. Switch back to the open management session on
   firefox.

   .. warning:: Don't forget to select the "okd" partition or you'll
      see nothing.

   Goto :menuselection:`Local Traffic --> Virtual Servers`

   With "Route" you'll seee two virtual servers defined. "okd_http_vs" and
   "okd_https_vs", listening on port 80 and 443.

   .. image:: ../images/f5-container-connector-check-app-route-bigipconfig.png

   These Virtuals use an LTM Policy to direct traffic based on the host header.
   You can view this from the BIG-IP GUI at :menuselection:`Local Traffic -->
   Virtual Servers --> Policies` and click :menuselection:`Published Policy -->
   "openshift_insecure_routes"`

   .. image:: ../images/f5-check-ltm-policy-route.png

#. Check the Pools to see a new pool and the associated pool members:

   GoTo: :menuselection:`Local Traffic --> Pools` and selec the
   "openshift_default_f5-hello-world-web" pool. Click the Members tab.

   .. image:: ../images/f5-container-connector-check-app-route-pool-clusterip.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. Access your web application via firefox on the jumpbox.

   .. note:: Select the "mysite.f5demo.com" shortcut or type
      http://mysite.f5demo.com in the URL field.

   .. image:: ../images/f5-container-connector-access-app.png

   .. note:: Why can't we use http://10.1.1.4 to open the web server?

#. Delete Hello-World

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.

   .. code-block:: bash

      oc delete -f route-hello-world.yaml
      oc delete -f clusterip-service-hello-world.yaml
      oc delete -f deployment-hello-world.yaml

   .. attention:: Validate the objects are removed via the management console.
      :menuselection:`Local Traffic --> Virtual Servers`
