Test Mesos DNS
==============

to test our Mesos DNS setup, we will start a new application and check if it automatically gets a DNS name.

Start a new app in marathon:

.. code-block:: none

  {
    "id": "app-test-dns",
    "cpus": 0.5,
    "mem": 32.0,
    "container": {
      "type": "DOCKER",
      "docker": {
        "image": "eboraas/apache-php",
        "network": "BRIDGE",
        "portMappings": [
          { "containerPort": 80, "hostPort": 0 }
        ]
      }
    }
  }

Once it's running, go to one of your slaves and run ping app-test-dns.marathon.mesos. It should work

.. image:: /_static/class2/setup-mesos-dns-test-create-app.png
  :align: center

If you don't try to ping from Slave1 or slave2, make sure that your client reach our mesos-dns server first (10.2.10.40)

.. image:: /_static/class2/setup-mesos-dns-test-ping-app.png
  :align: center
