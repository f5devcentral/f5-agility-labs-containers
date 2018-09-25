Lab 2.4 - Install the Kubernetes UI
===================================

.. important:: The following commands need to be run on the **master** only.

.. note:: You have two options to install the UI:

   1. Run the included script from the cloned git repo.
   
   2. Manually run each command.

   Both options are included below.

#. "git" the demo files

   .. note:: These files should be here by default, if **NOT** run the
      following commands.

   .. code-block:: console

      git clone https://github.com/f5devcentral/f5-agility-labs-containers.git ~/agilitydocs

      cd ~/agilitydocs/kubernetes

#. Run the following commands to configure the UI

   .. note:: A script is included in the cloned git repo from the previous
      step. In the interest of time you can simply use the script.

   .. code-block:: console

      cd /home/ubuntu/agilitydocs/kubernetes

      ./create-kube-dashboard

   or run through the following steps:

   .. code-block:: console

      kubectl create serviceaccount kubernetes-dashboard -n kube-system

      kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

   .. warning:: These commands create a service account with full admin rights.
      In a typical deployment this would be overkill.

   Create a file called kube-dashboard.yaml with the following content:

   .. literalinclude:: ../../../kubernetes/kube-dashboard.yaml
      :language: yaml
      :linenos:
      :emphasize-lines: 3,23,54,65

   Apply Kubernetes manifest file:

   .. code-block:: console

      kubectl apply -f kube-dashboard.yaml

#. To access the dashboard, you need to see which port it is listening on.
   You can find this information with the following command:

   .. code-block:: console

      kubectl describe svc kubernetes-dashboard -n kube-system

   .. image:: images/cluster-setup-guide-check-port-ui.png
      :align: center

   .. note:: In our service we are assigned port "32005" (NodePort), you'll be
      assigned a different port.

   We can now access the dashboard by connecting to the following uri
   http://10.1.10.21:32005

   .. image:: images/cluster-setup-guide-access-ui.png
      :align: center
