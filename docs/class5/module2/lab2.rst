Section 2.1 Working with BIG-IP HA pairs or device groups
=========================================================

Each Container Connector is uniquely suited to its specific container orchestration environment and purpose, utilizing the architecture and language appropriate for the environment. Application Developers interact with the platform’s API; the CCs watch the API for certain events, then act accordingly.

The Container Connector is stateless. The inputs are:

* the container orchestration environment’s config
* the BIG-IP device config
* the CC config (provided via the appropriate means for the container orchestration environment).

Wherever a Container Connector runs, it always watches the API and attempts to bring the BIG-IP up-to-date with the latest applicable configurations.

Managing BIG-IP HA Clusters in OpenShift
----------------------------------------

You can use the F5 Container Connectors to manage a BIG-IP HA active-standby pair or device group. The deployment details vary depending on the platform. For most, the basic principle is the same: You should run one BIG-IP Controller instance for each BIG-IP device. You will deploy two BIG-IP Controller instances - one for each BIG-IP device. To help ensure Controller HA, you will deploy each Controller instance on a separate Node in the cluster.

.. image:: /_static/class5/ha-cluster.jpg

BIG-IP config sync
------------------

**Important**

Each Container Connector monitors the BIG-IP partition it manages for configuration changes. If it discovers changes, the Connector reapplies its own configuration to the BIG-IP. F5 does not recommend making configuration changes to objects in any partition managed by a BIG-IP Controller via any other means (for example, the configuration utility, TMOS, or by syncing configuration from another device or service group). Doing so may result in disruption of service or unexpected behavior. 

The Container Connector for OpenShift uses FDB entries and ARP records to identify the Cluster resources associated with BIG-IP Nodes. Because BIG-IP config sync doesn’t include FDB entries or ARP records, F5 does not recommend using automatic configuration sync when managing a BIG-IP HA pair or cluster with the BIG-IP Controller. You must diable config sync when using tunnels.

Complete the steps below to set up the solution shown in the diagram. Be sure to use the correct IP addresses and subnet masks for your OpenShift Cluster

. table:: Tasks

   ===== ==================================================================================
   Step  Task
   ===== ==================================================================================
   1.    :ref:`openshift initial bigip setup ha`

   2.    :ref:`add bigip devices openshift ha`

         * openshift create hostsubnets ha
         * openshift upload hostsubnets ha
         * openshift verify hostsubnets ha

   3.    :ref:`openshift vxlan setup ha`

         * creating OCP partition create
         * ocp-profile create 
         * openshift create vxlan profile ha
         * penshift create vxlan tunnel ha
         * openshift vxlan selfIP ha
         * openshift vxlan floatingip ha

   4.    :ref:`openshift deploy kctlr ha`

         * openshift rbac ha
         * openshift create deployment ha
         * openshift upload deployment ha

   ===== ==================================================================================

.. _openshift initial bigip setup ha:

**Step 1:** Openshift initial bigip setup ha

The purpose of this lab is not to cover BIG-IP High Availability (HA) in depth but focus on OpenShift configuration with BIG-IP. Some prior BIG-IP HA knowledge is required. We have created the BIG-IPs base configuration for bigip01 and bigip02 to save time. Below is the initial configuration used on each BIG-IP:

**bigip01.f5.local**

.. code-block:: console

     tmsh modify sys global-settings hostname bigip01.f5.local
     tmsh modify sys global-settings mgmt-dhcp disabled
     tmsh create sys management-ip 10.10.200.98/24
     tmsh create sys management-route 10.10.200.1
     tmsh create net vlan external interfaces add {1.1}
     tmsh create net vlan internal interfaces add {1.2}
     tmsh create net vlan ha interfaces add {1.3}
     tmsh create net self 10.10.199.98/24 vlan internal
     tmsh create net self 10.10.201.98/24 vlan external
     tmsh create net self 10.10.202.98/24 vlan ha allow-service default
     tmsh create net route default gw 10.10.201.1
     tmsh mv cm device bigip1 bigip01.f5.local
     tmsh modify cm device bigip01.f5.local configsync-ip 10.10.202.98
     tmsh modify cm device bigip01.f5.local unicast-address {{ip 10.10.202.98} {ip management-ip}}
     tmsh modify cm trust-domain ca-devices add {10.10.200.99} username admin password admin
     tmsh create cm device-group ocp-devicegroup devices add {bigip01.f5.local bigip02.f5.local} type sync-failover auto-sync disabled
     tmsh run cm config-sync to-group ocp-devicegroup
     tmsh save sys config

