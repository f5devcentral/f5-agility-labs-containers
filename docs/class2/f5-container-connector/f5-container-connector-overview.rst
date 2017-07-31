Overview of F5® Container Connector (CC)
========================================

Overview
--------

F5 Container connector in Mesos / Marathon is called: F5 Marathon BIG-IP Controller.

The F5 Marathon BIG-IP Controller is a container-based Marathon Application – marathon-bigip-ctlr. You can launch the F5 Marathon BIG-IP Controller in Marathon via the Marathon REST API or the Marathon Web Interface.

The marathon-bigip-ctlr watches the Marathon API for special “F5 Application Labels” that tell it:

* what Application we want it to manage
* how we want to configure the BIG-IP for that specific Application.

You can manage BIG-IP objects directly, or deploy iApps, with the F5 Marathon BIG-IP Controller.

Architecture
------------

.. image:: /_static/class2/F5-container-connector-overview-f5-solution-architecture.png
	:align: center

In Marathon, you can associate labels with Application tasks for tracking/reporting purposes. F5 has developed a set of custom “F5 Application Labels” as a way notify the F5 Marathon BIG-IP Controller and F5 Marathon ASP Controller that they have work to do.

When the F5 Marathon BIG-IP Controller discovers Applications with new or updated F5 Application Labels, it dynamically creates iApps or virtual servers, pools, pool members, and HTTP health monitors for each of the Application’s tasks.

If you want to have more details about the F5 Application Labels, you may go to the F5 official documentation here: `F5 Marathon BIG-IP Controller <http://clouddocs.f5.com/products/connectors/marathon-bigip-ctlr/v1.1/>`_

Before being able to use the Container Connecter, you need to handle some prerequisites

Prerequisites
-------------

* You must have a fully active/licensed BIG-IP
* A BIG-IP partition needs to be setup for the Container connector. You need to have access to a user with the right privileges
* You need a user with administrative access to this partition
* Your Mesos / Marathon environment must be up and running already
