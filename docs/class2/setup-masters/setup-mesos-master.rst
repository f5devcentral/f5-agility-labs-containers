Setup Mesos
===========

On **each master** we need to setup the following files with the relevant information:

* /etc/mesos-master/ip
* /etc/mesos-master/hostname (specify the IP address of your node)
* /etc/mesos/zk (to have zookeeper handle HA for mesos)

::

	#On master1
	printf "10.2.10.10" | sudo tee /etc/mesos-master/ip
	printf "10.2.10.10" | sudo tee /etc/mesos-master/hostname
	printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | sudo tee /etc/mesos/zk

	# On master2
	printf "10.2.10.20" | sudo tee /etc/mesos-master/ip
	printf "10.2.10.20" | sudo tee /etc/mesos-master/hostname
	printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | sudo tee /etc/mesos/zk

	# On master3
	printf "10.2.10.30" | sudo tee /etc/mesos-master/ip
	printf "10.2.10.20" | sudo tee /etc/mesos-master/hostname
	printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | sudo tee /etc/mesos/zk
