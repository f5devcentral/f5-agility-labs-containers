Lab 2.2 - Configure the Cluster
===============================

Setup the Master
----------------

The master is the system where the "control plane" components run, including etcd (the cluster database) and the API server (which the kubectl CLI communicates with). All of these components run in pods started by kubelet (which is why we had to setup docker first even on the master node)

.. important:: The following commands need to be run on the **master** only unless otherwise specified.

#. Swtich back to the ssh session connected to kube-master

    .. tip:: This session should be running from the previous if lab.  If not simply open **mRemoteNG** and connect via the saved session.

#. Initialize kubernetes

    .. code-block:: console

        kubeadm init --apiserver-advertise-address=10.1.10.21 --pod-network-cidr=10.244.0.0/16

    .. note:: The IP address used to advertise the master. 10.1.10.0/24 is the network for our control plane. if you don't specify the --apiserver-advertise-address argument, kubeadm will pick the first interface with a default gateway (because it needs internet access).

    .. note:: 10.244.0.0/16 is the default network used by flannel.  We'll setup flannel in a later step.

    Be patient this step takes a few minutes.  The initialization is successful if you see "Your Kubernetes master has initialized successfully!".

    .. image:: images/cluster-setup-guide-kubeadm-init-master.png
        :align: center

    .. important:: Be sure to save the highlighted output from this command to notepad and save for use in this lab. You'll need this to add your worker nodes and configure user administration.

    .. image:: images/cluster-setup-guide-kubeadm-init-master-join.png
        :align: center

    .. important:: The "kubeadm join" command is run on the nodes to register themselves with the master. Keep the secret safe since anyone with this token can add an authenticated node to your cluster. This is used for mutual auth between the master and the nodes.

#. Configure kubernetes administration. At this point you should be logged in as root. The following will update both root and ubuntu user accounts for kubernetes administration.

    .. code-block:: console

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        exit
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        cd $HOME

#. Verify kubernetes is up and running.  You can monitor the services are running by using the following command.

    .. code-block:: console

        kubectl get pods --all-namespaces

    You'll need to run this several times until you see several containers "Running"  It should look like the following:

    .. image:: images/cluster-setup-guide-kubeadmin-init-check.png
        :align: center

    .. note:: corends won't start until the network pod is up and running.

#. Install flannel

    .. code-block:: console

        kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

    .. note:: You must install a *pod* network add-on so that your *pods* can communicate with each other. **It is necessary to do this before you try to deploy any applications to your cluster**, and before "coredns" will start up.

#. If everything installs and starts as expected you should have "coredns" and all services status "Running". To check the status of core services, you can run the followin command:

    .. code-block:: console

        kubectl get pods --all-namespaces

    The output should show all services as running.

    .. image:: images/cluster-setup-guide-kubeadmin-init-check-cluster-get-pods.png
        :align: center

    .. important:: Before moving to the next section, "Setup the nodes" wait for all system pods to show status “Running”.

#.  Addional kubernetes status checks.

    .. code-block:: console

        kubectl get cs

    .. image:: images/cluster-setup-guide-kubeadmin-init-check-cluster.png
        :align: center

    .. code-block:: console

        kubectl cluster-info

    .. image:: images/cluster-setup-guide-kubeadmin-init-check-cluster-info.png
        :align: center

Setup the Nodes
---------------

Once the master is setup and running, we need to join our *nodes* to the cluster.

.. important:: The following commands need to be run on the worker **nodes only** unless otherwise specified.

#. To join the master we need to run the command highlighted during the master initialization. You'll need to use the command saved to notepad in an earlier step.

    .. warning:: This is just an example!! **DO not cut/paste the one below.** You should have saved this command after successfully initializing the master with step 2 above.   Scroll up in your CLI history to find the hash your kube-master generated to add nodes.

    .. warning:: This command needs to be run on **node1** and **node2** only!

    .. code-block:: console

        kubeadm join 10.1.10.21:6443 --token 12rmdx.z0cbklfaoixhhdfj --discovery-token-ca-cert-hash sha256:c624989e418d92b8040a1609e493c009df5721f4392e90ac6b066c304cebe673

    The output should be similar to this:

    .. image:: images/cluster-setup-guide-node-setup-join-master.png
        :align: center

#. To verify the *nodes* have joined the cluster, run the following command on the **kube-master**:

    .. code-block:: console

        kubectl get nodes

    You should see your cluster (ie *master* + *nodes*)

    .. image:: images/cluster-setup-guide-node-setup-check-nodes.png
        :align: center


#. Verify all the services are started as expected (run on the **kube-master**)
Don't worry about last 5 characters matching on most services, as they are randomly generated:

    .. code-block:: console

        kubectl get pods --all-namespaces

    .. image:: images/cluster-setup-guide-node-setup-check-services.png
        :align: center


Install the Kubernetes UI
-------------------------

.. important:: The following commands need to be run on the **master** only.


To install the UI you have two options:

    1. Run the included script from the cloned git repo.

    or

    2. Manually run each command.

.. note:: Both options are included below.

#. "git" the demo files

    .. note:: These files should be here by default, if **NOT** run the following commands.

    .. code-block:: console

        git clone https://github.com/f5devcentral/f5-agility-labs-containers.git ~/agilitydocs

        cd ~/agilitydocs/kubernetes

#. Run the following commands to configure the UI

    .. note:: A script is included in the cloned git repo from the previous step.  In the interest of time you can simply use the script.

    .. code-block:: console

        cd /home/ubuntu/agilitydocs/kubernetes

        ./create-kube-dashboard

    or run through the following steps:

    .. code-block:: console

        kubectl create serviceaccount kubernetes-dashboard -n kube-system

        kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

    .. warning:: These commands create a service account with full admin rights.  In a typical deployment this would be overkill.

    Create a file called kube-dashboard.yaml with the following content:

    .. literalinclude:: ../../../kubernetes/kube-dashboard.yaml
        :language: yaml
        :linenos:
        :emphasize-lines: 3,23,54,65

    Apply Kubernetes manifest file:

    .. code-block:: console

         kubectl apply -f kube-dashboard.yaml

#. To access the dashboard, you need to see which port it is listening on. You can find this information with the following command:

    .. code-block:: console

        kubectl describe svc kubernetes-dashboard -n kube-system

    .. image:: images/cluster-setup-guide-check-port-ui.png
        :align: center

    .. note:: In our service we are assigned port "32005" (NodePort), you'll be assigned a different port.

    We can now access the dashboard by connecting to the following uri http://10.1.10.21:32005

    .. image:: images/cluster-setup-guide-access-ui.png
        :align: center


CONGRATUATIONS!  You just did the hardest part of todays lab - building a Kubernetes cluster.  While we didn't cover each step in great detail, due to time of other labs we need to complete today, this is one path to the overall steps to build your own cluster with a few linux boxes in your own lab.  All this content is publicaly online/available at clouddocs.f5.com. 
