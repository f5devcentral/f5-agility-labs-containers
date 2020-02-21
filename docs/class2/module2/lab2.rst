Lab 2.2 - Deploy Hello-World (Route)
====================================


Now that CIS is up and running, let's deploy an application and leverage CIS.

For this lab we'll use a simple pre-configured docker image called 
"f5-hello-world". It can be found on docker hub at
`f5devcentral/f5-hello-world <https://hub.docker.com/r/f5devcentral/f5-hello-world/>`_

App Deployment
--------------

On **kube-master1** we will create all the required files:

#. Create a file called ``f5-hello-world-deployment.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,20

#. Create a file called ``f5-hello-world-service-clusterip.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-service-clusterip.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,17

#. Create a file called ``f5-hello-world-route.yaml``

   .. tip:: Use the file in ~/agilitydocs/docs/class2/openshift

   .. literalinclude:: ../openshift/f5-hello-world-route.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7-9,23,24

#. We can now launch our application:

   .. code-block:: bash

      oc create -f f5-hello-world-deployment.yaml
      oc create -f f5-hello-world-service-clusterip.yaml
      oc create -f f5-hello-world-route.yaml

   .. image:: ../images/f5-container-connector-launch-app-clusterip-route.png

#. To check the status of our deployment, you can run the following commands:

   .. code-block:: bash

      oc get pods -o wide

   .. image:: ../images/f5-hello-world-cluster-route-pods.png

   .. code-block:: bash

      oc describe svc f5-hello-world

   .. image:: ../images/f5-cis-describe-clusterip-route-service.png

#. To understand and test the new app pay attention to the **Endpoints value**,
   this shows our 2 instances (defined as replicas in our deployment file) and
   the overlay network IP assigned to the pod.

   .. warning:: Don't forget to select the "okd" partition or you'll
      see nothing.

   With "Route" you'll seee two virtual servers defined. "okd_http_vs" and
   "okd_https_vs", listening on port 80 and 443.

   .. image:: ../images/f5-container-connector-check-app-route-bigipconfig.png

   These Virtual use an LTM Policy to direct traffic based on the host header.
   You can view this from the BIG-IP GUI at Local Traffic -->
   Virtual Servers --> Policies and click the Published Policy,
   "openshift_insecure_routes".

   .. image:: ../images/f5-check-ltm-policy-route.png

#. Check the Pools to see a new pool and the associated pool members:
   Local Traffic --> Pools --> "openshift_default_f5-hello-world-web"
   --> Members

   .. image:: ../images/f5-container-connector-check-app-route-pool-clusterip.png

   .. note:: You can see that the pool members IP addresses are assigned from
      the overlay network (**ClusterIP mode**)

#. To view the application from a browser you'll need to update your host file
   to point the assigned public IP at "mysite.f5demo.com".

   .. note:: This step can be skipped.

#. Delete Hello-World

   .. code-block:: bash

      oc delete -f f5-hello-world-route.yaml
      oc delete -f f5-hello-world-service-clusterip.yaml
      oc delete -f f5-hello-world-deployment.yaml

   .. important:: Do not skip this step. Instead of reusing some of these
      objects, the next lab we will re-deploy them to avoid conflicts and
      errors.
