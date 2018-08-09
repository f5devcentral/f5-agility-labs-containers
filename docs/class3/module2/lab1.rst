Lab 1.1 - F5 Container Connector Setup
======================================

The BIG-IP Controller for Marathon installs as an `Application <https://mesosphere.github.io/marathon/docs/application-basics.html>`_

.. seealso:: The official CC documentation is here: `Install the BIG-IP Controller: Marathon <http://clouddocs.f5.com/containers/v2/marathon/mctlr-app-install.html>`_

BIG-IP Setup
------------

To use F5 Container connector, you'll need a BIG-IP up and running first.

Through the Jumpbox, you should have a BIG-IP available at the following URL: https://10.1.1.245

.. warning:: Connect to your BIG-IP and check it is active and licensed. Its login and password are: **admin/admin**

    If your BIG-IP has no license or its license expired, renew the license. You just need a LTM VE license for this lab. No specific add-ons are required (ask a lab instructor for eval licenses if your license has expired)

#. You need to setup a partition that will be used by F5 Container Connector.

    .. code-block:: console

        From the CLI:
        tmsh create auth partition mesos

        From the UI:
        GoTo System --> Users --> Partition List
        - Create a new partition called "mesos" (use default settings)
        - Click Finished

    .. image:: images/f5-container-connector-bigip-partition-setup.png
		:align: center

Container Connector Deployment
------------------------------

.. note:: In this lab we have already built out your Mesos Environment. In the Kubernetes lab, we did the work via the CLI. In this lab we will use the GUI and do the tasks via the YAML/JSON format. For a more thorough explanation of all the settings and options see `F5 Container Connector - Marathon <https://clouddocs.f5.com/containers/v2/marathon/>`_

Now that BIG-IP is licensed and prepped with the "mesos" partition, we need to deploy our Marathon BIG-IP Controller, we can either use Marathon UI or use the Marathon REST API.  For this class we will be using the Marathon UI.

#. From the jumpbox connect to the Marathon UI on `http://10.2.10.10:8080 <http://10.2.10.10:8080>`_ and click "Create Application".

	.. image:: images/f5-container-connector-create-application-button.png
  		:align: center

#. Click on "JSON mode" in the top-right corner

	.. image:: images/f5-container-connector-json-mode.png
  		:align: center

#. **REPLACE** the 8 lines of default JSON code shown with the following JSON code and click Create Application

	.. literalinclude:: ../../../marathon/f5-bigip-ctlr.json
		:language: json
		:linenos:
		:emphasize-lines: 9,14,15

	.. image:: images/f5-container-connector-create-f5-cc.png

#. After a few seconds you should have a 2nd application folder labeled “F5” as shown in this picture.

	.. image:: images/f5-container-connector-clickF5folder.png
  		:align: center

#.  Click on the “F5” folder and you should have running the BIG-IP North/South Controller labeled marathon-bigip-ctrl

	.. image:: images/f5-container-connector-f5-folder-shown.png
  		:align: center

	.. note:: If you're running the lab outside of Agility, you need may need to update the field *image* with the appropriate path to your image:

  		* Load it on **all your agents/slaves** with the docker pull command. **sudo docker pull f5networks/marathon-bigip-ctlr:latest** for the latest version.
  		* Load it on a system and push it into your registry if needed.
  		* If your Mesos environment use authentication, here is a link explaining how to handle authentication with the Marathon BIG-IP Controller: `Set up authentication to your secure DC/OS cluster <http://clouddocs.f5.com/containers/v1/marathon/mctlr-authenticate-dcos.html#mesos-authentication>`_

#. If you need to troubleshoot your container, you have two different ways to check the logs of your container:

	- Marathon UI
	- Docker command (By connecting to the relevant node. Here you'll need to identify which node is running the container)

		#. Using the Marathon UI

			Click on Applications --> the f5 folder --> marathon-bigip-ctlr --> From here you can download and view the logs from the text editor of choice.

			You should see something like this:

			.. image:: images/f5-container-connector-logs.png
				:align: center

		#. To check the logs with docker, you need to identify where the Controller is running. From the previous step we can see it's running on 10.2.10.40 (which is **f5-mesos-agent1**).

			.. image:: images/f5-container-connector-locate-bigip-controller.png
				:align: center

		#. Connect via SSH to **f5-mesos-agent1** and run the following commands:

			.. code-block:: console

				sudo docker ps

			This command will give us the Controllers Container ID, here it is: 43c11f8d0cfa. We need this ID for the next few commands

			.. image:: images/f5-container-connector-get-bigip-ctlr-container-id.png
				:align: center

		#. To check the logs of our Controller:

			.. code-block:: console

				sudo docker logs 43c11f8d0cfa

			.. image:: images/f5-container-connector-check-logs-bigip-ctlr.png
				:align: center

		#. To connect to our container with a Shell:

			.. code-block:: console

				sudo docker exec -it 43c11f8d0cfa /bin/sh

				cd /app

				ls -la

				exit

			.. image:: images/f5-container-connector-run-shell-bigip-ctlr.png
				:align: center
