.. _my-cluster-setup:

Cluster installation
====================

Overview
--------

As a reminder, in this example, this is our cluster setup:

==================  ====================  ============
     Hostname           Kubernetes IP          Role
==================  ====================  ============
     Master 1             10.1.10.11          Master
      node 1              10.1.10.21           node
      node 2              10.1.10.22           node
==================  ====================  ============


For this setup we will use the steps specified here: `Ubuntu getting started guide 16.04 <http://kubernetes.io/docs/getting-started-guides/kubeadm/>`_

For ubuntu version earlier than 15, you will need to refer to this process: `Ubuntu getting started guide <http://kubernetes.io/docs/getting-started-guides/ubuntu/manual/>`_

To install Kubernetes on our ubuntu systems, we will leverage **kubeadm**

Here are the steps that are involved (detailed later):

1. make sure that firewalld is disabled (not supported today with kubeadm)
2. disable Apparmor
3. install docker if not already done (many kubernetes services will run into containers for reliability)
4. install kubernetes packages

to make sure the systems are up to date, run this command on **all systems**:

::

	sudo apt-get update && sudo apt-get upgrade -y

.. warning::

	Make sure that your /etc/hosts files on master and nodes resolve your hostnames with 10.1.10.X IPs

installation
-------------

You need **root privileges** for this section, either use sudo or su to gain the required privileges.

you need to give access to the kubernetes packages to your systems, do this on **all systems**:

::

    apt-get update && apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    apt-get update

    sudo apt-get -y install kubectl=1.5.3-00 kubelet=1.5.3-00 kubernetes-cni=0.3.0.1-07a8a2-00

    curl -Lo /tmp/old-kubeadm.deb https://apt.k8s.io/pool/kubeadm_1.6.0-alpha.0.2074-a092d8e0f95f52-00_amd64_0206dba536f698b5777c7d210444a8ace18f48e045ab78687327631c6c694f42.deb
    sudo dpkg -i /tmp/old-kubeadm.deb
    sudo apt-get install -f

    sudo apt-mark hold kubeadm kubectl kubelet kubernetes-cni

once this is done, install docker if not already done on **all systems**:

::

	apt-get install -y docker.io


Limitations
-----------

for a full list of the limitations go here: `kubeadm limitations <http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations>`_

* the cluster created here has a single master, with a single etcd database running on it. This means that if the master fails, your cluster loses its configuration data and will need to be recreated from scratch
