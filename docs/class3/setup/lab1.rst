Lab 1.1 - Setup the Masters
===========================

.. important:: The following commands need to be run on all three master nodes unless otherwise specified.

Prep Ubuntu
-----------

#. From the jumpbox open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - mesos-master1
    - mesos-master2
    - mesos-master3

#. Elivate to "root"

    .. code-block:: console

        su - ( when prompted for password enter "default" without the quotes )

#. Before doing anything related to this exercise, we need to make sure that the system is up to date.

    .. code-block:: console

        apt-get update -y

#. Once this is done, we need to install the required packages to execute the mesos and marathon processes.

    .. code-block:: console

        apt-get install -y openjdk-8-jdk build-essential python-dev python-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev zlib1g-dev

Install Mesos and Marathon
--------------------------

#. Now we need to let apt-get have access to the relevant repo (based on our distro name : ubuntu and our version: xenial)

    Do the following commands:

    .. code-block:: console

        #retrieve the key
        apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

        #this command identify the distro: ie ubuntu (a line starting with # is a comment, don't execute)
        DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

        #this command will identify the version for the distro. For example #xenial  ubuntu version)
        CODENAME=$(lsb_release -cs)

        #create a new repo to have access to mesosphere packages related to this distro/release
        printf "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list

        #update our local package cache to have access to mesosphere packages
        apt-get -y update

#. Finally we can install mesos and marathon on our masters

    .. code-block:: console

        apt-get install -y mesos marathon

Setup Zookeeper
---------------

#. Need to point zookeeper to our 3 master instances. This is done in the file ``/etc/mesos/zk``

    ``2181`` is zookeeper's default port.

#. On **all masters**, we need to setup a unique ID per zookeeper instance:

    - Master1: ``1``
    - Master2: ``2``
    - Master3: ``3``

    to do so we need to do the following:

    1. Update ``/etc/zookeeper/conf/myid`` to ``1``, ``2`` or ``3`` depending on the master
    2. Setup zookeeper config file on each master
    3. Change the quorum value to reflect our cluster size. It should be set over 50% of the number of master instances.  In this case it should be ``2``

    .. code-block:: console

           # On master1
           mkdir -p /etc/zookeeper/conf/
           printf 1 | tee /etc/zookeeper/conf/myid
           printf "tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181\ninitLimit=10\nsyncLimit=5\nserver.1=10.2.10.   10:2888:3888\nserver.2=10.2.10.20:2888:3888\nserver.3=10.2.10.30:2888:3888" | tee /etc/zookeeper/conf/zoo.cfg
           printf 2 | tee /etc/mesos-master/quorum


           # On master2
           mkdir -p /etc/zookeeper/conf/
           printf 2 | tee /etc/zookeeper/conf/myid
           printf "tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181\ninitLimit=10\nsyncLimit=5\nserver.1=10.2.10.   10:2888:3888\nserver.2=10.2.10.20:2888:3888\nserver.3=10.2.10.30:2888:3888" | tee /etc/zookeeper/conf/zoo.cfg
           printf 2 | tee /etc/mesos-master/quorum


           # On master3
           rm -rf /etc/zookeeper/
           mkdir -p /etc/zookeeper/conf/
           printf 3 | tee /etc/zookeeper/conf/myid
           printf "tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181\ninitLimit=10\nsyncLimit=5\nserver.1=10.2.10.   10:2888:3888\nserver.2=10.2.10.20:2888:3888\nserver.3=10.2.10.30:2888:3888" | tee /etc/zookeeper/conf/zoo.cfg
           echo 2 | tee /etc/mesos-master/quorum

Setup Mesos
-----------

#. Setup the following files with the relevant information:

    * /etc/mesos-master/ip
    * /etc/mesos-master/hostname (specify the IP address of your node)
    * /etc/mesos/zk (to have zookeeper handle HA for mesos)

    .. code-block:: console

        #On master1
        printf "10.2.10.10" | tee /etc/mesos-master/ip
        printf "10.2.10.10" | tee /etc/mesos-master/hostname
        printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | tee /etc/mesos/zk

        # On master2
        printf "10.2.10.20" | tee /etc/mesos-master/ip
        printf "10.2.10.20" | tee /etc/mesos-master/hostname
        printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | tee /etc/mesos/zk

        # On master3
        printf "10.2.10.30" | tee /etc/mesos-master/ip
        printf "10.2.10.20" | tee /etc/mesos-master/hostname
        printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | tee /etc/mesos/zk

Setup Marathon
--------------

#. Create the marathon directory structure

    .. code-block:: console

        mkdir -p /etc/marathon/conf

        cp /etc/mesos-master/hostname /etc/marathon/conf


#. We need to specify the zookeeper masters that marathon will connect to (for information and things like scheduling). We can copy the previous file we setup for mesos

    .. code-block:: console

        cp /etc/mesos/zk /etc/marathon/conf/master

#. We also need to have marathon store its own state in zookeper (since it runs on all three masters). Create a file /etc/marathon/conf/zk and put the following into it:

    .. code-block:: console

        printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/marathon" tee /etc/marathon/conf/zk

Start your services
-------------------

When you install mesos, the master and slave services are enabled (called mesos-master and mesos-slave). Here, we want our master to focus on this tasks so we need to disable the slave service.

#. Do this on *all the master* nodes:

    .. code-block:: console

        systemctl stop mesos-slave
        
        printf manual | tee /etc/init/mesos-slave.override

#. We need to restart zookeeper and start mesos-master and marathon process on *all master* nodes:

    .. code-block:: console

        systemctl restart zookeeper

        systemctl enable mesos-master

        systemctl start mesos-master

        systemctl enable marathon

        systemctl start marathon

#. We can validate that it works by connecting to mesos and marathon. Mesos runs on port 5050 (http) while marathon runs on port 8080.

    Mesos:

    .. image:: images/setup-master-check-UI-mesos-master.png
        :align: center

    Marathon:

    .. image:: images/setup-master-check-UI-marathon.png
        :align: center

#. If you want to check whether the service started as expected, you can use the following commands:

    .. code-block:: console

        systemctl status mesos-master

        systemctl status marathon

    you should see something like this:

    .. image:: images/setup-master-check-service-mesos-master.png
        :align: center

    .. image:: images/setup-master-check-service-marathon.png
        :align: center

#. Check the *about* section in marathon to have the information about the service.

    .. image:: images/setup-master-about-marathon.png
        :align: center

#. You can do the following to test the high availability of marathon:
    - Find on which mesos is running the framework marathon (here based on our screenshot above, it is available on master1)
    - Restart this master and you should see the framework was restarted automatically on another host

    .. image:: images/setup-master-test-HA-marathon.png
        :align: center
