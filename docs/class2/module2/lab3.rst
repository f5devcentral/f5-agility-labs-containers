Lab 2.3 - CIS Install & Configuration (ClusterIP)
=================================================

BIG-IP Setup
------------

With ClusterIP we're utilizing VXLAN to communicate with the application pods.
To do so we'll need to configure bigip first.

#. You need to setup a partition that will be used by F5 Container Ingress
   Service.

   .. note:: This step was performed in the previous lab.

   .. code-block:: bash

      # From the CLI:
      tmsh create auth partition okd

      # From the UI:
      GoTo System --> Users --> Partition List
      - Create a new partition called "okd" (use default settings)
      - Click Finished

   .. image:: images/f5-container-connector-bigip-partition-setup.png

.. attention:: Be sure to switch to the "Common" partition before making the
   following changes.

#. Create a vxlan tunnel profile

   .. code-block:: bash

      # From the CLI:
      tmsh create net tunnel vxlan okd-vxlan { app-service none flooding-type multipoint }

      # From the UI:
      GoTo Network --> Tunnels --> Profiles --> VXLAN
      - Create a new profile called "okd-vxlan"
      - Set the Flooding Type = Multipoint
      - Click Finished

   .. image:: images/create-okd-vxlan-profile.png

#. Create a vxlan tunnel

   .. code-block:: bash

      # From the CLI:
      tmsh create net tunnel tunnel okd-tunnel { app-service none key 0 local-address 10.1.1.4 profile okd-vxlan }

      # From the UI:
      GoTo Network --> Tunnels --> Tunnel List
      - Create a new tunnel called "okd-tunnel"
      - Set the Profile to the one previously created called "okd-vxlan"
      - set the key = 0
      - Set the Local Address to 10.1.1.4
      - Click Finished

   .. image:: images/create-okd-vxlan-tunnel.png

#. Create the vxlan tunnel self-ip

   .. tip:: For your SELF-IP subnet, remember it is a /14 and not a /23 -
      Why? The Self-IP has to be able to understand those other /23 subnets are
      local in the namespace in the example above for Master, Node1, Node2,
      etc. Many students accidently use /23, but then the self-ip will be only
      to communicate to one subnet on the openshift-f5-node. When trying to
      ping across to services on other /23 subnets from the BIG-IP for instance,
      communication will fail as your self-ip doesn't have the proper subnet
      mask to know thokd other subnets are local.
      
   .. code-block:: bash
      
      # From the CLI:
      tmsh create net self okd-vxlan-selfip { app-service none address 10.131.0.1/14 vlan okd-tunnel allow-service all }

      # From the UI:
      GoTo Network --> Self IP List
      - Create a new Self-IP called "okd-vxlan-selfip"
      - Set the IP Address to "10.131.0.1".
      - Set the Netmask to "255.252.0.0"
      - Set the VLAN / Tunnel to "okd-tunnel" (Created earlier)
      - Set Port Lockdown to "Allow All"
      - Click Finished

   .. image:: images/create-okd-vxlan-selfip.png

CIS Deployment
--------------

As stated in lab1, we have two deployment mode options, Nodeport or ClusterIP.
For more information see `BIG-IP Controller Modes <http://clouddocs.f5.com/containers/v2/kubernetes/kctlr-modes.html>`_

Here we'll configure **ClusterIP mode** ``f5-cluster-deployment.yaml``

.. note::
   - For your convenience the file can be found in
     /home/ubuntu/agilitydocs/docs/class2/openshift (downloaded earlier in the
     clone git repo step).
   - Or you can cut and paste the file below and create your own file.
   - If you have issues with your yaml and syntax (**indentation MATTERS**),
     you can try to use an online parser to help you :
     `Yaml parser <http://codebeautify.org/yaml-validator>`_

.. literalinclude:: ../openshift/f5-cluster-deployment.yaml
   :language: yaml
   :linenos:
   :emphasize-lines: 2,7,17,20,37,38,40,41

#. On okd-master1, log in with an Openshift Client.

   .. note:: Here we're using a user "centos", added when we built the cluster.
      When prompted for password, enter "centos".

   .. code-block:: bash

      oc login -u centos -n default

   .. image:: images/OC-DEMOuser-Login.png

   .. important:: Upon logging in you'll notice access to several projects. In
      our lab well be working from the default "default".

#. Next let's explore the f5-hostsubnet.yaml file

   .. code-block:: bash

      cd ~/agilitydocs/docs/class2/openshift

      cat f5-bigip-hostsubnet.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../openshift/f5-bigip-hostsubnet.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,9

   .. attention:: This YAML file creates an OpenShift Node and the Host is the
      BIG-IP with an assigned /23 subnet of IP 10.131.0.0 (3 images down).

#. Next let's look at the current cluster, you should see 3 members
   (1 master, 2 nodes)

   .. code-block:: bash

      oc get hostsubnet

   .. image:: images/F5-OC-HOSTSUBNET1.png

#. Now create the connector to the BIG-IP device, then look before and after
   at the attached devices

   .. code-block:: bash

      oc create -f f5-bigip-hostsubnet.yaml

   You should see a successful creation of a new OpenShift Node.

   .. image:: images/F5-OS-NODE.png

#. At this point nothing has been done to the BIG-IP, this only was done in
   the OpenShift environment.

   .. code-block:: bash

      oc get hostsubnet

   You should now see OpenShift configured to communicate with the BIG-IP

   .. image:: images/F5-OC-HOSTSUBNET2.png

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

#. Now that we have the new bigip node added you can try to launch your
   deployment. It will start our f5-k8s-controller container on one of our
   nodes (may take around 30sec to be in a running state):

   .. code-block:: bash

      cd ~/agilitydocs/docs/class2/openshift

      cat f5-cluster-deployment.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../openshift/f5-cluster-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,17,20,37-41

#. Create the CIS deployment with the following command

   .. code-block:: bash

      oc create -f f5-cluster-deployment.yaml

#. Verify the deployment "deployed"

   .. code-block:: bash

      kubectl get deployment k8s-bigip-ctlr --namespace kube-system

   .. image:: images/f5-container-connector-launch-deployment-controller.png

#. To locate on which node CIS is running, you can use the following command:

   .. code-block:: bash

      oc get pods -o wide -n kube-system

   .. image:: images/F5-CTRL-RUNNING.png

Troubleshooting
---------------

If you need to troubleshoot your container, you have two different ways to
check the logs of your container, kubectl command or docker command.

#. Using kubectl command: you need to use the full name of your pod as
   showed in the previous image

   .. code-block:: bash

      # For example:
      kubectl logs k8s-bigip-ctlr-8c6cf8667-htcgw -n kube-system

   .. image:: images/f5-container-connector-check-logs-kubectl.png
