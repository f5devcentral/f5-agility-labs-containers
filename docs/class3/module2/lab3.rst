Lab 2.3 - Setup the Agents
==========================

Once the master is setup and running, we need to setup and join our *agents* to
the cluster.

.. important:: The following commands need to be run on both agent nodes unless
   otherwise specified.

Install Mesos
-------------

#. Point apt to the relevant repo

   Run the following commands:

   .. code-block:: bash

      #retrieve the key
      apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

      #create a new repo to have access to mesosphere packages related to this distro/release
      cat <<EOF >> /etc/apt/sources.list.d/mesosphere.list
      deb http://repos.mesosphere.com/ubuntu $(lsb_release -cs) main
      EOF

#. Finally we can install mesos on our agents

   .. code-block:: bash

      apt update && apt-get install mesos -y

Setup Mesos
---------------

#. Setup the following files with the relevant information:

   - /etc/mesos-slave/ip
   - /etc/mesos-slave/hostname (specify the IP address of your node)
   - /etc/mesos/zk (to have zookeeper handle HA for mesos)

   .. code-block:: bash

      #On agent1
      echo "10.2.10.22" > /etc/mesos-slave/ip
      echo "10.2.10.22" > /etc/mesos-slave/hostname
      echo "zk://10.2.10.21:2181/mesos" > /etc/mesos/zk

      # On agent2
      echo "10.2.10.23" > /etc/mesos-slave/ip
      echo "10.2.10.23" > /etc/mesos-slave/hostname
      echo "zk://10.2.10.21:2181/mesos" > /etc/mesos/zk

#. Make the following changes to allow docker containers in mesos.

   .. code-block:: bash

      #Add the ability to use docker containers
      echo 'docker,mesos' > /etc/mesos-slave/containerizers

      #Increase the timeout to 5 min so that we have enough time to download any needed docker image
      echo '5mins' > /etc/mesos-slave/executor_registration_timeout

      #Allow users other then "marathon" to create and run jobs on the agents
      echo 'false' > /etc/mesos-slave/switch_user

Start Services
--------------

#. First we need to make sure that zookeeper and mesos-master don't run on the
   agents.

   .. code-block:: bash

      systemctl stop zookeeper
      echo manual > /etc/init/zookeeper.override

      systemctl stop mesos-master
      echo manual > /etc/init/mesos.master.override

#. Start & enable the agent process called mesos-slave

   .. code-block:: bash

      systemctl start mesos-slave
      systemctl enable mesos-slave

#. Check on one of your master with mesos interface (port 5050) if your agents
   registered successfully. You should see both agent1 and agent2 on the agent
   page

   .. image:: images/setup-slave-check-agent-registration.png
      :align: center

Test your setup
---------------

#. Connect to Marathon through one of the master (:8080) and launch an
   application

   #. Click on *create application* and make the following settings:

      .. image:: images/setup-slave-test-create-application-button.png
         :align: center

      - ID: Test
      - CPU: 0.1
      - Memory: 32M
      - Command: echo Test; sleep 10
    
      .. image:: images/setup-slave-test-create-application-command-def.png
         :align: center

#. Once it runs, if you connect to the mesos framework, you should see more
   and more completed tasks. Name of the task should be "Test" (our ID).

   .. image:: images/setup-slave-test-create-application-command-exec1.png
      :align: center

#. If you let it run for a while, you'll see more and more "Completed Tasks".
   You can see that the Host being selected to run those tasks is not always
   the same.

   .. image:: images/setup-slave-test-create-application-command-exec2.png
      :align: center

#. Go Back to Marathon, click on our application *test* and click on the
   setting button and select *destroy* to remove it.

   .. image:: images/setup-slave-test-create-application-command-delete.png
      :align: center

Launch a container
------------------

#. To test our containers from marathon, click on create an application, switch
   to JSON mode and use the following to start an apache in a container.

   .. note:: This may takes some time since we will have to retrieve the
      image first

   .. code-block:: json

      {
         "id": "my-website",
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

   .. image:: images/setup-slave-test-create-container-def.png
      :align: center

#. It may take some time to switch from ``Deploying`` to ``Running``. Once
   it's in a ``Running`` state, check the port used by the container and try
   to access it (slave ``IP:port``)

   .. image:: images/setup-slave-test-create-container-run.png
      :align: center

#. Click on your application and here you'll see the port associated to your
   instance (here it is ``31755``) and on which host it run (here slave1 -
   ``10.1.20.51``)

   .. image:: images/setup-slave-test-create-container-check-port.png
      :align: center

#. Use your browser to connect to the application:

   .. image:: images/setup-slave-test-create-container-access.png
      :align: center
