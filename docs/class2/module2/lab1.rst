Lab 2.1 - Prep Ubuntu
=====================

Overview
--------

This installation will utilize Ubuntu v16.04 (Xenial) and **kubeadm**

.. note::  You can find a more thorough installation guide here: `Ubuntu getting started guide 16.04 <http://kubernetes.io/docs/getting-started-guides/kubeadm/>`_

.. important:: The following commands need to be run on all three nodes unless otherwise specified.

Setup
-----

#. From the jumphost open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - kube-master
    - kube-node1
    - kube-node2

#. Connect as root

    .. code-block:: bash

        su - (passwd = default)

#. Edit /etc/hosts and add the following static hosts entries

    .. code-block:: bash

        vim /etc/hosts

        ...and add the following lines to the bottom of the file

        10.1.10.21    kube-master
        10.1.10.22    kube-node1
        10.1.10.23    kube-node2

    The file should look like this:

    .. image:: images/ubuntu-hosts-file.png
        :align: center

#. Disable linux swap file

    .. important:: Running a swap file is incompatible with Kubernetes

    .. code-block:: bash

        swapoff -a
        
        vim /etc/fstab 

        and rem out the highlighted line below by adding "#" to the beginning of the line, write and save the file, ":wq"

    .. image:: images/disable-swap.png
        :align: center

#. To ensure all the systems are up to date, run this command

    .. code-block:: bash

        apt update && apt upgrade -y

#. Install docker-ce

    .. note:: This was done earlier in `Class 1 / Module2: Install Docker <../../class1/module2/module2.html>`_.  If skipped go back and install Docker.

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

#. Install Kubernetes

    #. Add the kubernetes repo

        .. code-block:: bash

            curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
            
            cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
            deb http://apt.kubernetes.io/ kubernetes-xenial main
            EOF

    #. Install the kubernetes packages

        .. code-block:: bash
            
            apt update && apt install kubelet kubeadm kubectl -y

Limitations
-----------

For a full list of the limitations go here: `kubeadm limitations <http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations>`_

.. important:: The cluster created has a single master, with a single etcd database running on it. This means that if the master fails, your cluster loses its configuration data and will need to be recreated from scratch.
