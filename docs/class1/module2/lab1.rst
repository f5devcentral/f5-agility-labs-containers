Lab 2.1 - Install & Configure CIS in ClusterIP Mode
===================================================

In the previous moudule we learned about Nodeport Mode. Here we'll learn
about ClusterIP Mode.

.. seealso::
   For more information see `BIG-IP Controller Modes <http://clouddocs.f5.com/containers/v2/kubernetes/kctlr-modes.html>`_

BIG-IP Setup
------------
With ClusterIP we're utilizing VXLAN to communicate with the application pods.
To do so we'll need to configure BIG-IP first.

If not already connected, RDP to the UDF lab "jumpbox" host. Otherwise resume
previous session.

#. Open firefox and connect to bigip1. For your convenience there's a shortcut
   on the toolbar. Username and password are: **admin/admin**

.. attention::
   Be sure to be in the ``Common`` partition before creating the following
   objects.

   .. image:: ../images/f5-check-partition.png

#. First we need to setup a partition that will be used by F5 Container Ingress
   Service.

   .. note:: This step was performed in the previous module. Verify the
      "kubernetes" partion exists and if not follow the instructions below.

   - GoTo: :menuselection:`System --> Users --> Partition List`
   - Create a new partition called "kubernetes" (use default settings)
   - Click Finished

   .. image:: ../images/f5-container-connector-bigip-partition-setup.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create auth partition kubernetes

#. Install AS3 via the management console

   .. attention:: This has been done to save time. If needed see
      `Module1 / Lab 1.1 / Install AS3 Steps <../module1/lab1.html>`_

#. Create a vxlan tunnel profile.

   - GoTo: :menuselection:`Network --> Tunnels --> Profiles --> VXLAN`
   - Create a new profile called "fl-vxlan"
   - Set Port = 8472
   - Set the Flooding Type = none
   - Click Finished

   .. image:: ../images/create-fl-vxlan-profile.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create net tunnels vxlan fl-vxlan { app-service none port 8472 flooding-type none }

#. Create a vxlan tunnel.

   - GoTo: :menuselection:`Network --> Tunnels --> Tunnel List`
   - Create a new tunnel called "fl-tunnel"
   - Set the Profile to the one previously created called "fl-vxlan"
   - set the Key = 1
   - Set the Local Address to 10.1.1.4
   - Click Finished

   .. image:: ../images/create-fl-vxlan-tunnel.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create net tunnels tunnel fl-tunnel { app-service none key 1 local-address 10.1.1.4 profile fl-vxlan }

#. Create the vxlan tunnel self-ip

   .. tip:: For your SELF-IP subnet, remember it is a /16 and not a /24.

      Why? The Self-IP has to know all other /24 subnets are local to this
      namespace, which includes Master1, Node1, Node2, etc. Each of which have
      their own /24.

      Many students accidently use /24, doing so would limit the self-ip to
      only communicate with that subnet. When trying to ping services on other
      /24 subnets from the BIG-IP for instance, communication will fail as your
      self-ip doesn't have the proper subnet mask to know the other subnets are
      local.

   - GoTo: :menuselection:`Network --> Self IPs`
   - Create a new Self-IP called "fl-vxlan-selfip"
   - Set the IP Address to "10.244.20.1"
   - Set the Netmask to "255.255.0.0"
   - Set the VLAN / Tunnel to "fl-tunnel" (Created earlier)
   - Set Port Lockdown to "Allow All"
   - Click Finished

   .. image:: ../images/create-fl-vxlan-selfip.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create net self fl-vxlan-selfip { address 10.244.20.1/16 vlan fl-tunnel allow-service all }

CIS Deployment
--------------

.. note::
   - For your convenience the file can be found in
     /home/ubuntu/agilitydocs/docs/class1/kubernetes (downloaded earlier in the
     git clone repo step).
   - Or you can cut and paste the file below and create your own file.
   - If you have issues with your yaml and syntax (**indentation MATTERS**),
     you can try to use an online parser to help you :
     `Yaml parser <http://codebeautify.org/yaml-validator>`_

