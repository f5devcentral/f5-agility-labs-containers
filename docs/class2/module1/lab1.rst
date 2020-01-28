OpenShift Overview
==================

Red Hat’s OpenShift Origin is a containerized application platform with a
native Kubernetes integration. The BIG-IP Controller for Kubernetes enables
use of a BIG-IP device as an edge load balancer, proxying traffic from outside
networks to pods inside an OpenShift cluster. OpenShift Origin uses a pod
network defined by the OpenShift SDN.

We will be using the following terms throughout this class so here are some
basic definitions you should be familiar with. And you'll learn more terms
along the way, but these are the basics to get you started.

- Container - Your software wrapped in a complete filesystem containing
  everything it needs to run
- Image - We are talking about Docker images; read-only and used to create
  containers
- Pod - One or more docker containers that run together
- Service - Provides a common DNS name to access a pod (or replicated set of
  pods)
- Project - A project is a group of services that are related logically (for
  this workshop we have setup your account to have access to just a single
  project)
- Deployment - an update to your application triggered by a image change or
  config change
- Build - The process of turning your source code into a runnable image
- BuildConfig - configuration data that determines how to manage your build
- Route - a labeled and DNS mapped network path to a service from outside
  OpenShift
- Master - The foreman of the OpenShift architecture, the master schedules
  operations, watches for problems, and orchestrates everything
- Node - Where the compute happens, your software is run on nodes

Access the Master
-----------------

#. From the jumpbox start an SSH session with okd-master1.

   .. code-block:: bash

      ssh or putty to IP

#. For your convenience we've already added the host IP & names to /etc/hosts.
   Verify the file is correct on each node.

   .. code-block:: bash

      cat /etc/hosts

   The file should look like this:

   .. image:: images/centos-hosts-file.png

   If entries are not there add them to the bottom of the file be editing
   "/etc/hosts" with 'vim'

   .. code-block:: bash

      sudo vim /etc/hosts

      #cut and paste the following lines to /etc/hosts

      10.1.1.10    okd-master1
      10.1.1.11    okd-node1
      10.1.1.12    okd-node2

Accessing OpenShift
-------------------

OpenShift provides a web console that allow you to perform various tasks via a
web browser. Additionally, you can utilize a command line tool to perform
tasks. Let's get started by logging into both of these and checking the status
of the platform.

#. Login to OpenShift master

   From the previous step go back to the open terminal on **okd-master1** and
   login to openshift using the following command:

   .. code-block:: bash

      oc login -u centos
      
   When prompted the password is **centos**

   .. image:: images/oc-login.png

#. Check the OpenShift status

   The **oc status** command shows a high level overview of the project
   currently in use, with its components and their relationships, as shown in
   the following example:

   .. code-block:: bash

      oc status

   .. image:: images/oc-status.png

#. Check the OpenShift nodes

   You can manage nodes in your instance using the CLI. The CLI interacts with
   node objects that are representations of actual node hosts. The master uses
   the information from node objects to validate nodes with health checks.

   To list all nodes that are known to the master:

   .. code-block:: bash

      oc get nodes

   .. image:: images/oc-get-nodes.png

   .. attention:: If the **node** status shows **NotReady** or
      **SchedulingDisabled** contact the lab proctor. The node is not passing
      the health checks performed from the master and Pods cannot be scheduled
      for placement on the node.

#. To get more detailed information about a specific node, including the reason
   for the current condition use the oc describe node command. This does
   provide alot of very useful information and can assist with throubleshooting
   issues.

   .. code-block:: bash

      oc describe node okd-master1

   .. image:: images/oc-describe-node.png

#. Check to see what projects you have access to:

   .. code-block:: bash

      oc get projects

   .. image:: images/oc-get-projects.png

   .. note:: You will be using these projects in the lab.

#. Check to see what host subnests are created on OpenShift:

   .. code-block:: bash

      oc get hostsubnets

   .. image:: images/oc-get-hostsubnets.png
     
#. Access OpenShift web console

   From the jumpbox open a browser and navigate to https://okd-master1:8443 and
   login with the user/password provided.

   Use the following username and password
   username: **centos**
   password: **centos**

   .. image:: images/webconsole.png

Troubleshooting OpenShift!
--------------------------

If you have a problem in your OpenShift environment, how do you investigate:

- How can I troubleshoot it?
- What logs can I inspect?
- How can I modify the log level / detail that openshift generates?
- I need to provide supporting data to technical support for analysis. What
  information is needed?

A starting point for data collection from an OpenShift master or node is a
sosreport that includes docker and OpenShift related information. The process
to collect a sosreport is the same as with any other Red Hat Enterprise Linux
(RHEL) based system:

.. note:: The following is provided for informational purpokds. You do not
   need to run these commands for the lab.

.. code-block:: bash

   yum update sos
   sosreport

Openshift has five log message severities. Messages with FATAL, ERROR, WARNING
and some INFO severities appear in the logs regardless of the log configuration.

.. code-block:: bash

   0 - Errors and warnings only
   2 - Normal information
   4 - Debugging-level information
   6 - API-level debugging information (request / response)
   8 - Body-level API debugging information 

This parameter can be set in the OPTIONS for the relevant services environment
file within /etc/sysconfig/

For example to set OpenShift master's log level to debug, add or edit this
line in /etc/sysconfig/origin-node

.. code-block:: bash

   OPTIONS='--loglevel=4'

   and then restart the service with
  
   sudo systemctl restart origin-node

Key files / directories

.. code-block:: console

   .. attention:: Must be **root** to see/edit these files.

   /etc/origin/{node,master}/
   /etc/origin/{node,master}/{node.master}-config.yaml
