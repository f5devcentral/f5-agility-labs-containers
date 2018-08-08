Lab 1.2 Run a Container on Docker
=================================

.. note:: This is only a very basic introduction to docker. For everything else see `Docker Documentation <https://docs.docker.com/>`_

#. Continuing from where we left off on the jumpbox go back to the **kube-master** session.

#. Now that docker is up and running and confirmed to be working lets deploy the latest `Apache web server <https://hub.docker.com/_/httpd/>`_.

    .. note::

        The ``docker run`` command will first look for a local cache of the container **httpd**, and upon comparing that copy to the latest instance, decide to either download an update or use the local copy.  Since there is no local copy, docker will download the container **httpd** to your local cache.  This can take a few seconds (or longer), depending on container size and your bandwidth.  Docker will chunk this into parts called a pull.

        ``--rm`` "tells docker to remove the container after stopping"

        ``--name`` "give the container a memorable name"

          ``-d`` "tells tocker to run detached. Without this the container would run in foreground and stop upon exit"

          ``-it`` "this allows for interactive process, like shell, used together in order to allocate a tty for the container process"

          ``-P`` "tells docker to auto assign any required ephemeral port and map it to the container"

    .. code-block:: console

        docker run --rm --name "myapache" -d -it -P httpd:latest


#. If everything is working properly you should see your container running.

    .. note:: ``-f`` "lets us filter on key:pair"

    .. code-block:: console

        docker ps -f name=myapache

    .. image:: images/docker-ps-myapache.png
        :align: center

    .. note:: The "PORTS" section shows the container mapping.  In this case the nodes local IP and port 32768 are mapped to the container.  We can use this info to connect to the container in the next step.

#. The httpd container "myapache, is running on kube-master (10.1.10.21) and port 32768. To test, connect to the webserver via chrome.

    .. code-block:: console

        http://ip:port

    .. image:: images/myapache.png
        :align: center


Thats it, you installed docker, downloaded a container,  ran the Hello World container, ran a web server container, and accessed your web server container via the broswer.
