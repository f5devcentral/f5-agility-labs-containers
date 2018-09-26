Lab 2.3 - Setup the Nodes
=========================

Once the master is setup and running, we need to join our *nodes* to the
cluster.

.. important:: The following commands need to be run on the worker
   **nodes only** unless otherwise specified.

#. To join the master we need to run the command highlighted during the master
   initialization. You'll need to use the command saved to notepad in an
   earlier step.

   .. warning:: This is just an example!! **DO not cut/paste the one below.**
      You should have saved this command after successfully initializing the
      master with step 2 above.   Scroll up in your CLI history to find the
      hash your kube-master1 generated to add nodes.

   .. warning:: This command needs to be run on **node1** and **node2** only!

   .. code-block:: bash

      kubeadm join 10.1.10.21:6443 --token 12rmdx.z0cbklfaoixhhdfj --discovery-token-ca-cert-hash sha256:c624989e418d92b8040a1609e493c009df5721f4392e90ac6b066c304cebe673

   The output should be similar to this:

   .. image:: images/cluster-setup-guide-node-setup-join-master.png
      :align: center

#. To verify the *nodes* have joined the cluster, run the following command
   on the **kube-master1**:

   .. code-block:: bash

      kubectl get nodes

   You should see your cluster (ie *master* + *nodes*)

   .. image:: images/cluster-setup-guide-node-setup-check-nodes.png
      :align: center


#. Verify all the services are started as expected (run on the **kube-master1**)
   Don't worry about last 5 characters matching on most services, as they are
   randomly generated:

   .. code-block:: bash

      kubectl get pods --all-namespaces

   .. image:: images/cluster-setup-guide-node-setup-check-services.png
      :align: center

.. attention:: CONGRATUATIONS! You just did the hardest part of todays lab - building
   a Kubernetes cluster. While we didn't cover each step in great detail, due
   to time of other labs we need to complete today, this is one path to the
   overall steps to build your own cluster with a few linux boxes in your own
   lab. All this content is publicly online/available at clouddocs.f5.com. 
