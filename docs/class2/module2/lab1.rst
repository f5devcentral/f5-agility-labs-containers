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
      "okd" partion exists and if not follow the instructions below.

   - GoTo: :menuselection:`System --> Users --> Partition List`
   - Create a new partition called "okd" (use default settings)
   - Click Finished

   .. image:: ../images/f5-container-connector-bigip-partition-setup.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create auth partition okd

#. Install AS3 via the management console

   .. attention:: This has been done to save time. If needed see
      `Module1 / Lab 1.1 / Install AS3 Steps <../module1/lab1.html>`_

#. Create a vxlan tunnel profile

   - GoTo: :menuselection:`Network --> Tunnels --> Profiles --> VXLAN`
   - Create a new profile called "okd-vxlan"
   - set Port = 4789
   - Set the Flooding Type = Multipoint
   - Click Finished

   .. image:: ../images/create-okd-vxlan-profile.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create net tunnel vxlan okd-vxlan { app-service none port 4789 flooding-type multipoint }

#. Create a vxlan tunnel

   - GoTo: :menuselection:`Network --> Tunnels --> Tunnel List`
   - Create a new tunnel called "okd-tunnel"
   - Set the Profile to the one previously created called "okd-vxlan"
   - set the key = 0
   - Set the Local Address to 10.1.1.4
   - Click Finished

   .. image:: ../images/create-okd-vxlan-tunnel.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create net tunnel tunnel okd-tunnel { app-service none key 0 local-address 10.1.1.4 profile okd-vxlan }

#. Create the vxlan tunnel self-ip

   .. tip:: For your SELF-IP subnet, remember it is a /14 and not a /23.

      Why? The Self-IP has to know all other /23 subnets are local to this
      namespace, which includes Master1, Node1, Node2, etc. Each of which have
      their own /23.

      Many students accidently use /23, doing so would limit the self-ip to
      only communicate with that subnet. When trying to ping services on other
      /23 subnets from the BIG-IP for instance, communication will fail as your
      self-ip doesn't have the proper subnet mask to know the other subnets are
      local.

      - GoTo: :menuselection:`Network --> Self IPs`
      - Create a new Self-IP called "okd-vxlan-selfip"
      - Set the IP Address to "10.131.0.1".
      - Set the Netmask to "255.252.0.0"
      - Set the VLAN / Tunnel to "okd-tunnel" (Created earlier)
      - Set Port Lockdown to "Allow All"
      - Click Finished

   .. image:: ../images/create-okd-vxlan-selfip.png

   .. code-block:: bash

      # From the CLI:
      ssh admin@10.1.1.4 tmsh create net self okd-vxlan-selfip { app-service none address 10.131.0.1/14 vlan okd-tunnel allow-service all }

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

#. On the jumphost open a terminal and start an SSH session with okd-master1.

   .. note:: This session should be up and running from the previous module.

   .. code-block:: bash

      # If directed to, accept the authenticity of the host by typing "yes" and hitting Enter to continue.

      ssh centos@okd-master1

#. Just like the previous module where we deployed CIS in NodePort mode we need
   to create a "secret", "serviceaccount", and "clusterrolebinding".

   .. important:: This step can be skipped if previously done in
      module1(NodePort). Some classes may choose to skip module1.

   .. code-block:: bash

      oc create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin
      oc create serviceaccount k8s-bigip-ctlr -n kube-system
      oc create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

#. Next let's explore the f5-hostsubnet.yaml file

   .. code-block:: bash

      cd ~/agilitydocs/docs/class2/openshift

      cat bigip-hostsubnet.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../openshift/bigip-hostsubnet.yaml
      :language: yaml
      :caption: bigip-hostsubnet.yaml
      :linenos:
      :emphasize-lines: 2,9

   .. attention:: This YAML file creates an OpenShift Node and the Host is the
      BIG-IP with an assigned /23 subnet of IP 10.131.0.0 (3 images down).

#. Next let's look at the current cluster, you should see 3 members
   (1 master, 2 nodes)

   .. code-block:: bash

      oc get hostsubnet

   .. image:: ../images/F5-OC-HOSTSUBNET1.png

#. Now create the connector to the BIG-IP device, then look before and after
   at the attached devices

   .. code-block:: bash

      oc create -f bigip-hostsubnet.yaml

   You should see a successful creation of a new OpenShift Node.

   .. image:: ../images/F5-OS-NODE.png

#. At this point nothing has been done to the BIG-IP, this only was done in
   the OpenShift environment.

   .. code-block:: bash

      oc get hostsubnet

   You should now see OpenShift configured to communicate with the BIG-IP

   .. image:: ../images/F5-OC-HOSTSUBNET2.png

   .. important:: The Subnet assignment, in this case is 10.131.0.0/23, was
      assigned by the **subnet: "10.131.0.0/23"** line in "HostSubnet" yaml
      file.

   .. note:: In this lab we're manually assigning a subnet. We have the option
      to let openshift auto assign ths by removing **subnet: "10.131.0.0/23"**
      line at the end of the "hostsubnet" yaml file and setting the
      **assign-subnet: "true"**. It would look like this:

      .. code-block:: yaml
         :emphasize-lines: 7

         apiVersion: v1
         kind: HostSubnet
         metadata:
            name: openshift-f5-node
            annotations:
               pod.network.openshift.io/fixed-vnid-host: "0"
               pod.network.openshift.io/assign-subnet: "true"
         host: openshift-f5-node
         hostIP: 10.1.1.4

#. Now that we have added a HostSubnet for bigip1 we can launch the CIS
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

      oc get deployment k8s-bigip-ctlr --namespace kube-system

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
