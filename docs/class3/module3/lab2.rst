Setup Zookeeper
===============

Need to point zookeeper to our 3 master instances. This is done in the file
``/etc/mesos/zk``

``2181`` is zookeeper's default port.

On **all masters**, we need to setup a unique ID per zookeeper instance:

- Master1: ``1``
- Master2: ``2``
- Master3: ``3``

to do so we need to do the following:

1. Update ``/etc/zookeeper/conf/myid`` to ``1``, ``2`` or ``3`` depending
   on the master
2. Setup zookeeper config file on each master
3. Change the quorum value to reflect our cluster size. It should be set
   over 50% of the number of master instances.  In this case it should be ``2``

.. code-block:: console

   # On master1
   mkdir -p /etc/zookeeper/conf/
   printf 1 | sudo tee /etc/zookeeper/conf/myid
   printf "tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181\ninitLimit=10\nsyncLimit=5\nserver.1=10.2.10.   10:2888:3888\nserver.2=10.2.10.20:2888:3888\nserver.3=10.2.10.30:2888:3888" | sudo tee /etc/zookeeper/conf/zoo.cfg
   printf 2 | sudo tee /etc/mesos-master/quorum


   # On master2
   mkdir -p /etc/zookeeper/conf/
   printf 2 | sudo tee /etc/zookeeper/conf/myid
   printf "tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181\ninitLimit=10\nsyncLimit=5\nserver.1=10.2.10.   10:2888:3888\nserver.2=10.2.10.20:2888:3888\nserver.3=10.2.10.30:2888:3888" | sudo tee /etc/zookeeper/conf/zoo.cfg
   printf 2 | sudo tee /etc/mesos-master/quorum


   # On master3
   rm -rf /etc/zookeeper/
   mkdir -p /etc/zookeeper/conf/
   printf 3 | sudo tee /etc/zookeeper/conf/myid
   printf "tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181\ninitLimit=10\nsyncLimit=5\nserver.1=10.2.10.   10:2888:3888\nserver.2=10.2.10.20:2888:3888\nserver.3=10.2.10.30:2888:3888" | sudo tee /etc/zookeeper/conf/zoo.cfg
   echo 2 | sudo tee /etc/mesos-master/quorum
