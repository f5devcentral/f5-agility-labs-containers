Lab 1.1 - Install & Configure CIS in NodePort Mode
==================================================

The BIG-IP Controller for Kubernetes installs as a
`Deployment object <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>`_

.. seealso:: The official CIS documentation is here:
   `Install the BIG-IP Controller: Kubernetes <https://clouddocs.f5.com/containers/v2/kubernetes/kctlr-app-install.html>`_

In this lab we'll use NodePort mode to deploy an application to the BIG-IP.

.. seealso::
   For more information see `BIG-IP Controller Modes <http://clouddocs.f5.com/containers/v2/kubernetes/kctlr-modes.html>`_

BIG-IP Setup
------------

Via RDP connect to the UDF lab "jumpbox" host. 

.. note:: Username and password are: **ubuntu/ubuntu**

#. Open firefox and connect to bigip1 management console. For your convenience
   there's a shortcut on the firefox toolbar. 
   
   .. note:: Username and password are: **admin/admin**

   .. attention::

      - Check BIG-IP is active and licensed.

      - If your BIG-IP has no license or its license expired, renew the
        license. You just need a LTM VE license for this lab. No specific
        add-ons are required (ask a lab instructor for eval licenses if your
        license has expired)

      - Be sure to be in the ``Common`` partition before creating the following
        objects.

      .. image:: ../images/f5-check-partition.png

#. First we need to setup a partition that will be used by F5 Container Ingress
   Service. 
   
   - GoTo: :menuselection:`System --> Users --> Partition List`
   - Create a new partition called "kubernetes" (use default settings)
   - Click Finished

   .. image:: ../images/f5-container-connector-bigip-partition-setup.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create auth partition kubernetes

#. Verify AS3 is installed.

   .. attention:: This has been done to save time but is documented here for
      reference.

   .. seealso:: For more info click here:
      `Application Services 3 Extension Documentation <https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/>`_

   - GoTo: :menuselection:`iApps --> Package Management LX` and confirm
     "f5-appsvcs" is in the last as shown below.

     .. image:: ../images/confirm-as3-installed.png

#. If AS3 is NOT installed follow these steps:

   - Click here to: `Download latest AS3 <https://github.com/F5Networks/f5-appsvcs-extension/releases>`_

   - Go back to: :menuselection:`iApps --> Package Management LX`

     - Click Import
     - Browse and select downloaded AS3 RPM
     - Click Upload

Explore the Kubernetes Cluster
------------------------------

#. On the jumphost open a terminal and start an SSH session with kube-master1.

   .. image:: ../images/start-term.png

   .. code-block:: bash

      # If directed to, accept the authenticity of the host by typing "yes" and hitting Enter to continue.

      ssh kube-master1

   .. image:: ../images/sshtokubemaster1.png

#. "git" the demo files

   .. note:: These files should already be there and upon login updated. If not
      use the following command to clone the repo.

   .. code-block:: bash

      git clone -b develop https://github.com/f5devcentral/f5-agility-labs-containers.git ~/agilitydocs

      cd ~/agilitydocs/docs/class1/kubernetes

#. Check the Kubernetes cluster nodes.

   You can manage nodes in your instance using the CLI. The CLI interacts with
   node objects that are representations of actual node hosts. The master uses
   the information from node objects to validate nodes with health checks.

   To list all nodes that are known to the master:

   .. code-block:: bash

      kubectl get nodes

   .. image:: ../images/kube-get-nodes.png

   .. attention::
      If the node STATUS shows **NotReady** or **SchedulingDisabled** contact
      the lab proctor. The node is not passing the health checks performed from
      the master, therefore pods cannot be scheduled for placement on the node.

#. To get more detailed information about a specific node, including the reason
   for the current condition use the kubectl describe node command. This does
   provide alot of very useful information and can assist with throubleshooting
   issues.

   .. code-block:: bash

      kubectl describe node kube-master1

   .. image:: ../images/kube-describe-node.png

CIS Deployment
--------------

.. seealso:: For a more thorough explanation of all the settings and options see
   `F5 Container Ingress Services - Kubernetes <https://clouddocs.f5.com/containers/v2/kubernetes/>`_

Now that BIG-IP is licensed and prepped with the "kubernetes" partition, we
need to define a `Kubernetes deployment <https://kubernetes.io/docs/user-guide/deployments/>`_
and create a `Kubernetes secret <https://kubernetes.io/docs/user-guide/secrets/>`_
to hide our bigip credentials.

