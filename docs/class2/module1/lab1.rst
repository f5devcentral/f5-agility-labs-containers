Lab 1.1 - Install & Configure CIS in NodePort Mode
==================================================

The BIG-IP Controller for OpenShift installs as a
`Deployment object <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>`_

.. seealso:: The official CIS documentation is here:
   `Install the BIG-IP Controller: Openshift <https://clouddocs.f5.com/containers/latest/userguide/openshift/#cis-installation>`_

In this lab we'll use NodePort mode to deploy an application to the BIG-IP.

.. seealso::
   For more information see `BIG-IP Deployment Options <https://clouddocs.f5.com/containers/latest/userguide/config-options.html>`_

BIG-IP Setup
------------

#. Browse to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   and connect to **bigip** using the **TMUI** access method.

   .. image:: ../images/udf-access-bigip-tmui.png

#. Login with username: **admin** and password: **F5site02@**.

   .. image:: ../images/udf-bigip-loginscreen.png

   .. attention::

      - Be sure to be in the ``Common`` partition before creating the following
        objects.

      .. image:: ../images/f5-check-partition.png

#. Just like the previous Kubernetes class we need to setup a partition that
   will be used by F5 Container Ingress Service.

   - Browse to: :menuselection:`System --> Users --> Partition List`
   - Create a new partition called "**ocp**" (use default settings)
   - Click **Finished**

   .. image:: ../images/f5-container-connector-bigip-partition-setup.png


#. Verify AS3 is installed.

   .. attention:: This has been done to save time but is documented here for
      reference.

   .. seealso:: For more info click here:
      `Application Services 3 Extension Documentation <https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/>`_

   - Browse to: :menuselection:`iApps --> Package Management LX`. and confirm
     "**f5-appsvcs**" is in the last as shown below.

     .. image:: ../images/confirm-as3-installed.png

#. If AS3 is NOT installed follow these steps:

   - Click here to: `Download latest AS3 <https://github.com/F5Networks/f5-appsvcs-extension/releases>`_

   - Go back to: :menuselection:`iApps --> Package Management LX`

     - Click **Import**
     - Browse and select the downloaded AS3 RPM
     - Click **Upload**

Explore the OpenShift Cluster
-----------------------------

#. Go to the **Deployment** tab of your UDF lab session at https://udf.f5.com 
   to connect to **ocp-provisioner** using the **Web Shell** access method, then su to cloud-user:

   .. image:: ../images/udf-access-ocp-provisioner.png

   .. code-block:: bash

      su - cloud-user

#. "git" the demo files

   .. note:: These files should already be there and upon login updated. If not
      use the following command to clone the repo.

   .. code-block:: bash

      git clone -b develop https://github.com/f5devcentral/f5-agility-labs-containers.git ~/agilitydocs

      cd ~/agilitydocs/docs/class2/openshift

#. Check the OpenShift status

   The **oc status** command shows a high level overview of the project
   currently in use, with its components and their relationships, as shown in
   the following example:

   .. code-block:: bash

      oc status

   .. image:: ../images/oc-status.png

#. Check the OpenShift cluster nodes

   You can manage nodes in your instance using the CLI. The CLI interacts with
   node objects that are representations of actual node hosts. The master uses
   the information from node objects to validate nodes with health checks.

   To list all nodes that are known to the master:

   .. code-block:: bash

      oc get nodes

   .. image:: ../images/oc-get-nodes.png

   .. attention::
      If the node STATUS shows **NotReady** or **SchedulingDisabled** contact
      the lab proctor. The node is not passing the health checks performed from
      the master, therefor pods cannot be scheduled for placement on the node.

#. To get more detailed information about a specific node, including the reason
   for the current condition use the oc describe node command. This does
   provide alot of very useful information and can assist with throubleshooting
   issues.

   .. code-block:: bash

      oc describe node master-1

   .. image:: ../images/oc-describe-node.png

#. Check to see what projects you have access to:

   .. code-block:: bash

      oc get projects

   .. image:: ../images/oc-get-projects.png

   .. note:: You will be using the "default" project in this class.

CIS Deployment
--------------

.. seealso:: For a more thorough explanation of all the settings and options see
   `F5 Container Ingress Service - Openshift <https://clouddocs.f5.com/containers/v2/openshift/>`_

Now that BIG-IP is licensed and prepped with the "**okd**" partition, we
need to define a `Kubernetes deployment <https://docs.okd.io/3.11/dev_guide/deployments/how_deployments_work.html>`_
and create a `Kubernetes secret <https://docs.okd.io/3.11/dev_guide/secrets.html>`_
to hide our bigip credentials.

#. Create bigip login secret

   .. code-block:: bash

      oc create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin

   You should see something similar to this:

   .. image:: ../images/f5-container-connector-bigip-secret.png

#. Create kubernetes service account for bigip controller

   .. code-block:: bash

      oc create serviceaccount k8s-bigip-ctlr -n kube-system

   You should see something similar to this:

   .. image:: ../images/f5-container-connector-bigip-serviceaccount.png

#. Create cluster role for bigip service account (admin rights, but can be
   modified for your environment)

   .. code-block:: bash

      oc create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

   You should see something similar to this:

   .. image:: ../images/f5-container-connector-bigip-clusterrolebinding.png

#. At this point we have two deployment mode options, Nodeport or ClusterIP.
   This class will feature both modes. For more information see
   `BIG-IP Deployment Options <https://clouddocs.f5.com/containers/latest/userguide/config-options.html>`_

   Lets start with **Nodeport mode**

   .. note::
      - For your convenience the file can be found in
        /home/ubuntu/agilitydocs/docs/class2/openshift (downloaded earlier in
        the clone git repo step).
      - Or you can cut and paste the file below and create your own file.
      - If you have issues with your yaml and syntax (**indentation MATTERS**),
        you can try to use an online parser to help you :
        `Yaml parser <http://codebeautify.org/yaml-validator>`_

   .. literalinclude:: ../openshift/nodeport-deployment.yaml
      :language: yaml
      :caption: nodeport-deployment.yaml
      :linenos:
      :emphasize-lines: 2,7,17,20,37,39-41

#. Once you have your yaml file setup, you can try to launch your deployment.
   It will start our f5-k8s-controller container on one of our nodes.

   .. note:: This may take around 30sec to be in a running state.

   .. code-block:: bash

      oc create -f nodeport-deployment.yaml

#. Verify the deployment "deployed"

   .. code-block:: bash

      oc get deployment k8s-bigip-ctlr --namespace kube-system

   .. image:: ../images/f5-container-connector-launch-node-deployment-controller.png

#. To locate on which node the CIS service is running, you can use the
   following command:

   .. code-block:: bash

      oc get pods -o wide -n kube-system

   We can see that our container is running on okd-node1 below.

   .. image:: ../images/f5-container-connector-locate-node-controller-container.png

Troubleshooting
---------------

If you need to troubleshoot your container, you have two different ways to
check the logs of your container, oc command or docker command.

.. attention:: Depending on your deployment, CIS can be running on either
   master-1 or master-2. 

#. Using ``oc`` command: you need to use the full name of your pod as shown in
   the previous image.

   .. code-block:: bash

      # For example:
      oc logs k8s-bigip-ctlr-844dfdc864-669hb -n kube-system

   .. image:: ../images/f5-container-connector-check-logs-kubectl.png

