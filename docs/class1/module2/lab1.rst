Install Docker
==============

#. From the jumphost open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - kube-master
    - kube-node1
    - kube-node2

#. Connect as root

    .. code-block:: bash

        su - (passwd = default)

#. To ensure the OS is up to date

    .. code-block:: bash

        apt update && apt upgrade -y

#. Add the docker repo

    .. code-block:: bash

        curl \-fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add \-

        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#. Install the docker packages

    .. code-block:: bash
        
        apt update && apt install docker-ce -y

#. Configure docker to use the correct cgroupdriver

    .. important:: The cgroupdrive for docker and kubernetes have to match.  In this lab "cgroupfs" is the correct driver.

    .. code-block:: bash
        
        cat << EOF > /etc/docker/daemon.json
        {
        "exec-opts": ["native.cgroupdriver=cgroupfs"]
        }
        EOF

#. Verify docker is up and running

    .. code-block:: bash

        docker run hello-world

    If everything is working properly you should see the following message

    .. image:: images/docker-hello-world-yes.png
        :align: center
