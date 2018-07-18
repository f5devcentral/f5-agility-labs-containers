Lab 3.1 - F5 Container Connector(CC) Setup
==========================================

The official CC documentation is here: `Install the F5 Kubernetes BIG-IP Controller <http://clouddocs.f5.com/containers/v1/kubernetes/kctlr-app-install.html>`_

BIG-IP setup
------------

To use F5 Container connector, you'll need a BIG-IP up and running first.

Through the Jumpbox, you should have a BIG-IP available at the following URL: https://10.1.1.245

.. warning:: Connect to your BIG-IP and check it is active and licensed. Its login and password are: **admin/admin**

    If your BIG-IP has no license or its license expired, renew the license. You just need a LTM VE license for this lab. No specific add-ons are required (ask a lab instructor for eval licenses if your license has expired)

#. You need to setup a partition that will be used by F5 Container Connector.

    .. code-block:: bash

        From the CLI:
        tmsh create auth partition kubernetes

        From the UI:
        GoTo System --> Users --> Partition List
        Create a new partition called "kubernetes" (use default settings and click Finished)

    .. image:: images/f5-container-connector-bigip-partition-setup.png
        :align: center

    With the new partition created, we can go back to Kubernetes to setup the F5 Container connector.

Container Connector Deployment
------------------------------

.. note:: For a more thorough explanation of all the settings and options see `F5 Container Connector - Kubernetes <https://clouddocs.f5.com/containers/v2/kubernetes/>`_

Now that BIG-IP is licensed and prepped with the "kubernetes" partition, we need to define a `Kubernetes deployment <https://kubernetes.io/docs/user-guide/deployments/>`_ and create a `Kubernetes secret <https://kubernetes.io/docs/user-guide/secrets/>`_ to hide our bigip credentials. 

#. From the jumphost open **mRemoteNG** and start a session with Kube-master.

    .. note:: As a reminder we're utilizing a wrapper called **MRemoteNG** for Putty and other services. MRNG hold credentials and allows for multiple protocols(i.e. SSH, RDP, etc.), makes jumping in and out of SSH connections easier.

    On your desktop select **MRemoteNG**, once launched you'll see a few tabs similar to the example below.  Open up the Kubernetes / kubernetes-Cluster folder and double click kube-master.

    .. image:: images/MRemoteNG-kubernetes.png
        :align: center

#. "git" the demo files

    .. code-block:: bash

        git clone https://github.com/iluvpcs/f5-agility-labs-containers.git
        
    .. note:: If you did the optional Kubernetes UI Lab earlier you have these files.

#. Create bigip login secret

    .. code-block:: bash

        kubectl create secret generic bigip-login -n kube-system --from-literal=username=admin --from-literal=password=admin

    You should see something similar to this:

    .. image:: images/f5-container-connector-bigip-secret.png
        :align: center

#. Create kubernetes service account for bigip controller

    .. code-block:: bash

        kubectl create serviceaccount k8s-bigip-ctlr -n kube-system

    You should see something similar to this:

    .. image:: images/f5-container-connector-bigip-serviceaccount.png
        :align: center


#. Create cluster role for bigip service account (admin rights, but can be modified for your environment)

    .. code-block:: bash

        kubectl create clusterrolebinding k8s-bigip-ctlr-clusteradmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8s-bigip-ctlr

    You should see something similar to this:

    .. image:: images/f5-container-connector-bigip-clusterrolebinding.png
        :align: center

#. At this point we have two deployment mode options, Nodeport or Cluster. For more information see `BIG-IP Controller Modes <http://clouddocs.f5.com/containers/v2/kubernetes/kctlr-modes.html>`_

    .. important:: This lab will focus on **Nodeport** but both deployment options are included below.

    #. **Nodeport mode** ``f5-nodeport-deployment.yaml``. 
    
        .. note:: For your convenience the file can be found in /home/ubuntu/f5-agility-labs-containers/kubernetes (downloaded earlier in the clone git repo step).

        .. note:: Or you can cut and paste the file below and create your own file.
            If you have issues with your yaml and syntax (**identation MATTERS**), you can try to use an online parser to help you : `Yaml parser <http://codebeautify.org/yaml-validator>`_

        .. literalinclude:: ../../../kubernetes/f5-nodeport-deployment.yaml
            :language: yaml
            :linenos:
            :emphasize-lines: 2,17,34,35,37

    #. Once you have your yaml file setup, you can try to launch your deployment. It will start our f5-k8s-controller container on one of our nodes (may take around 30sec to be in a running state):

        .. code-block:: bash

            kubectl create -f f5-nodeport-deployment.yaml

            kubectl get deployment k8s-bigip-ctlr-deployment --namespace kube-system

        .. image:: images/f5-container-connector-launch-deployment-controller.png
            :align: center

    #. To locate on which node the container connector is running, you can use the following command:

        .. code-block:: bash

            kubectl get pods -o wide -n kube-system

        We can see that our container is running on kube-node2 below.
    
        .. image:: images/f5-container-connector-locate-controller-container.png
            :align: center

    #. If you need to troubleshoot your container, you have two different ways to check the logs of your container:

        - kubectl command (recommended - easier)
        - docker command (By connecting to the relevant node. Here you'll need to identify which node is running the container)

        #. Using kubectl command: you need to use the full name of your pod as showed in the previous image

            .. code-block:: bash
                
                kubectl logs k8s-bigip-ctlr-deployment-79fcf97bcc-48qs7 -n kube-system

            .. image:: images/f5-container-connector-check-logs-kubectl.png
                :align: center

        #. Using docker logs command: From the previous check we know the container is running on kube-node1.  Via mRemoteNG open a session to kube-nodel and run the following commands:

            .. code-block:: bash

                sudo docker ps

            Here we can see our container ID is "b91d400df115"
            
            .. image:: images/f5-container-connector-find-dockerID--controller-container.png
                :align: center

            Now we can check our container logs:

            .. code-block:: bash

                sudo docker logs b91d400df115

            .. image:: images/f5-container-connector-check-logs-controller-container.png
                :align: center


    #. You can connect to your container with kubectl as well:

        .. code-block:: bash

            kubectl exec -it k8s-bigip-ctlr-deployment-79fcf97bcc-48qs7 -n kube-system  -- /bin/sh

            cd /app

            ls -lR

            exit