#. Before deploying CIS in ClusterIP mode we need to configure Big-IP as a node
   in the kubernetes cluster. To do so you'll need to modify
   "bigip-node.yaml" with the MAC address auto created from the previous
   steps. From the jumpbox terminal run the following command at bigip1. You'll
   want to copy the displayed "MAC Address".

   .. code-block:: bash

      # If directed to, accept the authenticity of the host by typing "yes" and hitting Enter to continue.
      # The password is "admin"

      ssh admin@10.1.1.4 tmsh show net tunnels tunnel fl-tunnel all-properties

   .. image:: ../images/get-fl-tunnel-mac-addr.png

#. On kube-master1 edit bigip-node.yaml and change the highlighted MAC address
   with the MAC address copied from the previous step.

   .. note:: If your unfamiliar with VI ask for help.

   .. code-block:: bash

      vim ~/agilitydocs/docs/class1/kubernetes/bigip-node.yaml

      i           # To enable insert mode and start editing
                  # Replace the current MAC addr with the one previously copied
      <ESC>       # To exit insert mode
      :wq <ENTER> # To write and exit file

   .. literalinclude:: ../kubernetes/bigip-node.yaml
      :language: yaml
      :caption: bigip-node.yaml
      :linenos:
      :emphasize-lines: 9

#. Create the bigip node:

   .. code-block:: bash

      kubectl create -f bigip-node.yaml

#. Verify "bigip1" node is created:

   .. code-block:: bash

      kubectl get nodes

   .. image:: ../images/create-bigip1.png

   .. note:: It's normal for bigip1 to show up as "Unknown" or "NotReady". This
      status can be ignored.

#. Just like the previous module where we deployed CIS in NodePort mode we need
   to create a "secret", "serviceaccount", and "clusterrolebinding".

   .. important:: This step can be skipped if previously done in
      module1(NodePort). Some classes may choose to skip module1.

   .. code-block:: bash

      kubectl create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin
      kubectl create serviceaccount k8s-bigip-ctlr -n kube-system
      kubectl create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

#. Now that we have bigip1 added as a Node we can launch the CIS deployment. It
   will start the f5-k8s-controller container on one of the worker nodes.

   .. attention:: This may take around 30sec to get to a running state.

   .. code-block:: bash

      cd ~/agilitydocs/docs/class1/kubernetes

      cat cluster-deployment.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../kubernetes/cluster-deployment.yaml
      :language: yaml
      :caption: cluster-deployment.yaml
      :linenos:
      :emphasize-lines: 2,7,17,20,37,39-41

#. Create the CIS deployment with the following command

   .. code-block:: bash

      kubectl create -f cluster-deployment.yaml

#. Verify the deployment "deployed"

   .. code-block:: bash

      kubectl get deployment k8s-bigip-ctlr --namespace kube-system

   .. image:: ../images/f5-container-connector-launch-deployment-controller2.png

#. To locate on which node CIS is running, you can use the following command:

   .. code-block:: bash

      kubectl get pods -o wide -n kube-system

   We can see that our container, in this example, is running on kube-node1
   below.

   .. image:: ../images/f5-container-connector-locate-controller-container2.png

Troubleshooting
---------------

Check the container/pod logs via ``kubectl`` command. You also have the option
of checking the Docker container as described in the previos module.

#. Using the full name of your pod as showed in the previous image run the
   following command:

   .. code-block:: bash

      # For example:
      kubectl logs k8s-bigip-ctlr-846dcb5958-zzvc8 -n kube-system

   .. image:: ../images/f5-container-connector-check-logs-kubectl2.png

   .. attention:: You will see **ERROR** in this log output. These errors can
      be ignored. The lab will work as expected.
