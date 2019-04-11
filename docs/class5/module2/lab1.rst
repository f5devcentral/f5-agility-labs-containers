Lab 2.1 - ConfigMap - Basic
==============================

.. note:: You will use the same Windows jumpbox as you used in the previous
   sections to complete the exercises in this section.

   Unless otherwise noted, all the resource definition yaml files have been
   pre-created and can be found on the **ose-master1** server under
   **/home/centos/agilitydocs/openshift/advanced/apps/module2**


An OpenShift ConfigMap is one of the resource types that the F5 Container
Connector watches for. The Container Connector will read the ConfigMap and
create a virtual server, node(s), a pool, pool member(s) and a pool health
monitor.

In this lab, you will create a ConfigMap that defines the objects that the
Container Connector should configure on the BIG-IP.

#. Deploy demo application.

   From the **ose-master1**, review the following Deployment configuration:
   **f5-demo-app-deployment.yaml**

   .. literalinclude:: ../../../openshift/advanced/apps/module2/f5-demo-app-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,7

   Now that you have reviewed the Deployment, you need to actually create the
   Deployment by deploying it to OpenShift by using the **oc create** command.

   From **ose-master1** server, run the following command:

   .. attention:: Be sure to change the proper working directory on
      **ose-master1**:

      /home/centos/agilitydocs/openshift/advanced/apps/module2

   .. code-block:: bash

      oc create -f f5-demo-app-deployment.yaml

#. Create Service to expose application.

   In order for an application to be accessible outside of the OpenShift
   cluster, a Service must be created. The Service uses a label selector to
   reference the application to be exposed. Additionally, the service also
   specifies the container port (8080) that the application is listening on.

   From **ose-master1**, review the following Service: f5-demo-app-service.yaml

   .. literalinclude:: ../../../openshift/advanced/apps/module2/f5-demo-app-service.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,4,9

   Now that you have reviewed the Service, you need to actually create the
   Service by deploying it to OpenShift by using the **oc create** command.

   From ose-master1 server, run the following command:

   .. code-block:: bash

      oc create -f f5-demo-app-service.yaml

#. Create ConfigMap

   A ConfigMap is used to define the BIG-IP objects that need to be created to
   enable access to the application via the BIG-IP.

   The label, **f5type: virtual-server**, in the ConfigMap definition is what
   triggers the F5 Container Connector to process this ConfigMap.

   In addition to the label, there are several F5-specific sections defined:

   * **virtualServer:** Beginning of F5-specific configuration
   * **backend:** Represents the server-side of the virtual server definition
   * **healthMonitors:** Health monitor definition for the pool
   * **frontend:** Represents the client-side of the virtual server
   * **virtualAddress:** IP address and port of virtual server

   A **ConfigMap** points to a **Service** which points to one or more **Pods**
   where the application is running.

   From ose-master1, review the ConfigMap resource f5-demo-app-configmap.yaml

   .. literalinclude:: ../../../openshift/advanced/apps/module2/f5-demo-app-configmap.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 1,5,14,34,36

   .. attention:: Knowledge Check: How does the BIG-IP know which pods make up
      the application?*

   Now that you have reviewed the ConfigMap, you need to actually create the
   ConfigMap by deploying it to OpenShift by using the **oc create** command:

   .. code-block:: bash

      oc create -f f5-demo-app-configmap.yaml

#. Review BIG-IP configuration. Examine the BIG-IP configuration that was
   created by the Container Connector when it processed the ConfigMap created
   in the previous step.

   Launch the Chrome browser and click on the bookmark named
   **bigip1.agility-labs.io** to access the BIG-IP GUI:

   .. image:: images/bigip01-bookmark.png

   From the BIG-IP login page, enter username=admin and password=admin and
   click the **Log in** button:

   .. image:: images/bigip01-login-page.png

   Navigate to :menuselection:`Local Traffic --> Network Map` and change the
   partition to **ocp** using the dropdown in the upper right. The network map
   view shows a virtual server, pool and pool member. All of these objects were
   created by the Container Connector using the declarations defined in the
   ConfigMap.

   .. image:: images/bigip01-network-map-cfgmap.png

   .. attention:: *Knowledge Check: In the network map view, what OpenShift
      object type does the pool member IP address represent?  How was the IP
      address assigned?*

   To view the IP address of the virtual server, hover your cursor over the name
   of the virtual server:

   .. image:: images/bigip01-vs-ip-hover.png

   .. attention:: *Knowledge Check: What OpenShift resource type was used to
      define the virtual server IP address?*

#. Test the application. Use the Chrome browser to access the application you
   previously deployed to OpenShift.

   Open a new browser tab and enter the IP address assigned to the virtual
   server in to the address bar:

   .. image:: images/f5-demo-app-url.png

   .. note:: On the application page, the **Server IP** is the pool member
      (pod) IP address; the **Server Port** is the port of the virtual server;
      and the **Client IP** is the floating Self-IP address of the Big-IP.

#. Scale the application.  The application deployed in step #1 is a single
   replica (instance). Now we'll increase the number of replicas and then check
   the BIG-IP configuration to see what's changed.

   When the deployment replica count is scaled up or scaled down, an OpenShift
   event is generated and the Container Connector sees the event and adds or
   removes pool members as appropriate.

   To scale the number of replicas, you will use the OpenShift **oc scale**
   command. You will be scaling the demo app deployment and so You first need
   to get the name of the deployment.

   From ose-master1, issue the following command:

   .. code-block:: bash

      oc get deployment -n f5demo

   You can see from the output that the deployment is named **f5-demo-app**.
   You will use that name for the next command.

   .. image:: images/oc-get-deployment1.png

   From the ose-master1 host, entering the following command to set the replica
   count for the deployment to 10 instances:

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5-demo-app -n f5demo

#. Review the BIG-IP configuration. Examine the BIG-IP configuration for
   changes that occured after the application was scaled up.

   Navigate to :menuselection:`Local Traffic --> Network Map` and change the
   partition to **ocp** using the dropdown in the upper right.

   .. image:: images/bigip01-network-map-scaled.png

   .. attention:: *Knowledge Check: How many pool members are shown in the
      network map view? What do you think would happen if you scaled the
      deployment back to one replica?*

#. Test the scaled application. Use the Chrome browser to access the
   application that you scaled to 10 replicas in the previous step.

   Open a new Chrome browser tab and enter the IP address assigned to the
   virtual server in to the address bar:

   .. image:: images/f5-demo-app-url.png

   If you reload the page every few seconds, you should see the **Server IP**
   address change.  Because there is more than one instance of the application
   running, the BIG-IP load balances the application traffic amongst multiple
   pods.  

#. Cleanup deployed resources. Remove the OpenShift Deployment, Service and
   ConfigMap resources you created in the previous steps using the OpenShift
   **oc delete** command.

   From ose-master1 server, issue the following commands:

   .. code-block:: bash

      oc delete -f f5-demo-app-configmap.yaml
      oc delete -f f5-demo-app-deployment.yaml
      oc delete -f f5-demo-app-service.yaml
