Lab 2.1 - Prep Ubuntu
=====================

Overview
--------

This installation will utilize Ubuntu v16.04 (Xenial) and **kubeadm**

.. note::  You can find a more thorough installation guide here: `Ubuntu getting started guide 16.04 <http://kubernetes.io/docs/getting-started-guides/kubeadm/>`_

Setup
-----

.. attention:: The following commands need to be run on all three nodes unless otherwise specified.

#. From the jumphost open **mRemoteNG** and start a session to each of the following servers. The sessions are pre-configured to connect with the default user “ubuntu”.

    - kube-master
    - kube-node1
    - kube-node2

    .. image:: images/MremoteNG-1.png
        :align: center

#. Once connected as ubuntu user (it's the user already setup in the MremoteNG settings), let's elivate to root:

    .. code-block:: console

        su - ( when prompted for password enter "default" without the quotes )

    Your prompt should change to root@ at the start of the line :

    .. image:: images/rootuser.png
        :align: center


#. Edit /etc/hosts and add the following static hosts entries

    .. code-block:: console

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

    .. code-block:: console

        swapoff -a
        
        vim /etc/fstab 

        and rem out the highlighted line below by adding "#" to the beginning of the line, write and save the file, ":wq"

    .. image:: images/disable-swap.png
        :align: center

#. Then, to ensure the OS is up to date, run the following command

    .. code-block:: console

        apt update && apt upgrade -y

        (This can take a few seconds to a minute depending on demand to download the latest updates for the OS)

#. Install docker-ce

    .. attention:: This was done earlier in `Class 1 / Module2: Install Docker <../../class1/module2/module2.html>`_.  If skipped go back and install Docker by clicking the link.

#. Install Kubernetes

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
