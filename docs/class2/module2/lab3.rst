Lab 2.3 - Test our setup (Optional)
===================================

Our environment is setup. We can try our environment by deploying a large application built as micro services

We will use this application: `Micro services demo <https://github.com/microservices-demo/microservices-demo>`_

#. Connect to the **master** with the default "ubuntu" account and run the following command:

    .. code-block:: bash

        git clone https://github.com/microservices-demo/microservices-demo

        kubectl create namespace sock-shop

        kubectl apply -f microservices-demo/deploy/kubernetes/manifests

#. You can monitor the deployment of the application with the command:

    .. code-block:: bash

        kubectl get pods -n sock-shop

    .. image:: images/cluster-setup-guide-test-sock-shop-status.png
        :align: center

    .. warning::

        The deployment of this application may take quite some time (5-10 min)

#. Once all the containers are in a "Running" state, we can try to access our application. To access our application, we need to identify on which port our application is listening to. We can do so with the following command:

    .. code-block:: bash

        kubectl describe svc front-end -n sock-shop

    .. image:: images/cluster-setup-guide-test-sock-shop-find-IP.png
        :align: center

#. You can now access your application with the following URL: 

    .. code-block:: bash
    
        http://<master IP>:<NodePort>

    .. image:: images/cluster-setup-guide-test-sock-shop-access-ui.png
        :align: center
        :scale: 50%

#. You can also try to access it with the following URL:

    .. code-block:: bash
    
        http://<Node1 IP>:<NodePort> , http://<Node2 IP>:<NodePort>