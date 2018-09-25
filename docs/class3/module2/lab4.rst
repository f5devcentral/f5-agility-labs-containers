Lab 2.4 - Setup Mesos-DNS
=========================

If you want to be able to do service discovery with Mesos/Marathon, you will
need to install and setup mesos-dns.

To leverage marathon for scalability and HA, we will launch Mesos-DNS as an
application from Marathon.

We will setup mesos dns on **agent1** (we will force mesos-dns to start on
agent1 in Marathon - 10.2.10.23).

We need to do the following tasks:

- Retrieve the latest mesos-dns binaries
- Configure mesos-dns
- Launch the mesos-dns binary from Marathon

To retrieve the binary, go to
`Mesos DNS releases <https://github.com/mesosphere/mesos-dns/releases>`_
and select the latest version. For this class we'll use the following binary:
`Mesos DNS release v0.6.0 <https://github.com/mesosphere/mesos-dns/releases/download/v0.6.0/mesos-dns-v0.6.0-linux-amd64>`_

#. Connect on **agent1** and do the following:

   .. code-block:: console

      curl -O -L https://github.com/mesosphere/mesos-dns/releases/download/v0.6.0/mesos-dns-v0.6.0-linux-amd64

      mkdir /etc/mesos-dns

#. Create a file in /etc/mesos-dns/ called config.json

   .. code-block:: console

      vi /etc/mesos-dns/config.json

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

   .. code-block:: console

      mkdir /usr/local/mesos-dns

      mv ./mesos-dns-v0.6.0-linux-amd64 /usr/local/mesos-dns/

      chmod +x /usr/local/mesos-dns/mesos-dns-v0.6.0-linux-amd64

#. To test your setup do the following:

   .. code-block:: console

      /usr/local/mesos-dns/mesos-dns-v0.6.0-linux-amd64 -config /etc/mesos-dns/config.json -v 10

#. This will start your mesos-dns app and you can test it.

   .. image:: images/setup-mesos-dns-test.png
      :align: center

#. You can now test your dns setup:

   .. code-block:: console

      $ nslookup

      > server 10.2.10.22
      Default server: 10.2.10.22
      Address: 10.2.10.22#53

      > www.google.com
      Server:		10.2.10.22
      address:	10.2.10.22#53

      Non-authoritative answer:
      Name:	www.google.com
      Address: 172.217.3.163

      > master.mesos
      Server:		10.2.10.22
      Address:	10.2.10.22#53

      Name:	master.mesos
      Address: 10.2.10.21

#. Launch the mesos-dns image in marathon. Connect to marathon, click on
   *Create an application* and enable *json mode*

   .. code-block:: json

      {
         "cmd": "/usr/local/mesos-dns/mesos-dns-v0.6.0-linux-amd64 -config=/etc/mesos-dns/config.json -v=10",
         "cpus": 0.2,
         "mem": 256,
         "id": "mesos-dns",
         "instances": 1,
         "constraints": [["hostname", "CLUSTER", "10.2.10.22"]]
      }

#. Last thing is to update /etc/resolv.conf on **all slaves/agents**: we add
   our mesos dns into our /etc/resolv.conf file

   .. code-block:: console

      sed -i /nameserver/s/.*/"nameserver 10.2.10.22"/ /etc/resolv.conf

.. note:: If you have deployed your instances in a cloud like AWS, it is likely
   that you'll lose your DNS setup after a reboot. If you want to make your
   changes persist, you need to update /etc/dhcp/dhclient.conf to supersede the
   dhcp setup. More information here: 
   `Static DNS server in a EC2 instance <https://aws.amazon.com/premiumsupport/knowledge-center/ec2-static-dns-ubuntu-debian/>`_

Test Mesos DNS
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
   app-test-dns.marathon.mesos. It should work

   .. image:: images/setup-mesos-dns-test-create-app.png
      :align: center

#. If you don't try to ping from agent1 or agent2, make sure your client can
   reach mesos-dns server first (10.2.10.22)

   .. image:: images/setup-mesos-dns-test-ping-app.png
      :align: center