#. Create bigip login secret

   .. code-block:: bash

      kubectl create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin

   You should see something similar to this:

   .. image:: ../images/f5-container-connector-bigip-secret.png

#. Create kubernetes service account for bigip controller

   .. code-block:: bash

      kubectl create serviceaccount k8s-bigip-ctlr -n kube-system

   You should see something similar to this:

   .. image:: ../images/f5-container-connector-bigip-serviceaccount.png

#. Create cluster role for bigip service account (admin rights, but can be
   modified for your environment)

   .. code-block:: bash

      kubectl create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

   You should see something similar to this:

   .. image:: ../images/f5-container-connector-bigip-clusterrolebinding.png

#. At this point we have two deployment mode options, Nodeport or ClusterIP.
   This class will feature both modes. For more information see
   `BIG-IP Controller Modes <http://clouddocs.f5.com/containers/v2/kubernetes/kctlr-modes.html>`_

   Lets start with **Nodeport mode**

   .. note:: 
      - For your convenience the file can be found in
        /home/ubuntu/agilitydocs/docs/class1/kubernetes (downloaded earlier in
        the clone git repo step).
      - Or you can copy and paste the file below and create your own file.
      - If you have issues with your yaml and syntax (**indentation MATTERS**),
        you can try to use an online parser to help you :
        `Yaml parser <http://codebeautify.org/yaml-validator>`_

   .. literalinclude:: ../kubernetes/nodeport-deployment.yaml
      :language: yaml
      :caption: nodeport-deployment.yaml
      :linenos:
      :emphasize-lines: 2,7,17,20,37,39-40

#. Once you have your yaml file setup, you can try to launch your deployment.
   It will start our f5-k8s-controller container on one of our nodes.
   
   .. note:: This may take around 30sec to be in a running state.

   .. code-block:: bash

      kubectl create -f nodeport-deployment.yaml

#. Verify the deployment "deployed"

   .. code-block:: bash

      kubectl get deployment k8s-bigip-ctlr --namespace kube-system

   .. image:: ../images/f5-container-connector-launch-deployment-controller.png

#. To locate on which node the CIS service is running, you can use the
   following command:

   .. code-block:: bash

      kubectl get pods -o wide -n kube-system

   We can see that our container is running on kube-node1 below.

   .. image:: ../images/f5-container-connector-locate-controller-container.png

Troubleshooting
---------------

If you need to troubleshoot your container, you have two different ways to
check the logs, kubectl command or docker command.

.. attention:: Depending on your deployment, CIS can be running on either
   kube-node1 or kube-node2. In our example above it's running on
   **kube-node2**

#. Using ``kubectl`` command: you need to use the full name of your pod as
   shown in the previous image.

   .. code-block:: bash

      # For example:
      kubectl logs k8s-bigip-ctlr-7469c978f9-6hvbv -n kube-system

   .. image:: ../images/f5-container-connector-check-logs-kubectl.png

#. Using docker logs command: From the previous check we know the container
   is running on kube-node2. On your current session with kube-master1 SSH to
   kube-node2 first and then run the docker command:

   .. important:: Be sure to check which Node your "connector" is running on.

   .. code-block:: bash

      # If directed to, accept the authenticity of the host by typing "yes" and hitting Enter to continue.
      
      ssh kube-node2

      sudo docker ps

   Here we can see our container ID is "e7f69e3ad5c6"

   .. image:: ../images/f5-container-connector-find-dockerID--controller-container.png

   Now we can check our container logs:

   .. code-block:: bash

      sudo docker logs e7f69e3ad5c6

   .. image:: ../images/f5-container-connector-check-logs-controller-container.png

   .. important:: The log messages here are identical to the log messages
      displayed in the previous kubectl logs command. 

#. Exit kube-node2 back to kube-master1

   .. code-block:: bash

      exit

#. You can connect to your container with kubectl as well. This is something
   not typically needed but support may direct you to do so.

   .. important:: Be sure the previous command to exit **kube-node2** back to
      kube-master1 was successfull.

   .. code-block:: bash

      kubectl exec -it k8s-bigip-ctlr-7469c978f9-6hvbv -n kube-system  -- /bin/sh

      cd /app

      ls -la

      exit
