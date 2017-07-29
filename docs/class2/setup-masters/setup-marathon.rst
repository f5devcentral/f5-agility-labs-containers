Setup Marathon
==============

We need to create the marathon directory structure on **each master**

::

	sudo mkdir -p /etc/marathon/conf

	sudo cp /etc/mesos-master/hostname /etc/marathon/conf


We need to specify the zookeeper masters that marathon will connect to (for information and things like scheduling). We can copy the previous file we setup for mesos

::

	sudo cp /etc/mesos/zk /etc/marathon/conf/master

We also need to have marathon store its own state in zookeper (since it runs on all three masters).

Create a file /etc/marathon/conf/zk and put the following into it:

::

	printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/marathon" | sudo tee /etc/marathon/conf/zk
