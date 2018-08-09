Lab 1.2 - Setup the Agents
==========================

.. important:: The following commands need to be run on both agent nodes unless otherwise specified.

Prep Ubuntu
-----------

#. From the jumpbox open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - mesos-agent1
    - mesos-agent2

#. Elivate to "root"

    .. code-block:: console

        su - ( when prompted for password enter "default" without the quotes )

#. Before doing anything related to this exercise, we need to make sure that the system is up to date.

    .. code-block:: console

        apt-get update -y

#. Once this is done, we need to install the required packages to execute the mesos and marathon processes.

    .. code-block:: console

        apt-get install -y openjdk-8-jdk build-essential python-dev libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev unzip

Install Mesos
-------------

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

        #Update our local package cache to have access to mesosphere packages
        apt-get -y update

#. Finally we can install mesos on our agents

    .. code-block:: console

        apt-get install -y mesos

Setup Zookeeper
---------------

#. Need to point zookeeper to our 3 master instances. This is done in the file ``/etc/mesos/zk``

    ``2181`` is zookeeper's default port.


#. We need to point our agent to our 3 master instances. This is how the agent(s) will find the master(s). This is done via the file ``/etc/mesos/zk``

    ``2181`` is zookeeper's default port.

#. Do this on **all your agents**

    .. code-block:: console

        printf "zk://10.2.10.10:2181,10.2.10.20:2181,10.2.10.30:2181/mesos" | tee /etc/mesos/zk

Configure Mesos
---------------

#. We need to provide IP / hostname information to the mesos slave system (as we did for mesos master). On **each agent**, run the following commands:

    .. code-block:: console

        #On slave1:
        printf "10.2.10.40" | tee /etc/mesos-slave/ip
        cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

        #On slave2:
        printf "10.2.10.50" | tee /etc/mesos-slave/ip
        cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

Install and setup docker
------------------------

#. We have to install docker-engine on the agents to be able to run docker containers.  On **each agent**, do the following:

    .. code-block:: console

        apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

        printf "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list

        apt-get update


        #For Ubuntu Trusty, Wily, and Xenial, it’s recommended to install the linux-image-extra-* kernel packages. The linux-image-extra-* packages allows you use the aufs storage driver.

        apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

        apt-get install -y docker-engine


#. Once this is done, docker should be up and running already. To test that it was launched successfully, you may use the command **on one or all the agents**

    .. code-block:: console

        docker run --rm hello-world

    This will download a test image automatically and launch it. You should have things appearing on your terminal. Once it is done, the container will stop automatically and be deleted (done by the --rm parameter)

    .. image:: images/setup-slave-test-docker.png
        :align: center

#. We need to allow mesos and docker containers in mesos. Execute the following commands on **all agents**

    .. code-block:: console

        printf 'docker,mesos' | tee /etc/mesos-slave/containerizers

        #Increase the timeout to 10 min so that we have enough time to download any needed docker image
        printf '10mins' | tee /etc/mesos-slave/executor_registration_timeout

Start your services
-------------------

#. We need to make sure that zookeeper and mesos-master don't run on those agents. Do this on **all agents**:

    .. code-block:: console

         systemctl stop zookeeper
        printf manual | tee /etc/init/zookeeper.override

        systemctl stop mesos-master
        printf manual | tee /etc/init/mesos.master.override

#. We enable/start the agent process called mesos-slave

    .. code-block:: console

        systemctl enable mesos-slave
        systemctl start mesos-slave

#. Check on one of your master with mesos interface (port 5050) if your agents registered successfully. You should see both slave1 and slave2 in the agent page

    .. image:: images/setup-slave-check-agent-registration.png
        :align: center

Test your setup
---------------

#. Connect to Marathon through one of the master (:8080) and launch an application

    #. Click on *create application* and make the following settings:

        .. image:: images/setup-slave-test-create-application-button.png
            :align: center

        - ID: Test
        - CPU: 0.1
        - Memory: 32M
        - Command: echo Test; sleep 10

    
        .. image:: images/setup-slave-test-create-application-command-def.png
               :align: center

#. Once it runs, if you connect to the mesos framework, you should see more and
more completed tasks. Name of the task should be "Test" (our ID).

    .. image:: images/setup-slave-test-create-application-command-exec1.png
        :align: center

#. If you let it run for a while, you'll see more and more "Completed Tasks". You can see that the Host being selected to run those tasks is not always the same.

    .. image:: images/setup-slave-test-create-application-command-exec2.png
        :align: center

#. Go Back to Marathon, click on our application *test* and click on the setting
button and select *destroy* to remove it.

    .. image:: images/setup-slave-test-create-application-command-delete.png
        :align: center

Launch a container
------------------

#. To test our containers from marathon, click on create an application, switch to JSON mode and use the following to start an apache in a container.

    .. NOTE:: This may takes some time since we will have to retrieve the image first

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

#. It may take some time to switch from ``Deploying`` to ``Running``. Once it's
in a ``Running`` state, check the port used by the container and try to access
it (slave ``IP:port``)

    .. image:: images/setup-slave-test-create-container-run.png
        :align: center

#. Click on your application and here you'll see the port associated to your instance (here it is ``31755``) and on which host it run (here slave1 - ``10.1.20.51``)

    .. image:: images/setup-slave-test-create-container-check-port.png
        :align: center

#. Use your browser to connect to the application:

    .. image:: images/setup-slave-test-create-container-access.png
        :align: center
