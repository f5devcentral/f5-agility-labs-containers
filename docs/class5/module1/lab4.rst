Lab 1.4 - F5 Container Connector Usage
======================================

#. This class and following labs need these namespaces/projects created.

   .. code-block:: bash

      oc create namespace f5demo
      oc create namespace demoproj

#. For the following yaml files to work you need to be in the "f5demo" project.

   .. attention:: In the previous lab, upon OpenShift login, you were placed in
      the "default" project.

   .. code-block:: bash

      oc project f5demo

#. Create the f5demo deployment

   .. code-block:: bash

      oc create -f f5demo.yaml

   .. tip:: This file can be found at
      /home/centos/agilitydocs/openshift/advanced/apps/f5demo

   .. literalinclude:: ../../../openshift/advanced/apps/f5demo/f5demo.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2,6,15

#. Create the f5demo service

   .. code-block:: bash

      oc create -f f5service.yaml

   .. tip:: This file can be found at
      /home/centos/agilitydocs/openshift/advanced/apps/f5demo

   .. literalinclude:: ../../../openshift/advanced/apps/f5demo/f5service.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 2

#. Upload the Deployments to the OpenShift API server. Use the pool-only
   configmap to configuration project namespace: f5demo on the bigip

   .. code-block:: bash

      oc create -f pool-only.yaml

   .. tip:: This file can be found at
      /home/centos/agilitydocs/openshift/advanced/ocp/

   .. literalinclude:: ../../../openshift/advanced/ocp/pool-only.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 1,11,14,34

#. Check **bigip1** and **bigip2** to make sure the pool got created. Validate
   the pools are marked green.

   .. attention:: Make sure you are looking at the **"ocp" partition**

   .. image:: images/pool-members.png

#. Increase the replicas of the f5demo project pods. Replicas specified the
   required number of instances to run

   .. code-block:: bash

      oc scale --replicas=10 deployment/f5demo -n f5demo

   .. note:: It may take time to have your replicas up and running.
   
#. Don't hesitate to track this by using the following command. To check the
   number of **AVAILABLE** instances:

   .. code-block:: bash

      oc get deployment f5demo -n f5demo

   .. image:: images/10-containers.png

   Validate that bigip1 and bigip2 are updated with the additional pool members
   and their health monitor works. If the monitor is failing check the tunnel
   and selfIP.

Validation and Troubleshooting
------------------------------

Now that you have HA configured and uploaded the deployment, it is time to
generate traffic through our BIG-IPs. 

Add a virtual IP to the the configmap. You can edit the pool-only.yaml
configmap. There are multiple ways to edit the configmap which will be covered
in module 3. In this task remove the deployment, edit the yaml file and
re-apply the deployment

#. Remove the "pool-only" configmap.

   .. code-block:: bash

      oc delete -f pool-only.yaml
   
#. Edit the pool-only.yaml and add the bindAddr 

   vi pool-only.yaml

   .. code-block:: bash

      "frontend": {
         "virtualAddress": {
            "port": 80,
            "bindAddr": "10.3.10.220"

   .. tip:: Do not use TAB in the file, only spaces. Don't forget the "," at the
      end of the ""port": 80," line.

#. Create the modified pool-only deployment

   .. code-block:: bash

      oc create -f pool-only.yaml

#. From the jumpbox open a browser and try to connect to the virtual server at
   http://10.3.10.220. Does the connection work? If not, try the following
   troubleshooting options:

   a. Capture the http request to see if the connection is established with the
      BIG-IP.
   b. Follow the following network troubleshooting section.

Network Troubleshooting
-----------------------

How do I verify connectivity between the BIG-IP VTEP and the OSE Node?

#. Ping the Node's VTEP IP address. Use the ``-s`` flag to set the MTU of the
   packets to allow for VxLAN encapsulation.

   .. code-block:: bash

      ping -s 1600 -c 4 10.3.10.21 #(or .22 or .23)

#. Ping the Pod's IP address (use the output from looking at the pool members
   in the previous steps). Use the ``-s`` flag to set the MTU of the packets to
   allow for VxLAN encapsulation.

   .. code-block:: bash

      ping -s 1600 -c 4 10.130.0.8
      
#. Now change the MTU to 1400

   .. code-block:: bash

      ping -s 1400 -c 4 10.130.0.8
      
   .. note:: When pinging the VTEP IP directly the BIG-IP was L2 adjacent to
      the device and could send a large MTU.  
      
      In the second example, the packet is dropped across the VxLAN tunnel.  
      
      In the third example, the packet is able to traverse the VxLAN tunnel.

#. In a TMOS shell, do a ``tcpdump`` of the underlay network.
      
   .. tip.. Example showing two-way communication between the BIG-IP VTEP IP
      and the OSE node VTEP IPs.

      Example showing traffic on the overlay network; at minimum, you should
      see BIG-IP health monitors for the Pod IP addresses.

   .. code-block:: bash

      tcpdump -i ocp-tunnel -c 10 -nnn

#. In a TMOS shell, view the MAC address entries for the OSE tunnel. This will
   show the mac address and IP addresses of all of the OpenShift endpoints.

   .. code-block:: bash

      tmsh show /net fdb tunnel ocp-tunnel

   .. image:: images/net-fdb-entries.png

#. In a TMOS shell, view the ARP entries.

   This will show all of the ARP entries; you should see the VTEP entries on
   the :code:`ocpvlan` and the Pod IP addresses on :code:`ose-tunnel`.

   .. code-block:: bash

      tmsh show /net arp

   .. image:: images/net-arp-entries.png

#. Validate floating IP address for ocp-tunnel. Check to validate if the
   configuration is correct from the earlier config step. Make sure the self-IP
   is a floating IP. Traffic Group should be set to traffic-group-1 floating.
   If the traffic is local non-floating change to floating.

   .. image:: images/floating.png

#. Connect to the viutal IP address.

   .. image:: images/success.png

#. Test failover and make sure you can connect to the virtual. 

.. attention:: **Congratulations** for completing the HA clustering setup.
   Before moving to the next module cleanup the deployed resource:

   oc delete -f pool-only.yaml