**bigip02.f5.local**

.. code-block:: console

     tmsh modify sys global-settings hostname bigip02.f5.local
     tmsh modify sys global-settings mgmt-dhcp disabled
     tmsh create sys management-ip 10.10.200.99/24
     tmsh create sys management-route 10.10.200.1
     tmsh create net vlan external interfaces add {1.1}
     tmsh create net vlan internal interfaces add {1.2}
     tmsh create net vlan ha interfaces add {1.3}
     tmsh create net self 10.10.199.99/24 vlan internal
     tmsh create net self 10.10.201.99/24 vlan external
     tmsh create net self 10.10.202.99/24 vlan ha allow-service default
     tmsh create net route default gw 10.10.201.1
     tmsh modify sys global-settings gui-setup disabled
     tmsh mv cm device bigip1 bigip02.f5.local
     tmsh modify cm device bigip02.f5.local configsync-ip 10.10.202.99
     tmsh modify cm device bigip02.f5.local unicast-address {{ip 10.10.202.99} {ip management-ip}}
     tmsh save sys config

Before adding the BIG-IP devices to OpenShift make sure your High Availability (HA) device trust group, license, selfIP, vlans are configured correctly

Validate that SDN services license is active

.. image:: /_static/class5/license.png

Validate the vlan configuration

.. image:: /_static/class5/vlans.png

Validate bigip01 self IP configuration

.. image:: /_static/class5/self-ip-bigip01.png

Validate bigip02 self IP configuration

.. image:: /_static/class5/self-ip-bigip02.png

Validate the device group HA settings and make sure bigip01 and bigip02 are in sync. If out of sync, sync the bigip

.. image:: /_static/class5/device-group-sync.png

All synced. Note the sync-failover configuration is set to manual sync

.. image:: /_static/class5/synced.png

The diagram below displays the BIG-IP deployment with the OpenShift cluster in High Availability (HA) active-standby pair or device group. Note this solution applies to BIG-IP devices v13.x and later only. To accomplish High Availability (HA) active-standby pair or device group with OpenShift the BIG-IP needs to create a floating vxlan tunnel address with is currently only available in BIG-IP 13.x and later.

.. _openshift upload hostsubnets ha:

