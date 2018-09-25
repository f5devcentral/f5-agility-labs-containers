Lab 2.2 - Setup the Master
==========================

.. important:: The following commands need to be run on the **master** only
   unless otherwise specified.

Install Mesos, Marathon and Zookeeper
-------------------------------------

#. Point apt to the relevant repo

   Run the following commands:

   .. code-block:: bash

      #retrieve the key
      apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

      #create a new repo to have access to mesosphere packages related to this distro/release
      cat <<EOF >> /etc/apt/sources.list.d/mesosphere.list
      deb http://repos.mesosphere.com/ubuntu $(lsb_release -cs) main
      EOF

#. Install mesos, marathon and zookeeper on the master.

   .. code-block:: bash

      apt update && apt install mesos marathon zookeeperd -y

Setup Zookeeper
---------------

#. Point zookeeper to the master instance. This is done in the file
   ``/etc/mesos/zk``

   .. note:: ``2181`` is zookeeper's default port.

#. Setup a unique ID per zookeeper instance:

   - Update ``/etc/zookeeper/conf/myid`` to ``1``, ``2`` or ``3`` depending
     on the master
   - Setup zookeeper config file on each master
   
   .. code-block:: bash

      # On master1
      echo 1 > /etc/zookeeper/conf/myid
      sed -i /^#server.1/s/#server.1=zookeeper1/server.1=10.2.10.21/ /etc/zookeeper/conf/zoo.cfg

Setup Mesos
-----------

#. Setup the following files with the relevant information:

   - /etc/mesos-master/ip
   - /etc/mesos-master/hostname (specify the IP address of your node)
   - Change the quorum value to reflect our cluster size. It should be set
      over 50% of the number of master instances. In this case it should be
      ``2``
   - /etc/mesos/zk (to have zookeeper handle HA for mesos)

   .. code-block:: bash

      #On master1
      echo "10.2.10.21" > /etc/mesos-master/ip
      echo "10.2.10.21" > /etc/mesos-master/hostname
      echo 1 > /etc/mesos-master/quorum
      echo "zk://10.2.10.21:2181/mesos" > /etc/mesos/zk

Setup Marathon
--------------

Modify the Marathon environment variables in /etc/default/marathon.

#. First we need to specify the zookeeper masters that marathon will connect to
   (for information and things like scheduling). We can copy the previous file
   we setup for mesos:

   .. code-block:: bash

      echo "MARATHON_MASTER=`cat /etc/mesos/zk`" > /etc/default/marathon

#. We also need to have marathon store its own state in zookeper (since it
   runs on all three masters):

   .. code-block:: bash

      echo "MARATHON_ZK=zk://10.2.10.21:2181/marathon" >> /etc/default/marathon

Start your services
-------------------

When you install mesos, the master and slave services are enabled (called
mesos-master and mesos-slave). Here, we want our master to focus on this tasks
so we need to disable the slave service.

#. Do this on *all the master* nodes:

   .. code-block:: bash

      systemctl stop mesos-slave
      echo manual > /etc/init/mesos-slave.override

#. We need to restart zookeeper and start mesos-master and marathon process on
   *all master* nodes:

   .. code-block:: bash

      systemctl restart zookeeper
      
      systemctl start mesos-master
      systemctl enable mesos-master

      systemctl start marathon

#. We can validate that it works by connecting to mesos and marathon. Mesos
   runs on port 5050 (http) while marathon runs on port 8080.

    Mesos:

   .. image:: images/setup-master-check-UI-mesos-master.png
      :align: center

   Marathon:

   .. image:: images/setup-master-check-UI-marathon.png
      :align: center

#. If you want to check whether the service started as expected, you can use
   the following commands:

   .. code-block:: bash

      systemctl status mesos-master

      systemctl status marathon

   you should see something like this:

   .. image:: images/setup-master-check-service-mesos-master.png
      :align: center

   .. image:: images/setup-master-check-service-marathon.png
      :align: center

#. Check the *about* section in marathon to have the information about the
   service.

   .. image:: images/setup-master-about-marathon.png
      :align: center

#. You can do the following to test the high availability of marathon:

   - Find on which mesos is running the framework marathon (here based on our
     screenshot above, it is available on master1)
   - Restart this master and you should see the framework was restarted
     automatically on another host

   .. image:: images/setup-master-test-HA-marathon.png
      :align: center
