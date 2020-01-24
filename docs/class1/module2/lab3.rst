Lab 2.3 - CIS Install & Configuration (ClusterIP)
=================================================

.. attention:: This lab relies on many of the objects created in lab1.

BIG-IP Setup
------------

.. important:: Be sure to switch to the "Common" partition before making the
   following changes.

With ClusterIP we're utilizing vxlan to communicate with the application pods.
To do so we'll need to configure bigip.

#. Create a vxlan tunnel profile

   .. code-block:: bash

      # From the CLI:
      tmsh create net tunnels vxlan k8s-vxlan { app-service none port 8472 flooding-type none }

      # From the UI:
      GoTo Network --> Tunnels --> Profiles --> VXLAN
      - Create a new profile called "k8s-vxlan"
      - Set Port = 8472
      - Set the Flooding Type = none
      - Click Finished

   .. image:: images/create-k8s-vxlan-profile.png

#. Create a vxlan tunnel

   .. code-block:: bash

      # From the CLI:
      tmsh create net tunnels tunnel k8s-tunnel { app-service none key 1 local-address 10.1.1.4 profile k8s-vxlan }

      # From the UI:
      GoTo Network --> Tunnels --> Tunnel List
      - Create a new tunnel called "k8s-tunnel"
      - Set the Local Address to 10.1.1.4
      - Set the Profile to the one previously created called "k8s-vxlan"
      - Click Finished

   .. image:: images/create-k8s-vxlan-tunnel.png

#. Create the vxlan tunnel self-ip

   .. tip:: For your SELF-IP subnet, remember it is a /16 and not a /24 -
      Why? The Self-IP has to be able to understand those other /24 subnets are
      local in the namespace in the example above for Master, Node1, Node2,
      etc. Many students accidently use /24, but then the self-ip will be only
      to communicate to one subnet on the openshift-f5-node. When trying to
      ping across to services on other /24 subnets from the BIG-IP for instance,
      communication will fail as your self-ip doesn't have the proper subnet
      mask to know thokd other subnets are local.
      
   .. code-block:: bash
      
      # From the CLI:
      tmsh create net self k8s-vxlan-selfip { address 10.244.20.1/16 vlan k8s-tunnel allow-service all }

      # From the UI:
      GoTo Network --> Self IP List
      - Create a new Self-IP called "k8s-vxlan-selfip"
      - Set the IP Address to "10.244.20.1"
      - Set the Netmask to "255.255.0.0"
      - Set the VLAN / Tunnel to "k8s-tunnel" (Created earlier)
      - Set Port Lockdown to "Allow All"
      - Click Finished

   .. image:: images/create-k8s-vxlan-selfip.png

CIS Deployment
--------------

#. As stated in lab1, we have two deployment mode options, Nodeport or
   ClusterIP. For more information see
   `BIG-IP Controller Modes <http://clouddocs.f5.com/containers/v2/kubernetes/kctlr-modes.html>`_

   **ClusterIP mode** ``f5-cluster-deployment.yaml``

   .. note:: 
      - For your convenience the file can be found in
        /home/ubuntu/agilitydocs/docs/class1/kubernetes (downloaded earlier in
        the clone git repo step).
      - Or you can cut and paste the file below and create your own file.
      - If you have issues with your yaml and syntax (**indentation MATTERS**),
        you can try to use an online parser to help you :
        `Yaml parser <http://codebeautify.org/yaml-validator>`_

   .. literalinclude:: ../kubernetes/f5-cluster-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,7,17,20,37,38,40,41

#. Before deploying CIS in Cluster mode we need to configure Big-IP as a node
   in the kubernetes cluster. To do so you'll need to modify
   "f5-bigip-node.yaml" with the MAC address auto created from the previous
   steps. SSH to BIG-IP and run the following command. You'll want to copy the
   displayed "MAC Address".

   .. code-block:: bash
      
      tmsh show net tunnels tunnel fl-vxlan all-properties

   .. image:: images/get-k8s-tunnel-mac-addr.png

#. On the kube-master node edit f5-bigip-node.yaml

   .. code-block:: bash

      vim /home/ubuntu/agilitydocs/docs/class1/kubernetes/f5-bigip-node.yaml

      and edit the highlighted MAC addr line with your addr shown below:

   .. literalinclude:: ../kubernetes/f5-bigip-node.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 9

#. Create the bigip node:

   .. code-block:: bash

      kubectl create -f f5-bigip-node.yaml

#. Now that we have the new bigip node added you can try to launch your
   deployment. It will start our f5-k8s-controller container on one of our
   nodes (may take around 30sec to be in a running state):

   .. code-block:: bash

      kubectl create -f f5-cluster-deployment.yaml

#. Verify the deployment "deployed"

   .. code-block:: bash

      kubectl get deployment k8s-bigip-ctlr-deployment --namespace kube-system

   .. image:: images/f5-container-connector-launch-deployment-controller.png

#. To locate on which node CIS is running, you can use the following command:

   .. code-block:: bash

      kubectl get pods -o wide -n kube-system

   We can see that our container is running on kube-node2 below.

   .. image:: images/f5-container-connector-locate-controller-container.png

Troubleshooting
---------------

If you need to troubleshoot your container, you have two different ways to
check the logs of your container, kubectl command or docker command.

#. Using kubectl command: you need to use the full name of your pod as
   showed in the previous image

   .. code-block:: bash

      # For example:
      kubectl logs k8s-bigip-ctlr-deployment-5b74dd769-x55vx -n kube-system

   .. image:: images/f5-container-connector-check-logs-kubectl.png

#. If the tunnel is up and running big-ip should be able to ping the cluster
   nodes. SSH to big-ip and run one or all of the following ping tests.

   .. code-block:: bash

      # ping kube-master1
      ping -c 4 10.244.0.1

      # ping kube-node1
      ping -c 4 10.244.1.1

      # ping kube-node2
      ping -c 4 10.244.2.1
