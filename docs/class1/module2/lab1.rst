Lab 2.1 Install Docker
======================

.. attention:: The following commands need to be run on all three nodes unless otherwise specified.

#. From the jumphost open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - kube-master
    - kube-node1
    - kube-node2

    .. image:: images/MremoteNG-1.png
        :align: center

#. Once connected as ubuntu user (it's the user already setup in the MremoteNG settings), let's elivate to root:

    .. code-block:: bash

        su - ( when prompted for password enter "default" without the quotes )

    Your prompt should change to root@ at the start of the line :

    .. image:: images/rootuser.png
        :align: center

#. Then, to ensure the OS is up to date, run the following command

    .. code-block:: bash

        apt update && apt upgrade -y

        (This can take a few seconds to a minute depending on demand to download the latest updates for the OS)

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

        This next part can be a bit tricky - just cut/paste the 5 lines below exactly as they are and paste via buffer to the CLI (and press return when done)

        cat << EOF > /etc/docker/daemon.json
        {
        "exec-opts": ["native.cgroupdriver=cgroupfs"]
        }
        EOF

    It should look something like this image below:

    .. image:: images/goodEOL.png
        :align: center

#. Verify docker is up and running

    .. code-block:: bash

        docker run hello-world

    If everything is working properly you should see the following message

    .. image:: images/docker-hello-world-yes.png
        :align: center


.. note:: If you are not a linux/unix person - don't worry.  What happened above is how the linux installs and updates software. This is  ALL the ugly (under the cover steps to install apps, and in this case Docker on a Linux host. Please ask questions as to what really happened, but this is how with linux on ubuntu (and many other linux flavors) installs applications.  Linux uses a term called "package manager", and there are many: like YUM, APT, DPKG, RPM, PACMAN, etc. usually one is more favored by the flavor of linux (i.e. debian, ubuntu, redhat gentoo, OpenSuse, etc.), but at the end of the day they all pretty much do the same thing, download and keep applications updated.
