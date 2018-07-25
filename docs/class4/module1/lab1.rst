Lab 1.1 - F5 Container Connector Setup
======================================

The official CC documentation is here: `Install the BIG-IP Controller: Openshift <https://clouddocs.f5.com/containers/v2/openshift/kctlr-openshift-app-install.html>`_

BIG-IP Setup
------------

To use F5 Container connector, you'll need a BIG-IP up and running first.

Through the Jumpbox, you should have a BIG-IP available at the following URL: https://10.1.1.245

.. warning:: Connect to your BIG-IP and check it is active and licensed. Its login and password are: **admin/admin**

    If your BIG-IP has no license or its license expired, renew the license. You just need a LTM VE license for this lab. No specific add-ons are required (ask a lab instructor for eval licenses if your license has expired)

#. You need to setup a partition that will be used by F5 Container Connector.

    .. code-block:: bash

        From the CLI:
        tmsh create auth partition ose

        From the UI:
        GoTo System --> Users --> Partition List
        Create a new partition called "ose" (use default settings and click Finished)

    .. image:: images/f5-container-connector-bigip-partition-setup.png
        :align: center

    With the new partition created, we can go back to Openshift to setup the F5 Container connector.

#. configure vxlan tunnel

    .. code-block:: bash

        tmsh create net tunnel vxlan ose-vxlan {app-service none flooding-type multipoint}

        tmsh create net tunnel tunnel ose-tunnel {key 0 local-address 10.10.199.60 profile ose-vxlan}

        tmsh create net self ose-vxlan-selfip address 10.131.0.98/14 vlan ose-tunnel

        tmsh save sys config

Container Connector Deployment
------------------------------

.. note:: For a more thorough explanation of all the settings and options see `F5 Container Connector - Openshift <https://clouddocs.f5.com/containers/v2/openshift/>`_

Now that BIG-IP is licensed and prepped with the "ose" partition, we need to define a `Kubernetes deployment <https://kubernetes.io/docs/user-guide/deployments/>`_ and create a `Kubernetes secret <https://kubernetes.io/docs/user-guide/secrets/>`_ to hide our bigip credentials. 

#. From the jumphost open **mRemoteNG** and start a session with ose-master.

    .. note:: As a reminder we're utilizing a wrapper called **MRemoteNG** for Putty and other services. MRNG hold credentials and allows for multiple protocols(i.e. SSH, RDP, etc.), makes jumping in and out of SSH connections easier.

    On your desktop select **MRemoteNG**, once launched you'll see a few tabs similar to the example below.  Open up the OpenShift Enterprise / OSE-Cluster folder and double click ose-master.

    .. image:: images/MRemoteNG-ose.png
        :align: center

#. "git" the demo files

    .. code-block:: bash

        git clone https://github.com/iluvpcs/f5-agility-labs-containers.git

        cd /root/f5-agility-labs-containers/openshift
        
#. Log in with an Openshift Client.

    .. note:: Here we're using a prebuilt user "demouser" and prompted for a password, which is: demouser

    .. code-block:: console

        oc login -u demouser

    .. image:: images/OC-DEMOuser-Login.png
        :align: center
    
    .. important:: Upon logging in you'll notice access to several projects.  In our lab well be working from the default "demoproject".

#. Create bigip login secret

    .. code-block:: bash

        oc create secret generic bigip-login --from-literal=username=admin --from-literal=password=admin

    You should see something similar to this:

    .. image:: images/f5-container-connector-bigip-secret.png
        :align: center

#. Create kubernetes service account for bigip controller

    .. code-block:: bash

        oc create serviceaccount k8s-bigip-ctlr

    You should see something similar to this:

    .. image:: images/f5-container-connector-bigip-serviceaccount.png
        :align: center


#. Create cluster role for bigip service account (admin rights, but can be modified for your environment)

    .. code-block:: bash

        oc create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=demoproject:k8s-bigip-ctlr

    You should see something similar to this:

    .. image:: images/f5-container-connector-bigip-clusterrolebinding.png
        :align: center

#. Next let's explore the f5-hostsubnet.yaml file

    .. code-block:: console

        cd /root/f5-agility-labs-containers/openshift/

        cat f5-bigip-hostsubnet.yaml

    You'll see a config file similar to this:

    .. literalinclude:: ../../../openshift/f5-bigip-hostsubnet.yaml
            :language: yaml
            :linenos:
            :emphasize-lines: 2,9

    .. attention:: This YAML file creates an OpenShift Node and the Host is the BIG-IP with /23 subnet of IP's (3 images down).

#. Next let's look at the current cluster,  you should see 3 members (1 master, 2 nodes)

    .. code-block:: console

        oc get hostsubnet

    .. image:: images/F5-OC-HOSTSUBNET1.png
        :align: center

#. Now create the connector to the BIG-IP device, then look before and after at the attached devices

    .. code-block:: console

        oc create -f f5-bigip-hostsubnet.yaml

    You should see a successful creation of a new OpenShift Node.

    .. image:: images/F5-OS-NODE.png
        :align: center

#. At this point nothing has been done to the BIG-IP, this only was done in the OpenShift environment.

    .. code-block:: console

        oc get hostsubnet

    You should now see OpenShift configured to communicate with the BIG-IP

    .. image:: images/F5-OC-HOSTSUBNET2.png
        :align: center

    .. note:: The Subnet assignment, in our case 10.129.2.0/23.

#. Now we'll create an Openshift F5 Container Connector to do the API calls to/from the F5 device. First we need the "deployment" file.

    .. code-block:: console

        cd /root/f5-agility-labs-containers/openshift/

        cat f5-cluster-deployment.yaml

    You'll see a config file similar to this:

    .. literalinclude:: ../../../openshift/f5-cluster-deployment.yaml
        :language: yaml
        :linenos:
        :emphasize-lines: 2,5,17,34-38

#. Create the container connector deployment with the following command

    .. code-block:: console

        oc create -f f5-cluser-deployment.yaml

#. Check for successful creation:

    .. code-block:: console

        oc get pods -o wide

    .. image:: images/F5-CTRL-RUNNING.png
        :align: center
