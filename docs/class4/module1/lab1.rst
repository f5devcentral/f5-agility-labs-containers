Lab 1.1 - Prep CentOS
=====================

.. note::
   - This installation will utilize centOS v7.5.
   - SSH keys were configured to allow the jumphost to login without a passwd
     as well as between the master & nodes to facilitate the Ansible playbooks.

.. important:: The following commands need to be run on all three nodes
   unless otherwise specified.

#. From the jumpbox open **mRemoteNG** and start a session to each of the
   following servers. The sessions are pre-configured to connect with the
   default user “centos”.

   - ose-master1
   - ose-node1
   - ose-node2

   .. image:: images/MremoteNG.png
      :align: center

#. For your convenience we've already added the host IP & names to /etc/hosts.
   Verify the file

   .. code-block:: bash

      cat /etc/hosts

   The file should look like this:

   .. image:: images/centos-hosts-file.png
      :align: center

   If entries are not there add them to the bottom of the file be editing
   "/etc/hosts" with 'vim'

   .. code-block:: bash

      sudo vim /etc/hosts

      #cut and paste the following lines to /etc/hosts

      10.3.10.21    ose-master1
      10.3.10.22    ose-node1
      10.3.10.23    ose-node2

#. Ensure the OS is up to date

   .. code-block:: bash

      sudo yum update -y

      #This can take a few seconds to several minutes depending on demand to download the latest updates for the OS.

#. Install the docker packages

   .. code-block:: bash

      sudo yum install -y docker
      sudo systemctl start docker && sudo systemctl enable docker

#. Verify docker is up and running

   .. code-block:: bash

      sudo docker run --rm hello-world
   
   If everything is working properly you should see the following message

   .. image:: images/setup-test-docker.png
      :align: center
