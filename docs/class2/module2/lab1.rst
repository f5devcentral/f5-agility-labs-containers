Lab 2.1 - Prep Ubuntu
=====================

Overview
--------

This installation will utilize Ubuntu v16.04 (Xenial) and **kubeadm**

.. note::  You can find a more thorough installation guide here: `Ubuntu getting started guide 16.04 <http://kubernetes.io/docs/getting-started-guides/kubeadm/>`_

Setup
-----

.. important:: The following commands need to be run on all three nodes unless otherwise specified.

#. From the jumpbox open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - kube-master
    - kube-node1
    - kube-node2

    .. tip:: These sessions should be running from the previous Docker lab.

    .. image:: images/MremoteNG-1.png
        :align: center

#. If not already done from the previous Docker lab elivate to "root"

    .. code-block:: console

        su - ( when prompted for password enter "default" without the quotes )

    Your prompt should change to root@ at the start of the line :

    .. image:: images/rootuser.png
        :align: center

#. For your conveniance we've already added the host IP & names to /etc/hosts.  Verify the file

    .. code-block:: console

        cat /etc/hosts

    The file should look like this:

    .. image:: images/ubuntu-hosts-file.png
        :align: center

    If not there add the following lines to the bottom of the file with "vim /etc/hosts"

    .. code-block:: console

        10.1.10.21    kube-master
        10.1.10.22    kube-node1
        10.1.10.23    kube-node2

#. The linux swap file needs to be disabled, this is not the case by default.  Again for your convenience we disabled swap.  Verify the setting

    .. important:: Running a swap file is incompatible with Kubernetes.  Lets use the linux top command, which allows users to monitor processes and system resource usage


    .. code-block:: console

        top

    .. image:: images/top.png

    If you see a number other than "0" you need to run the following commands (else press q to quit top)

    .. code-block:: console

        swapoff -a

        vim /etc/fstab

        and rem out the highlighted line below by adding "#" to the beginning of the line, write and save the file, ":wq"

    .. image:: images/disable-swap.png
        :align: center

#. Ensure the OS is up to date, run the following command

    .. tip:: You can skip this step if it was done in the previous Docker lab.

    .. code-block:: console

        apt update && apt upgrade -y

        (This can take a few seconds to a minute depending on demand to download the latest updates for the OS)

#. Install docker-ce

    .. attention:: This was done earlier in `Class 1 / Module1 / Lab 1.1: Install Docker <../../class1/module1/lab1.html>`_.  If skipped go back and install Docker by clicking the link.

#. Configure docker to use the correct cgroupdriver

    .. important:: The cgroupdrive for docker and kubernetes have to match.  In this lab "cgroupfs" is the correct driver.

    .. note:: This next part can be a bit tricky - just cut/paste the 5 lines below exactly as they are and paste via buffer to the CLI (and press return when done)

    .. code-block:: console

        cat << EOF > /etc/docker/daemon.json
        {
        "exec-opts": ["native.cgroupdriver=cgroupfs"]
        }
        EOF

    It should look something like this image below:

    .. image:: images/goodEOL.png
        :align: center

#. Add the kubernetes repo

    .. code-block:: console

        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

        cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
        deb http://apt.kubernetes.io/ kubernetes-xenial main
        EOF

#. Install the kubernetes packages

    .. code-block:: console

        apt update && apt install kubelet kubeadm kubectl -y

Limitations
-----------

For a full list of the limitations go here: `kubeadm limitations <http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations>`_

.. important:: The cluster created has a single master, with a single etcd database running on it. This means that if the master fails, your cluster loses its configuration data and will need to be recreated from scratch.