Upload the HostSubnet files to the OpenShift API server
```````````````````````````````````````````````````````

**Step 2:** Create a new OpenShift HostSubnet

HostSubnets must use valid YAML. You can upload the files individually using separate oc create commands. Create one HostSubnet for each BIG-IP device. These will handle health monitor traffic. Also create one HostSubnet to pass client traffic. You will create the floating IP address for the active device in this subnet as shown in the diagram above. We have create the YAML files to save time. The files are located at **/root/agility2018/ocp**

Define HostSubnets
------------------

hs-bigip01.yaml

.. code-block:: console

     {
        "apiVersion": "v1",
        "host": "openshift-f5-bigip01",
        "hostIP": "10.10.199.98",
        "kind": "HostSubnet",
        "metadata": {
            "name": "openshift-f5-bigip01"
        },
        "subnet": "10.131.0.0/23"
    }

hs-bigip02.yaml

.. code-block:: console

     {
        "apiVersion": "v1",
        "host": "openshift-f5-bigip02",
        "hostIP": "10.10.199.99",
        "kind": "HostSubnet",
        "metadata": {
            "name": "openshift-f5-bigip02"
        },
        "subnet": "10.131.2.0/23"
    }

hs-bigip-float.yaml

.. code-block:: console

     {
        "apiVersion": "v1",
        "host": "openshift-f5-bigip-float",
        "hostIP": "10.10.199.200",
        "kind": "HostSubnet",
        "metadata": {
            "name": "openshift-f5-bigip-float"
        },
        "subnet": "10.131.4.0/23"
    }

Create the HostSubnet files to the OpenShift API server

.. code-block:: console

     oc create -f hs-bigip01.yaml
     oc create -f hs-bigip02.yaml
     oc create -f hs-bigip-float.yaml

Verify creation of the HostSubnets:

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get hostsubnet
     NAME                       HOST                       HOST IP         SUBNET          EGRESS IPS
     openshift-f5-bigip-float   openshift-f5-bigip-float   10.10.199.200   10.131.4.0/23   []
     openshift-f5-bigip01       openshift-f5-bigip01       10.10.199.98    10.131.0.0/23   []
     openshift-f5-bigip02       openshift-f5-bigip02       10.10.199.99    10.131.2.0/23   []
     ose-mstr01.f5.local        ose-mstr01.f5.local        10.10.199.100   10.130.0.0/23   []
     ose-node01                 ose-node01                 10.10.199.101   10.128.0.0/23   []
     ose-node02                 ose-node02                 10.10.199.102   10.129.0.0/23   []
    [root@ose-mstr01 ocp]#

.. _openshift vxlan setup ha:

Set up the VXLAN on the BIG-IP devices
--------------------------------------

**Step 3.1:** Create a new partition on your BIG-IP system

The BIG-IP OpenShift Controller cannot manage objects in the /Common partition. Its recommended to create all HA using the /Common partition

* ssh root@10.10.200.98 tmsh create auth partition ocp
* ssh root@10.10.200.99 tmsh create auth partition ocp

**Step 3.2:** Creating ocp-profile

* ssh root@10.10.200.98 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint
* ssh root@10.10.200.99 tmsh create net tunnels vxlan ocp-profile flooding-type multipoint

**Step 3.3:** Creating floating IP for underlay network

* ssh root@10.10.200.98 tmsh create net self 10.10.199.200/24 vlan internal traffic-group traffic-group-1
* ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

**Step 3.4:** Creating vxlan tunnel ocp-tunnel

* ssh root@10.10.200.98 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.98 traffic-group traffic-group-1
* ssh root@10.10.200.99 tmsh create net tunnels tunnel ocp-tunnel key 0 profile ocp-profile local-address 10.10.199.200 secondary-address  10.10.199.99 traffic-group traffic-group-1

**Step 3.5:** Creating overlay self-ip

* ssh root@10.10.200.98 tmsh create net self 10.131.0.98/14 vlan ocp-tunnel
* ssh root@10.10.200.99 tmsh create net self 10.131.2.99/14 vlan ocp-tunnel

**Step 3.6:** Creating floating IP for overlay network

Note: Should the traffic group be configured as a traffic-group-local-only (non-floating) or traffic-group-1 (floating)?

* ssh root@10.10.200.98 tmsh create net self 10.131.4.200/14 vlan ocp-tunnel
* ssh root@10.10.200.98 tmsh run cm config-sync to-group ocp-devicegroup

**Step 3.7:** Saving configuration

* ssh root@10.10.200.98 tmsh save sys config
* ssh root@10.10.200.99 tmsh save sys config

Before adding the BIG-IP controller to OpenShift validate the partition and tunnel configuration

Validate that the OCP bigip partition was created

.. image:: /_static/class5/partition.png

Validate bigip01 self IP configuration

Note: On the active device, there is floating IP address in the subnet assigned by the OpenShift SDN.

.. image:: /_static/class5/self-ip-bigip01-ha.png

Validate bigip02 self IP configuration

.. image:: /_static/class5/self-ip-bigip02-ha.png

Check the ocp-tunnel configuration. Note the local-address 10.10.199.200 and secondary-address are  10.10.199.98 for bigip01 and 10.10.199.99 for bigip02

.. image:: /_static/class5/bigip01-tunnel-ip.png

.. _openshift deploy kctlr ha:

Deploy the BIG-IP Controller
----------------------------

Take the steps below to deploy a contoller for each BIG-IP device in the cluster.

Set up RBAC
-----------

You can create RBAC resources in the project in which you will run your BIG-IP Controller. Each Controller that manages a device in a cluster or active-standby pair can use the same Service Account, Cluster Role, and Cluster Role Binding.

**Step 4.1:** Create a Service Account for the BIG-IP Controller

.. code-block:: console

     [root@ose-mstr01 ocp]# **oc create serviceaccount bigip-ctlr [-n kube-system]**
     serviceaccount "bigip-ctlr" created

**Step 4.2:** Create a Cluster Role and Cluster Role Binding with the required permissions.

The following file has already being created **f5-kctlr-openshift-clusterrole.yaml** which is located in /root/agility2018/ocp

.. code-block:: console

     # For use in OpenShift clusters
     apiVersion: v1
     kind: ClusterRole
     metadata:
     annotations:
         authorization.openshift.io/system-only: "true"
     name: system:bigip-ctlr
     rules:
     - apiGroups: ["", "extensions"]
     resources: ["nodes", "services", "endpoints", "namespaces", "ingresses", "routes" ]
     verbs: ["get", "list", "watch"]
     - apiGroups: ["", "extensions"]
     resources: ["configmaps", "events", "ingresses/status"]
     verbs: ["get", "list", "watch", "update", "create", "patch" ]
     - apiGroups: ["", "extensions"]
     resources: ["secrets"]
     resourceNames: ["<secret-containing-bigip-login>"]
     verbs: ["get", "list", "watch"]

     ---

     apiVersion: v1
     kind: ClusterRoleBinding
     metadata:
         name: bigip-ctlr-role
     userNames:
     - system:serviceaccount:kube-system:bigip-ctlr
     subjects:
     - kind: ServiceAccount
     name: bigip-ctlr
     roleRef:
     name: system:bigip-ctlr

Use the oc create -f f5-kctlr-openshift-clusterrole.yaml 

.. code-block:: console

     [root@ose-mstr01 ocp]# **oc create -f f5-kctlr-openshift-clusterrole.yaml**
     clusterrole "system:bigip-ctlr" created
     clusterrolebinding "bigip-ctlr-role" created

Create Deployments
------------------

**Step 4.3:** Deploy the BIG-IP Controller

Create an OpenShift Deployment for each Controller (one per BIG-IP device). You need to deploy a controller for both f5-bigip-node01 and f5-bigip-node02

* Provide a unique metadata.name for each Controller.
* Provide a unique --bigip-url in each Deployment (each Controller manages a separate BIG-IP device).
* Use the same --bigip-partition in all Deployments.

bigip01-cc.yaml

.. code-block:: console

     apiVersion: extensions/v1beta1
     kind: Deployment
     metadata:
       name: bigip01-ctlr
       namespace: kube-system
     spec:
       replicas: 1
       template:
         metadata:
           name: k8s-bigip-ctlr1
           labels:
             app: k8s-bigip-ctlr1
         spec:
           serviceAccountName: bigip-ctlr
           containers:
             -  name: k8s-bigip-ctlr
                image: "f5networks/k8s-bigip-ctlr:latest"
                env:
                  - name: BIGIP_USERNAME
                    valueFrom:
                      secretKeyRef:
                        name: bigip-login
                        key: username
                 - name: BIGIP_PASSWORD
                   valueFrom:
                      secretKeyRef:
                      name: bigip-login
                      key: password
          command: ["/app/bin/k8s-bigip-ctlr"]
          args: [
            "--bigip-username=$(BIGIP_USERNAME)",
            "--bigip-password=$(BIGIP_PASSWORD)",
            "--bigip-url=10.10.200.98",
            "--bigip-partition=ocp",
            "--pool-member-type=cluster",
            "--manage-routes=true",
            "--node-poll-interval=5",
            "--verify-interval=5",
	        "--namespace=demoproj",
	        "--namespace=yelb",
	        "--namespace=guestbook",
	        "--namespace=f5demo",
            "--route-vserver-addr=10.10.201.120",
            "--route-http-vserver=ocp-vserver",
            "--route-https-vserver=ocp-https-vserver",
            "--openshift-sdn-name=/Common/ocp-tunnel"
          ]
      imagePullSecrets:
        - name: f5-docker-images

bigip02-cc.yaml

.. code-block:: console

     apiVersion: extensions/v1beta1
     kind: Deployment
     metadata:
       name: bigip02-ctlr
       namespace: kube-system
     spec:
       replicas: 1
       template:
         metadata:
           name: k8s-bigip-ctlr1
           labels:
             app: k8s-bigip-ctlr1
         spec:
           serviceAccountName: bigip-ctlr
           containers:
             -  name: k8s-bigip-ctlr
                image: "f5networks/k8s-bigip-ctlr:latest"
                env:
                  - name: BIGIP_USERNAME
                    valueFrom:
                      secretKeyRef:
                        name: bigip-login
                        key: username
                 - name: BIGIP_PASSWORD
                   valueFrom:
                      secretKeyRef:
                      name: bigip-login
                      key: password
          command: ["/app/bin/k8s-bigip-ctlr"]
          args: [
            "--bigip-username=$(BIGIP_USERNAME)",
            "--bigip-password=$(BIGIP_PASSWORD)",
            "--bigip-url=10.10.200.99",
            "--bigip-partition=ocp",
            "--pool-member-type=cluster",
            "--manage-routes=true",
            "--node-poll-interval=5",
            "--verify-interval=5",
	        "--namespace=demoproj",
	        "--namespace=yelb",
	        "--namespace=guestbook",
	        "--namespace=f5demo",
            "--route-vserver-addr=10.10.201.120",
            "--route-http-vserver=ocp-vserver",
            "--route-https-vserver=ocp-https-vserver",
            "--openshift-sdn-name=/Common/ocp-tunnel"
          ]
      imagePullSecrets:
        - name: f5-docker-images

Use the oc create -f bigip01-cc.yaml and bigip02-cc.yaml to add the bigip controller to OpenShift

**Step 4.3:** Upload the Deployments to the OpenShift API server

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f  bigip01-cc.yaml
     deployment "bigip01-ctlr" created
     [root@ose-mstr01 ocp]# oc create -f  bigip02-cc.yaml
     deployment "bigip02-ctlr" created

**Step 4.4:** Verify Pod creation

Verify the deployment and pods that are created

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get deployment
     NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
     bigip01-ctlr   1         1         1            1           42s
     bigip02-ctlr   1         1         1            1           36s

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get deployment bigip01-ctlr
     NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
     bigip01-ctlr   1         1         1            1           1m

.. code-block:: console

     [root@ose-mstr01 ocp]# oc get pods
     NAME                           READY     STATUS    RESTARTS   AGE
     bigip01-ctlr-242733768-dbwdm   1/1       Running   0          1m
     bigip02-ctlr-66171581-q87kb    1/1       Running   0          1m
     [root@ose-mstr01 ocp]#

You can also use the web conole in OpenShift to view the bigip controller. Go the kube-system project

.. image:: /_static/class5/kube-system.png

Upload the Deployments
----------------------

**Step 4.5:** Upload the Deployments to the OpenShift API server. Use the pool-only configmap to configuration project namespace: f5demo on the bigip

pool-only.yaml

.. code-block:: console

     kind: ConfigMap
     apiVersion: v1
     metadata:
     # name of the resource to create on the BIG-IP
     name: k8s.poolonly
     # the namespace to create the object in
     # As of v1.1, the k8s-bigip-ctlr watches all namespaces by default
     # If the k8s-bigip-ctlr is watching a specific namespace(s),
     # this setting must match the namespace of the Service you want to proxy
     # -AND- the namespace(s) the k8s-bigip-ctlr watches
     namespace: f5demo
     labels:
         # the type of resource you want to create on the BIG-IP
         f5type: virtual-server
     data:
     schema: "f5schemadb://bigip-virtual-server_v0.1.3.json"
     data: |
         {
         "virtualServer": {
             "backend": {
             "servicePort": 8080,
             "serviceName": "f5demo",
             "healthMonitors": [{
                 "interval": 3,
                 "protocol": "http",
                 "send": "GET /\r\n",
                 "timeout": 10
             }]
             },
             "frontend": {
             "virtualAddress": {
                 "port": 80
             },
             "partition": "ocp",
             "balance": "round-robin",
             "mode": "http"
             }
         }
         }

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f pool-only.yaml
     configmap "k8s.poolonly" created

**Step 4.5:** Check bigip01 and bigip02 to make sure the pool got create. Validate that both bigip01 and bigip02 can reach the pool members. Pool members should show green

.. image:: /_static/class5/pool-members.png

**Step 4.6:** Increase the replication of the f5demo project pods

.. image:: /_static/class5/10-containers.png

Validate that bigip01 and bigip02 so the updated pool member count and they keepalives work. If the keepalives are failing check the tunnel and selfIP

Validation and troubleshooting
------------------------------

Now that you have HA configured and uploaded the deployment its time to generate traffic through bigip. 

**Step 5.1:** Create a virtual IP address for the deployment

Add a virtual IP to the the configmap. You can edit the pool-only.yaml configmap. There are multuple ways to edit the configmap which will be covered in module 3. In this task remove the deployment, edit the yaml file and re-apply the deployment

.. code-block:: console

     [root@ose-mstr01 ocp]# oc delete -f pool-only.yaml
     configmap "k8s.poolonly" deleted
     [root@ose-mstr01 ocp]#
  
.. code-block:: console

Edit the pool-only.yaml and add the bindAddr 

vi pool-only.yaml

.. code-block:: console

     "frontend": {
          "virtualAddress": {
            "port": 80,
            "bindAddr": "10.10.201.220"

Create the modified pool-only deployment

.. code-block:: console

     [root@ose-mstr01 ocp]# oc create -f pool-only.yaml
     configmap "k8s.poolonly" created

Connect to the virtual server at http://10.10.201.220. Does the connection work? If not, try the following troubleshooting options

1) Capture the http request to see if the connection is established with the bigip
2) Follow the following networking troubleshooting Tasks

Network troubleshooting
-----------------------

How do I verify connectivity between the BIG-IP VTEP and the OSE Node?
``````````````````````````````````````````````````````````````````````

#. Ping the Node's VTEP IP address.

   Use the ``-s`` flag to set the MTU of the packets to allow for VxLAN encapsulation.

   .. code-block:: console

      ping -s 1600 <OSE_Node_IP>

#. In a TMOS shell, output the REST requests from the BIG-IP logs.

   - Do a ``tcpdump`` of the underlay network.

   Example showing two-way communication between the BIG-IP VTEP IP and the OSE node VTEP IPs. Example showing traffic on the overlay network; at minimum, you should see BIG-IP health monitors for the Pod IP addresses.

   .. code-block:: console

      root@(bigip01)(cfg-sync In Sync)(Standby)(/Common)(tmos)# tcpdump -i ocp-tunnel
      tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
      listening on ocp-tunnel, link-type EN10MB (Ethernet), capture size 65535 bytes
      10:29:48.126529 IP 10.131.0.98.47006 > 10.128.0.96.webcache: Flags [S], seq 3679729621, win 29200, options [mss 1460,sackOK,TS val 3704230749 ecr 0,nop,wscale 7], length 0 out slot1/tmm0 lis=
      10:29:48.128430 IP 10.128.0.96.webcache > 10.131.0.98.47006: Flags [S.], seq 2278441553, ack 3679729622, win 27960, options [mss 1410,sackOK,TS val 2782018 ecr 3704230749,nop,wscale 7], length 0 in slot1/tmm0 lis=
      10:29:48.131715 IP 10.128.0.96.webcache > 10.131.0.98.47006: Flags [.], ack 10, win 219, options [nop,nop,TS val 2782022 ecr 3704230753], length 0 in slot1/tmm1 lis=
      10:29:48.130533 IP 10.131.0.98.47006 > 10.128.0.96.webcache: Flags [.], ack 1, win 229, options [nop,nop,TS val 3704230753 ecr 2782018], length 0 out slot1/tmm0 lis=
      10:29:48.130539 IP 10.131.0.98.47006 > 10.128.0.96.webcache: Flags [P.], seq 1:10, ack 1, win 229, options [nop,nop,TS val 3704230753 ecr 2782018], length 9: HTTP: GET / out slot1/tmm0 lis=
      10:29:48.141479 IP 10.131.0.98.47006 > 10.128.0.96.webcache: Flags [.], ack 1349, win 251, options [nop,nop,TS val 3704230764 ecr 2782031], length 0 out slot1/tmm0 lis=
      10:29:48.141036 IP 10.128.0.96.webcache > 10.131.0.98.47006: Flags [P.], seq 1:1349, ack 10, win 219, options [nop,nop,TS val 2782031 ecr 3704230753], length 1348: HTTP: HTTP/1.1 200 OK in slot1/tmm1 lis=
      10:29:48.141041 IP 10.128.0.96.webcache > 10.131.0.98.47006: Flags [F.], seq 1349, ack 10, win 219, options [nop,nop,TS val 2782031 ecr 3704230753], length 0 in slot1/tmm1 lis=

#. In a TMOS shell, view the MAC address entries for the OSE tunnel. This will show the mac address and IP addresses of all of the OpenShift endpoints.

   .. code-block:: console

      root@(bigip02)(cfg-sync In Sync)(Active)(/Common)(tmos)# show /net fdb tunnel ocp-tunnel

      ----------------------------------------------------------------
      Net::FDB
      Tunnel      Mac Address        Member                    Dynamic
      ----------------------------------------------------------------
      ocp-tunnel  0a:0a:0a:0a:c7:64  endpoint:10.10.199.100%0  no
      ocp-tunnel  0a:0a:0a:0a:c7:65  endpoint:10.10.199.101%0  no
      ocp-tunnel  0a:0a:0a:0a:c7:66  endpoint:10.10.199.102%0  no
      ocp-tunnel  0a:58:0a:80:00:60  endpoint:10.10.199.101    yes

#. In a TMOS shell, view the ARP entries.

   This will show all of the ARP entries; you should see the VTEP entries on the :code:`ocpvlan` and the Pod IP addresses on :code:`ose-tunnel`.

   .. code-block:: console

      root@(bigip02)(cfg-sync In Sync)(Active)(/Common)(tmos)# show /net arp

      --------------------------------------------------------------------------------------------
      Net::Arp
      Name           Address        HWaddress          Vlan                Expire-in-sec  Status
      --------------------------------------------------------------------------------------------
      10.10.199.100  10.10.199.100  2c:c2:60:49:b2:9d  /Common/internal    41             resolved
      10.10.199.101  10.10.199.101  2c:c2:60:58:62:64  /Common/internal    70             resolved
      10.10.199.102  10.10.199.102  2c:c2:60:51:65:a0  /Common/internal    41             resolved
      0.10.202.98   10.10.202.98   2c:c2:60:1f:74:62  /Common/ha          64             resolved
      10.128.0.96    10.128.0.96    0a:58:0a:80:00:60  /Common/ocp-tunnel  7              resolved

      root@(bigip02)(cfg-sync In Sync)(Active)(/Common)(tmos)#

**Step 5.1:** Validate floating traffic for ocp-tunnel self-ip

Check if the configuration is correct from step 3.6. Make sure the floating IP is set to traffic-group-1 floating. A floating traffic group is request for the response traffic from the pool-member. If the traffic is local change to floating

.. image:: /_static/class5/non-floating.png

change to floating

.. image:: /_static/class5/floating.png

Connect to the viutal IP address

.. image:: /_static/class5/success.png

Test failover and make sure you can connect to the virtual. 

Congraulation for completeing the HA clusterting setup. Please move next module. 












