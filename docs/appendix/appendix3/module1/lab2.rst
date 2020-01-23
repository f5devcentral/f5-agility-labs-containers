Lab 1.2 - Configure VXLAN (OpenShift and Big-IP)
================================================

.. important:: This solution applies to BIG-IP devices v13.x and later only. To
   accomplish High Availability (HA) active-standby pair or device group with
   OpenShift the BIG-IP needs to create a floating vxlan tunnel address with is
   currently only available in BIG-IP 13.x and later.

Configure VXLAN on Openshift
----------------------------

HostSubnets must use valid YAML. You can upload the files individually using
separate oc create commands. 

Create one HostSubnet for each BIG-IP device. These will handle health monitor
traffic. 

Also create one HostSubnet to pass client traffic. You will create the floating
IP address for the active device in this subnet as shown in the diagram above. 

#. Create new OpenShift HostSubnet's for bigip.

   .. attention:: We have created the YAML files to save time. The files are
      located at **/home/centos/agilitydocs/openshift/advanced/ocp** on
      **ose-master1**

      cd /home/centos/agilitydocs/openshift/advanced/ocp

   hs-bigip1.yaml

   .. literalinclude:: ../openshift/advanced/ocp/hs-bigip1.yaml
      :language: yaml
      :emphasize-lines: 3,4,9

   hs-bigip2.yaml

   .. literalinclude:: ../openshift/advanced/ocp/hs-bigip2.yaml
      :language: yaml
      :emphasize-lines: 3,4,9

   hs-bigip-float.yaml

   .. literalinclude:: ../openshift/advanced/ocp/hs-bigip-float.yaml
      :language: yaml
      :emphasize-lines: 3,4,9

   Create the HostSubnet files to the OpenShift API server. Run the following
   commands from the **master**

   .. code-block:: bash

      oc create -f hs-bigip1.yaml
      oc create -f hs-bigip2.yaml
      oc create -f hs-bigip-float.yaml

#. Verify creation of the HostSubnets:

   .. code-block:: bash

      oc get hostsubnet

   .. image:: images/oc-get-hostsubnet.png

Configure VXLAN on BIG-IP
-------------------------

.. important:: The BIG-IP OpenShift Controller cannot manage objects in the
   /Common partition. 

   Its recommended to create all HA using the /Common partition

.. tip:: You can copy and paste the following commands to be run directly
   from the OpenShift **master** (ose-master1). To paste content into
   mRemoteNG; use your right mouse button.

#. Create a new partition on your BIG-IP system

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh create auth partition ocp
      ssh root@10.1.1.246 tmsh create auth partition ocp

#. Creating ocp-profile

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint
      ssh root@10.1.1.246 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint

#. Creating floating IP for underlay network

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh create net self ose-float address 10.3.10.59/24 vlan external-ose traffic-group traffic-group-1 allow-service default
      ssh root@10.1.1.245 tmsh run cm config-sync to-group device-group-ose

#. Creating vxlan tunnel ocp-tunnel

   .. note:: the delete commands are there to cleanup entries from the previous
      class.

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh delete net self ose-vxlan-selfip
      ssh root@10.1.1.245 tmsh delete net fdb tunnel ose-tunnel all-records
      ssh root@10.1.1.245 tmsh delete net tunnels tunnel ose-tunnel
      ssh root@10.1.1.245 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.3.10.59 secondary-address 10.3.10.60 traffic-group traffic-group-1
      ssh root@10.1.1.246 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.3.10.59 secondary-address 10.3.10.61 traffic-group traffic-group-1

#. Creating overlay self-ip

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh create net self ocp-tunnel-selfip address 10.131.0.1/14 vlan ocp-tunnel allow-service all
      ssh root@10.1.1.246 tmsh create net self ocp-tunnel-selfip address 10.131.2.1/14 vlan ocp-tunnel allow-service all

#. Creating floating IP for overlay network

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh create net self ocp-tunnel-float address 10.131.4.1/14 vlan ocp-tunnel traffic-group traffic-group-1 allow-service all
      ssh root@10.1.1.245 tmsh run cm config-sync to-group device-group-ose

#. Saving configuration

   .. code-block:: bash

      ssh root@10.1.1.245 tmsh save sys config
      ssh root@10.1.1.246 tmsh save sys config

Before adding the BIG-IP controller to OpenShift validate the partition and
tunnel configuration

#. Validate that the OCP bigip partition was created

   .. image:: images/partition.png

#. Validate **bigip1** self IP configuration

   .. note:: On the active device, there is floating IP address in the subnet
      assigned by the OpenShift SDN.

   .. image:: images/self-ip-bigip01-ha.png

#. Validate **bigip2** self IP configuration

   .. image:: images/self-ip-bigip02-ha.png

#. Check the ocp-tunnel configuration (:menuselection:`Network --> Tunnels -->
   Tunnel List`).
   
   .. note:: The local-address 10.3.10.59 and secondary-address are 10.3.10.60
      for **bigip1** and 10.3.10.61 for **bigip2**. The secondary-address will
      be used to send monitor traffic and the local address will be used by the
      active device to send client traffic.

   .. image:: images/bigip01-tunnel-ip.png
