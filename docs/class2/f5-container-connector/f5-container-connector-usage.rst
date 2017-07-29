Container Connector - Marathon BIG-IP Controller Usage
======================================================

Now that our container connector (Marathon BIG-IP Controller) is up and running, let's deploy an application and leverage our BIG-IP Controller.

The f5-demo-app is already loaded as an image (Application provided by Eric Chen - F5 Cloud SA). It is loaded in our private lab registry 10.2.10.10:5000/f5-demo-app

.. _frontend_definition:

Frontend application deployment
-------------------------------

To deploy our front-end application, we will need to do the following:

#. Go to Marathon UI and click on "Create application"
#. Click on "JSON Mode"

::

	{
		"id": "my-frontend",
		"cpus": 0.1,
		"mem": 128.0,
		"container": {
			"type": "DOCKER",
			"docker": {
				"image": "10.2.10.10:5000/f5-demo-app",
				"network": "BRIDGE",
				"portMappings": [
					{ "containerPort": 80, "hostPort": 0, "protocol": "tcp" }
				]
			}
		},
		"labels": {
			"F5_PARTITION": "mesos",
			"F5_0_BIND_ADDR": "10.2.10.80",
			"F5_0_MODE": "http",
			"F5_0_PORT": "80",
			"run": "my-frontend"
		},
		"env": {
		"F5DEMO_APP": "frontend",
		"F5DEMO_BACKEND_URL": "http://asp-my-backend.marathon.mesos:31899/"
		},
		"healthChecks": [
		{
			"protocol": "HTTP",
			"portIndex": 0,
			"path": "/",
			"gracePeriodSeconds": 5,
			"intervalSeconds": 20,
			"maxConsecutiveFailures": 3
		}
		]
	}


3.. Click on "Create Application"

.. note::

	Here we specified a few things:

	1. The involved BIG-IP configuration (Partition, VS IP, VS Port)
	2. The Marathon health check for this app. The BIG-IP will replicate those health checks
	3. We didn't specified how many instances of this application we want so it will deploy a single instance

Wait for your application to be successfully deployed and be in a running state.

.. image:: /_static/class2/f5-container-connector-check-application-running.png
	:align: center

Click on "my-frontend". Here you will see the instance deployed and how to access it (here it's 10.2.10.40:31109 - you may have something else)

.. image:: /_static/class2/f5-container-connector-check-application-instance.png
	:align: center

Click on the <IP:Port> assigned to be redirect there:

.. image:: /_static/class2/f5-container-connector-access-application-instance.png
	:align: center
	:scale: 50%

We can check whether the Marathon BIG-IP Controller has updated our BIG-IP configuration accordingly

Connect to your BIG-IP on https://10.2.10.60 and go to Local Traffic > Virtual Server. Select the Partition called "**mesos**" from the top-right corner in the GUI. You should have something like this:

.. image:: /_static/class2/f5-container-connector-check-app-on-BIG-IP-VS.png
	:align: center

Go to Local Traffic > Pool > "my-frontend_10.2.10.80_80" > Members. Here we can see that a single pool member is defined.

.. image:: /_static/class2/f5-container-connector-check-app-on-BIG-IP-Pool_members.png
	:align: center

In your browser try to connect to http://10.2.10.80. You should be able to access the application (You have a bookmark for the Frontend application in your Chrome browser):

.. image:: /_static/class2/f5-container-connector-access-BIGIP-VS.png
	:align: center
	:scale: 50%

.. note::

	if you try to click on the link "Backend App", it will fail. This is expected (Proxy Error)

Scale the application via Marathon
----------------------------------

We can try to increase the number of containers delivering our application. To do so , go back to the Marathon UI (http://10.2.10.10:8080). Go to Applications > my-frontend  and click on "Scale Application". Let's request 10 instances. Click on "Scale Application".

Once it is done, you should see 10 "healthy instances" running in Marathon UI. You can also check your pool members list on your BIG-IP.

.. image:: /_static/class2/f5-container-connector-scale-application-UI.png
	:align: center
	:scale: 50%

.. image:: /_static/class2/f5-container-connector-scale-application-UI-10-done.png
	:align: center

.. image:: /_static/class2/f5-container-connector-scale-application-BIGIP-10-done.png
	:align: center

As we can see, the Marathon BIG-IP Controller is adapting the pool members setup based on the number of instances delivering this application automatically.

Scale back the application to 1 to save ressources for the next labs
