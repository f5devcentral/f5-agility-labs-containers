Lab 2.1 - CIS Install & Configuration (NodePort)
================================================

The BIG-IP Controller for OpenShift installs as a
`Deployment object <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>`_

.. seealso:: The official CIS documentation is here:
   `Install the BIG-IP Controller: Openshift <https://clouddocs.f5.com/containers/v2/openshift/kctlr-openshift-app-install.html>`_

BIG-IP Setup
------------

To use F5 Container Ingress Service, you'll need a BIG-IP up and running first.

Through the Jumpbox, you should have a BIG-IP available at the following
URL: https://10.1.1.4

.. warning:: 
   - Connect to your BIG-IP and check it is active and licensed. Its
     login and password are: **admin/admin**

   - If your BIG-IP has no license or its license expired, renew the license.
     You just need a LTM VE license for this lab. No specific add-ons are
     required (ask a lab instructor for eval licenses if your license has
     expired)

   - Be sure to be in the ``Common`` partition before creating the following
     objects.

     .. image:: images/f5-check-partition.png

#. You need to setup a partition that will be used by F5 Container Ingress Service.

   .. code-block:: bash

      # From the CLI:
      tmsh create auth partition okd

      # From the UI:
      GoTo System --> Users --> Partition List
      - Create a new partition called "okd" (use default settings)
      - Click Finished

   .. image:: images/f5-container-connector-bigip-partition-setup.png

#. Create a vxlan tunnel profile

   .. code-block:: bash

      # From the CLI:
      tmsh create net tunnel vxlan okd-vxlan {app-service none flooding-type multipoint}

      # From the UI:
      GoTo Network --> Tunnels --> Profiles --> VXLAN
      - Create a new profile called "okd-vxlan"
      - Set the Flooding Type = Multipoint
      - Click Finished

   .. image:: images/create-okd-vxlan-profile.png

#. Create a vxlan tunnel

   .. code-block:: bash

      # From the CLI:
      tmsh create net tunnel tunnel okd-tunnel {key 0 local-address 10.1.1.4 profile okd-vxlan}

      # From the UI:
      GoTo Network --> Tunnels --> Tunnel List
      - Create a new tunnel called "okd-tunnel"
      - Set the Local Address to 10.1.1.4
      - Set the Profile to the one previously created called "okd-vxlan"
      - Click Finished

   .. image:: images/create-okd-vxlan-tunnel.png

CIS Deployment
--------------

.. seealso:: For a more thorough explanation of all the settings and options see
   `F5 Container Ingress Service - Openshift <https://clouddocs.f5.com/containers/v2/openshift/>`_

Now that BIG-IP is licensed and prepped with the "okd" partition, we need to
define a `Kubernetes deployment <https://kubernetes.io/docs/user-guide/deployments/>`_
and create a `Kubernetes secret <https://kubernetes.io/docs/user-guide/secrets/>`_
to hide our bigip credentials.

#. From the jumpbox open **mRemoteNG** and start a session with okd-master.

   .. note:: As a reminder we're utilizing a wrapper called **MRemoteNG** for
      Putty and other services. MRNG hold credentials and allows for multiple
      protocols(i.e. SSH, RDP, etc.), makes jumping in and out of SSH
      connections easier.

   On your desktop select **MRemoteNG**, once launched you'll see a few tabs
   similar to the example below.  Open up the OpenShift Enterprise /
   okd-Cluster folder and double click okd-master.

   .. image:: images/MRemoteNG-okd.png

#. "git" the demo files

   .. note:: These files should be here by default, if **NOT** run the
      following commands.

   .. code-block:: bash

      git clone https://github.com/f5devcentral/f5-agility-labs-containers.git ~/agilitydocs

      cd ~/agilitydocs/openshift

#. Log in with an Openshift Client.

   .. attention:: You can skip this step if done in the previous module.

   .. note:: Here we're using a user "centos", added when we built the cluster.
      When prompted for password, enter "centos".

   .. code-block:: bash

      oc login -u centos -n default

   .. image:: images/OC-DEMOuser-Login.png

   .. important:: Upon logging in you'll notice access to several projects. In
      our lab well be working from the default "default".

#. Create bigip login secret

   .. code-block:: bash

      oc create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin

   You should see something similar to this:

   .. image:: images/f5-container-connector-bigip-secret.png

#. Create kubernetes service account for bigip controller

   .. code-block:: bash

      oc create serviceaccount k8s-bigip-ctlr -n kube-system

   You should see something similar to this:

   .. image:: images/f5-container-connector-bigip-serviceaccount.png

#. Create cluster role for bigip service account (admin rights, but can be
   modified for your environment)

   .. code-block:: bash

      oc create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

   You should see something similar to this:

   .. image:: images/f5-container-connector-bigip-clusterrolebinding.png

#. Next let's explore the f5-hostsubnet.yaml file

   .. code-block:: bash

      cd /root/agilitydocs/openshift

      cat f5-bigip-hostsubnet.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../openshift/f5-bigip-hostsubnet.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,9

   .. attention:: This YAML file creates an OpenShift Node and the Host is the
      BIG-IP with an assigned /23 subnet of IP 10.131.0.0 (3 images down).

#. Next let's look at the current cluster,  you should see 3 members
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
      tmsh create net self okd-vxlan-selfip address 10.131.0.1/14 vlan okd-tunnel

      # From the UI:
      GoTo Network --> Self IP List
      - Create a new Self-IP called "okd-vxlan-selfip"
      - Set the IP Address to "10.131.0.1". (An IP from the subnet assigned in the previous step.)
      - Set the Netmask to "255.252.0.0"
      - Set the VLAN / Tunnel to "okd-tunnel" (Created earlier)
      - Set Port Lockdown to "Allow All"
      - Click Finished

   .. image:: images/create-okd-vxlan-selfip.png

#. Now we'll create an Openshift F5 Container Ingress Service to do the API
   calls to/from the F5 device. First we need the "deployment" file.

   .. code-block:: bash

      cd /root/agilitydocs/openshift

      cat f5-cluster-deployment.yaml

   You'll see a config file similar to this:

   .. literalinclude:: ../openshift/f5-cluster-deployment.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,5,17,34-38

#. Create the CIS deployment with the following command

   .. code-block:: bash

      oc create -f f5-cluster-deployment.yaml

#. Check for successful creation:

   .. code-block:: bash

      oc get pods -n kube-system -o wide

   .. image:: images/F5-CTRL-RUNNING.png

#. If the tunnel is up and running big-ip should be able to ping the cluster
   nodes. SSH to big-ip and run one or all of the following ping tests.

   .. hint:: To SSH to big-ip use mRemoteNG and the bigip1 shortcut

      .. image:: images/MRemoteNG-bigip.png
         
   .. code-block:: bash

      # ping okd-master
      ping -c 4 10.128.0.1

      # ping okd-node1
      ping -c 4 10.129.0.1

      # ping okd-node2
      ping -c 4 10.130.0.1
