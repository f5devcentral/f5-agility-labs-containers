Lab 2.1 - Install & Configure CIS in ClusterIP Mode
===================================================

In the previous moudule we learned about Nodeport Mode. Here we'll learn
about ClusterIP Mode.

.. seealso::
   For more information see `BIG-IP Deployment Options <https://clouddocs.f5.com/containers/latest/userguide/config-options.html>`_

BIG-IP Setup
------------
With ClusterIP we're utilizing VXLAN to communicate with the application pods.
To do so we'll need to configure BIG-IP first.

#. Go back to the TMUI session you opened in a previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   and connect to **bigip** using the **TMUI** access method (*username*: **admin** and *password*: **F5site02@**)

   .. image:: ../images/udf-access-bigip-tmui.png

#. First we need to setup a partition that will be used by F5 Container Ingress
   Service.

   .. note:: This step was performed in the previous module. Verify the
      "ocp" partion exists and if not follow the instructions below.

   - Browse to: :menuselection:`System --> Users --> Partition List`
   .. attention::
   Be sure to be in the ``Common`` partition before creating the following
   objects.

   .. image:: ../images/f5-check-partition.png

   - Create a new partition called "**ocp**" (use default settings)
   - Click **Finished**

   .. image:: ../images/udf-ocp-partition.png



#. Install AS3 via the management console

   .. attention:: This has been done to save time. If needed see
      `Module1 / Lab 1.1 / Install AS3 Steps <../module1/lab1.html>`_


CIS Deployment
--------------

.. note::
   - For your convenience the file can be found in
     /home/ubuntu/agilitydocs/docs/class2/openshift (downloaded earlier in the
     clone git repo step).
   - Or you can cut and paste the file below and create your own file.
   - If you have issues with your yaml and syntax (**indentation MATTERS**),
     you can try to use an online parser to help you :
     `Yaml parser <http://codebeautify.org/yaml-validator>`_

#. Go back to the Web Shell session you opened in a previous task. If you need to open a new
   session go back to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   to connect to **ocp-provisioner** using the **Web Shell** access method, then su to cloud-user:

   .. image:: ../images/udf-access-ocp-provisioner.png

   .. code-block:: bash

      su - cloud-user

#. Just like the previous module where we deployed CIS in NodePort mode we need
   to create a "**secret**", "**serviceaccount**", and "**clusterrolebinding**".

   .. important:: This step can be skipped if previously done in
      module1(NodePort). Some classes may choose to skip module1.

   .. code-block:: bash

      oc create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin
      oc create serviceaccount k8s-bigip-ctlr -n kube-system
      oc create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

#. Now that we have added a HostSubnet for bigip we can launch the CIS
   deployment. It will start the f5-k8s-controller container on one of the
   worker nodes.

   .. attention:: This may take around 30s to get to a running state.

   .. code-block:: bash

      cd ~/agilitydocs/docs/class2/openshift

      cat cluster-deployment.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../openshift/cluster-deployment.yaml
      :language: yaml
      :caption: cluster-deployment.yaml
      :linenos:
      :emphasize-lines: 2,7,17,20,37-40,46-47

#. Create the CIS deployment with the following command

   .. code-block:: bash

      oc create -f cluster-deployment.yaml

#. Verify the deployment "deployed"

   .. code-block:: bash

      oc get deployment k8s-bigip-ctlr-deployment --namespace kube-system

   .. image:: ../images/f5-container-connector-launch-deployment-controller.png

#. To locate on which node CIS is running, you can use the following command:

   .. code-block:: bash

      oc get pods -o wide -n kube-system

   We can see that our container, in this example, is running on okd-node1
   below.

   .. image:: ../images/F5-CTRL-RUNNING.png

Troubleshooting
---------------

Check the container/pod logs via ``oc`` command. You also have the option of
checking the Docker container as described in the previos module.

#. Using the full name of your pod as showed in the previous image run the
   following command:

   .. code-block:: bash

      # For example:
      oc logs k8s-bigip-ctlr-79b8f9cbd8-smsqs -n kube-system

   .. image:: ../images/f5-container-connector-check-logs-kubectl2.png

   .. attention:: You will see **ERROR** in this log output. These errors can
      be ignored. The lab will work as expected.
