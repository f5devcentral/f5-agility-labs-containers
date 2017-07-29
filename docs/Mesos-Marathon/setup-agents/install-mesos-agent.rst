Install Mesos
=============

All the steps mentioned below are to be done on **ALL THE AGENTS** 

* Slave1
* Slave2

Update the system
-----------------

Before doing anything related to this exercise, we need to make sure that the system is up to date. 

:: 

	sudo apt-get -y update

Once this is done, we need to install the required packages to execute the mesos and marathon processes. 

:: 

	sudo apt-get install -y openjdk-8-jdk 

	sudo apt-get install -y build-essential python-dev libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev unzip


Install Mesos
-------------

Now we need to let apt-get have access to the relevant repo (based on our distro name : ubuntu and our version: xenial)

Do the following commands: 

::

	#retrieve the key
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

	#this command identify the distro: ie ubuntu (a line starting with # is a comment, don't execute)
	DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') 

	#this command will identify the version for the distro. For example #xenial  ubuntu version)
	CODENAME=$(lsb_release -cs)

	#create a new repo to have access to mesosphere packages related to this distro/release
	printf "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

	#Update our local package cache to have access to mesosphere packages
	sudo apt-get -y update


Finally we can install mesos on our agents

::

	sudo apt-get install -y mesos
