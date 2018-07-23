Lab 1.1 - F5 Container Connector Setup
======================================

The official CC documentation is here: `Install the BIG-IP Controller: Openshift <https://clouddocs.f5.com/containers/v2/openshift/kctlr-openshift-app-install.html>`_

BIG-IP Setup
------------

The BIG-IP we are working on has been licensed, and only these following commands below has been issued in the CLI so we have a very new/basic BIG-IP configured.

    .. code-block:: console

        License BIG-IP

        tmsh create net vlan external-ose interfaces add {1.2}

        tmsh create net self ose-selfip address 10.10.199.60/24 vlan external-ose

        tmsh create auth partition ose

        tmsh create net tunnel vxlan ose-vxlan {app-service none flooding-type multipoint}

        tmsh create net tunnel tunnel ose-tunnel {key 0 local-address 10.10.199.60 profile ose-vxlan}

        tmsh save sys config

    .. note:: Typically the command below is entered after running the ''oc create -f f5-hostsubnet.yaml'' command coming up in the next section (This is the range the self ip should come from, to make this lab quicker we have already done this tmsh command)**

    .. code-block:: console

        tmsh create net self <IP>/subnet vlan <tunnel>

        tmsh create net self ose-vxlan-selfip address 10.131.0.98/14 vlan ose-tunnel

Let's validate your BIG-IP is just configured with VLANs, Self-IPs.  No Virtual Servers and no Pools. From the jumphost connect to your BIG-IP on https://10.1.1.245

#. Go to Local Traffic --> Network --> VLANs.  You should have an external VLAN

    .. image:: images/F5-BIG-IP-NETWORK-VLAN.png
        :align: center

#. Go to Local Traffic -> Network -> Self-IP.  You should have an external SELF-IPs

    .. image:: images/F5-BIG-IP-NETWORK-SELFIP.png
        :align: center

#. Go to Local Traffic -> Network -> Tunnel.  You should see something similar to this:

    .. image:: images/F5-BIG-IP-NETWORK-TUNNEL.png
        :align: center

#. Lastly, validate there are no Virtual Servers and no Pools.  Go to Local Traffic -> Virtual Servers and then Pools.

    .. note:: Be sure to select the ose partition.

    .. image:: images/F5-BIG-IP-LOCAL_TRAFFIC-POOL.png
        :align: center

    .. important:: If you find something missing in the last several steps/checks be sure to ask a lab assistant or add the missing component.  If all checks out move to the next section "Container Connector Deployment".

Container Connector Deployment
------------------------------

The official CC documentation is here: `F5 Container Connector - OpenShift <http://clouddocs.f5.com/containers/v2/openshift/>`_

#. From the jumphost open **mRemoteNG**, go to the OpenShift folder, and connect to OSE-Master

    .. attention:: The following steps need to be run on **ose-master** unless otherwise specified.

    .. image:: images/MremoteNG.png
        :align: center

#. The next step logs you into Openshift Client

    .. code-block:: console

        oc login -u demouser

    .. note:: You will be prompted for password, which is: demouser

    .. image:: images/OC-DEMOuser-Login.png
        :align: center

#. Next let's explore the f5-hostsubnet.yaml file

    .. code-block:: console

        cat f5-hostsubnet.yaml

    You'll see a config file similar to this:

    .. image:: images/F5-HOSTSUBNET-YAML.png
        :align: center

    .. note:: This YAML file creates an OpenShift Node and the Host is the BIG-IP with /23 subnet of IP's (3 images down).

#. Next let's look at the current cluster,  you should see 3 members (1 master, 2 nodes)

    .. code-block:: console

        oc get hostsubnet

    .. image:: images/F5-OC-HOSTSUBNET1.png
        :align: center

#. Let create the connector to the BIG-IP device, then look before and after at the attached devices

    .. code-block:: console

        oc create -f f5-hostsubnet.yaml

    You should see a successful creation a new OpenShift Node

    .. image:: images/F5-OS-NODE.png
        :align: center

#. Nothing has been done yet to the BIG-IP, this only was done in the OpenShift environment.

    .. code-block:: console

        oc get hostsubnet

    You should now see  OpenShift configured to communicate with the BIG-IP

    .. image:: images/F5-OC-HOSTSUBNET2.png
        :align: center

#. The next step is to do is create an Openshift F5 Container Connector to do the API calls to/from the F5 device. First, let us examine a few items in a configuration YAML file.  

    .. note:: You can ''cat f5-cc.yaml'' or just review the config below.

    - Credentials to authenticate to the BIG-IP
    - Container image name
    - Namespace this container will live in
    - IP of the BIP-IP to communicate to for API calls
    - Which tunnel to use to/from the BIG-IP

    .. literalinclude:: ../../../openshift/f5-cc.yaml
        :language: yaml
        :linenos:
        :emphasize-lines: 2,16,19-21,24

#. From the OSE-Master CLI, enter

    .. code-block:: console

        oc create -f f5-cc.yaml

    .. note:: As ContainerCreating is dependent on many factors i.e. first download remotely, you host your own local images, or it's already cached on the host. I've seen 20 containers spin up <1 second on my laptop, as well as minutes depending on long downloads of the image first time.

    .. image:: images/F5-CTRL-RUNNING.png
        :align: center
