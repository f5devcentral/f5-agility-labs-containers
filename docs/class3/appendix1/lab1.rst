Lab 2.1 - Prep Ubuntu
=====================

.. note::  This installation will utilize Ubuntu v16.04 (Xenial)

.. important:: The following commands need to be run on all three nodes unless
   otherwise specified.

#. From the jumpbox open **mRemoteNG** and start a session to each of the
   following servers. The sessions are pre-configured to connect with the
   default user “ubuntu”.

   - mesos-master1
   - mesos-agent2
   - mesos-agent3

   .. image:: images/MremoteNG.png

#. Elevate to "root"

   .. code-block:: bash

      su -
      
      #When prompted for password enter "default" without the quotes

#. For your convenience we've already added the host IP & names to /etc/hosts.
   Verify the file

   .. code-block:: bash

      cat /etc/hosts

   The file should look like this:

   .. image:: images/ubuntu-hosts-file.png

   If entries are not there add them to the bottom of the file be editing
   "/etc/hosts" with 'vim'

   .. code-block:: bash

      vim /etc/hosts

      #cut and paste the following lines to /etc/hosts

      10.2.10.21    mesos-master1
      10.2.10.22    mesos-agent1
      10.2.10.23    mesos-agent2

#. Ensure the OS is up to date, run the following command

   .. code-block:: bash

      apt update && apt upgrade -y

      #This can take a few seconds to several minute depending on demand to download the latest updates for the OS.

#. Add the docker repo

   .. code-block:: bash

      curl \-fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add \-

      add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#. Install the docker packages

   .. code-block:: bash

      apt update && apt install docker-ce -y

#. Verify docker is up and running

   .. code-block:: bash

      docker run --rm hello-world

   If everything is working properly you should see the following message

   .. image:: images/setup-test-docker.png

#. Install java for the mesos and marathon processes.

   .. code-block:: bash

      apt install -y openjdk-8-jdk
      
      export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
