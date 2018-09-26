Lab 2.4 - Setup Mesos-DNS
=========================

If you want to be able to do service discovery with Mesos/Marathon, you need to
install and setup mesos-dns.

To leverage marathon for scalability and HA, we will launch mesos-dns as an
application from Marathon.

We will setup mesos-dns on **mesos-agent1** (we will force mesos-dns to start
on mesos-agent1 in Marathon - 10.2.10.22).

We need to do the following tasks:

- Download the latest mesos-dns binaries
- Configure mesos-dns
- Launch the mesos-dns binary from Marathon

.. seealso:: To retrieve the binary, go to
   `Mesos DNS releases <https://github.com/mesosphere/mesos-dns/releases>`_
   and select the latest version. For this class we'll use the following binary:
   `Mesos DNS release v0.6.0 <https://github.com/mesosphere/mesos-dns/releases/download/v0.6.0/mesos-dns-v0.6.0-linux-amd64>`_

Download & Configure Mesos-DNS
------------------------------

#. SSH to **mesos-agent1** and do the following:

   .. code-block:: bash

      curl -O -L https://github.com/mesosphere/mesos-dns/releases/download/v0.6.0/mesos-dns-v0.6.0-linux-amd64

      mkdir /etc/mesos-dns

#. Create a file in /etc/mesos-dns/ called config.json and add the json block

   .. code-block:: bash

      vim /etc/mesos-dns/config.json

   .. code-block:: json

      {
         "zk": "zk://10.2.10.21:2181/mesos",
         "masters": ["10.2.10.21:5050"],
         "refreshSeconds": 60,
         "ttl": 60,
         "domain": "mesos",
         "port": 53,
         "resolvers": ["8.8.8.8"],
         "timeout": 5,
         "httpon": true,
         "dnson": true,
         "httpport": 8123,
         "externalon": true,
         "SOAMname": "ns1.mesos",
         "SOARname": "root.ns1.mesos",
         "SOARefresh": 60,
         "SOARetry": 600,
         "SOAExpire": 86400,
         "SOAMinttl": 60,
         "IPSources": ["mesos", "host"]
      }

#. Now setup the binary in a proper location:

   .. code-block:: bash

      mkdir /usr/local/mesos-dns

      mv ./mesos-dns-v0.6.0-linux-amd64 /usr/local/mesos-dns/

      chmod +x /usr/local/mesos-dns/mesos-dns-v0.6.0-linux-amd64

#. To test your setup do the following:

   .. code-block:: bash

      /usr/local/mesos-dns/mesos-dns-v0.6.0-linux-amd64 -config /etc/mesos-dns/config.json -v 10

#. This will start your mesos-dns app and you can test it.

   .. image:: images/setup-mesos-dns-test.png
      :align: center

#. You can now test your dns setup. Open a new command prompt from the windows
   jumpbox and start `nslookup`

   .. code-block:: console

      Microsoft Windows [Version 6.1.7601]
      Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

      C:\Users\user>nslookup
      Default Server:  b.resolvers.Level3.net
      Address:  4.2.2.2

      > server 10.2.10.22
      Default Server:  [10.2.10.22]
      Address:  10.2.10.22

      > www.google.com
      Server:  [10.2.10.22]
      Address:  10.2.10.22

      Non-authoritative answer:
      Name:    www.google.com
      Addresses:  2607:f8b0:4007:80e::2004
               172.217.14.100

      > master.mesos
      Server:  [10.2.10.22]
      Address:  10.2.10.22

      Name:    master.mesos
      Address:  10.2.10.21

      >

#. Stop your test mesos-dns app by typing "CTRL-c"

.. warning:: The next steps will fail if you don't stop your test mesos-dns app

Launch Mesos-DNS In Marathon
----------------------------

#. Launch the mesos-dns image in marathon. Connect to marathon, click on
   *Create Application* and enable *JSON Mode*. Copy the following JSON block
   over the default and click *Create Application*.

   .. code-block:: json

      {
         "cmd": "/usr/local/mesos-dns/mesos-dns-v0.6.0-linux-amd64 -config=/etc/mesos-dns/config.json -v=10",
         "cpus": 0.2,
         "mem": 256,
         "id": "mesos-dns",
         "instances": 1,
         "constraints": [["hostname", "CLUSTER", "10.2.10.22"]]
      }

#. Update /etc/resolv.conf on **all agents** by adding our mesos-dns nameserver
   to our /etc/resolv.conf file. SSH to mesos-agent1 & 2.

   .. code-block:: bash

      sed -i /nameserver/s/.*/"nameserver 10.2.10.22"/ /etc/resolv.conf

.. note:: If you have deployed your instances in a cloud like AWS, it is likely
   that you'll lose your DNS setup after a reboot. If you want to make your
   changes persist, you need to update /etc/dhcp/dhclient.conf to supersede the
   dhcp setup. More information here: 
   `Static DNS server in a EC2 instance <https://aws.amazon.com/premiumsupport/knowledge-center/ec2-static-dns-ubuntu-debian/>`_

Test Mesos-DNS
--------------

To test our Mesos DNS setup, we will start a new application and check if it
automatically gets a DNS name.

#. Start a new app in marathon:

   .. code-block:: json

      {
         "id": "app-test-dns",
         "cpus": 0.5,
         "mem": 32.0,
         "container": {
            "type": "DOCKER",
            "docker": {
               "image": "eboraas/apache-php",
               "network": "BRIDGE",
               "portMappings": [
                  { "containerPort": 80, "hostPort": 0 }
               ]
            }
         }
      }

#. Once it's running, go to one of your slaves and run ping
   app-test-dns.marathon.mesos. It should work and return the agent IP.

   .. image:: images/setup-mesos-dns-test-create-app.png
      :align: center

#. If you don't try to ping from mesos-agent1 or mesos-agent2, make sure your
   client can reach mesos-dns server first (10.2.10.22)

   .. image:: images/setup-mesos-dns-test-ping-app.png
      :align: center
